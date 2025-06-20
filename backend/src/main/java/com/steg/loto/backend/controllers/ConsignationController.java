package com.steg.loto.backend.controllers;

import com.steg.loto.backend.models.LockoutNote;
import com.steg.loto.backend.models.User;
import com.steg.loto.backend.repositories.LockoutNoteRepository;
import com.steg.loto.backend.repositories.UserRepository;
import com.steg.loto.backend.services.AuditService;
import com.steg.loto.backend.services.NotificationService;
import com.steg.loto.backend.dto.AssignNoteRequest;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/notes")
public class ConsignationController {

    @Autowired
    private LockoutNoteRepository lockoutNoteRepository;

    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private AuditService auditService;
    
    @Autowired
    private NotificationService notificationService;
    
    // Assign a note to a Charge Consignation user
    @PutMapping("/{id}/assign")
    @PreAuthorize("hasAnyAuthority('ADMIN', 'CHARGE_EXPLOITATION')")
    public ResponseEntity<?> assignNote(@PathVariable UUID id, @Valid @RequestBody AssignNoteRequest assignRequest) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String currentUserMatricule = authentication.getName();
        
        User currentUser = userRepository.findByMatricule(currentUserMatricule)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        User assignedUser = userRepository.findById(assignRequest.getAssignedToUserId())
                .orElseThrow(() -> new RuntimeException("Assigned user not found"));
        
        // Verify the assigned user is a CHARGE_CONSIGNATION
        if (!assignedUser.getRole().equals("CHARGE_CONSIGNATION")) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body(Map.of("error", "User must be a Charge Consignation"));
        }
        
        return lockoutNoteRepository.findById(id)
                .map(note -> {
                    // Verify the note is in VALIDATED status
                    if (note.getStatus() != LockoutNote.NoteStatus.VALIDATED) {
                        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                                .body(Map.of("error", "Note must be in VALIDATED status to be assigned"));
                    }
                    
                    note.setAssignedTo(assignedUser);
                    note.setAssignedAt(LocalDateTime.now());
                    LockoutNote updatedNote = lockoutNoteRepository.save(note);
                    
                    // Log the action in MongoDB
                    Map<String, Object> details = new HashMap<>();
                    details.put("noteId", updatedNote.getId().toString());
                    details.put("posteHt", updatedNote.getPosteHt());
                    details.put("assignedTo", assignedUser.getMatricule());
                    details.put("assignedBy", currentUser.getMatricule());
                    auditService.logAction("NOTE_ASSIGNED", currentUser.getId().toString(), details);
                    
                    // Send notification to the assigned user
                    notificationService.notifyNoteAssigned(updatedNote);
                    
                    return ResponseEntity.ok(updatedNote);
                })
                .orElse(ResponseEntity.notFound().build());
    }
    
    // Start the consignation process
    @PutMapping("/{id}/consignation/start")
    @PreAuthorize("hasAnyAuthority('ADMIN', 'CHARGE_CONSIGNATION')")
    public ResponseEntity<?> startConsignation(@PathVariable UUID id) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String currentUserMatricule = authentication.getName();
        
        User currentUser = userRepository.findByMatricule(currentUserMatricule)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        return lockoutNoteRepository.findById(id)
                .map(note -> {
                    // Verify the note is assigned and in VALIDATED status
                    if (note.getStatus() != LockoutNote.NoteStatus.VALIDATED || note.getAssignedTo() == null) {
                        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                                .body(Map.of("error", "Note must be in VALIDATED status and assigned to start consignation"));
                    }
                    
                    // Verify the current user is the assigned user or an admin
                    if (!currentUser.getRole().equals("ADMIN") && 
                        !note.getAssignedTo().getId().equals(currentUser.getId())) {
                        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                                .body(Map.of("error", "Only the assigned user or an admin can start consignation"));
                    }
                    
                    note.setConsignationStartedAt(LocalDateTime.now());
                    LockoutNote updatedNote = lockoutNoteRepository.save(note);
                    
                    // Log the action in MongoDB
                    Map<String, Object> details = new HashMap<>();
                    details.put("noteId", updatedNote.getId().toString());
                    details.put("posteHt", updatedNote.getPosteHt());
                    details.put("startedBy", currentUser.getMatricule());
                    auditService.logAction("CONSIGNATION_STARTED", currentUser.getId().toString(), details);
                    
                    // Send notification to note creator and validators
                    notificationService.notifyConsignationStarted(updatedNote);
                    
                    return ResponseEntity.ok(updatedNote);
                })
                .orElse(ResponseEntity.notFound().build());
    }
    
    // Complete the consignation process
    @PutMapping("/{id}/consignation/complete")
    @PreAuthorize("hasAnyAuthority('ADMIN', 'CHARGE_CONSIGNATION')")
    public ResponseEntity<?> completeConsignation(@PathVariable UUID id) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String currentUserMatricule = authentication.getName();
        
        User currentUser = userRepository.findByMatricule(currentUserMatricule)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        return lockoutNoteRepository.findById(id)
                .map(note -> {
                    // Verify the consignation has been started
                    if (note.getConsignationStartedAt() == null) {
                        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                                .body(Map.of("error", "Consignation must be started before it can be completed"));
                    }
                    
                    // Verify the current user is the assigned user or an admin
                    if (!currentUser.getRole().equals("ADMIN") && 
                        !note.getAssignedTo().getId().equals(currentUser.getId())) {
                        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                                .body(Map.of("error", "Only the assigned user or an admin can complete consignation"));
                    }
                    
                    note.setConsignationCompletedAt(LocalDateTime.now());
                    LockoutNote updatedNote = lockoutNoteRepository.save(note);
                    
                    // Log the action in MongoDB
                    Map<String, Object> details = new HashMap<>();
                    details.put("noteId", updatedNote.getId().toString());
                    details.put("posteHt", updatedNote.getPosteHt());
                    details.put("completedBy", currentUser.getMatricule());
                    auditService.logAction("CONSIGNATION_COMPLETED", currentUser.getId().toString(), details);
                    
                    // Send notification to note creator and validators
                    notificationService.notifyConsignationCompleted(updatedNote);
                    
                    return ResponseEntity.ok(updatedNote);
                })
                .orElse(ResponseEntity.notFound().build());
    }
    
    // Start the deconsignation process
    @PutMapping("/{id}/deconsignation/start")
    @PreAuthorize("hasAnyAuthority('ADMIN', 'CHARGE_CONSIGNATION')")
    public ResponseEntity<?> startDeconsignation(@PathVariable UUID id) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String currentUserMatricule = authentication.getName();
        
        User currentUser = userRepository.findByMatricule(currentUserMatricule)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        return lockoutNoteRepository.findById(id)
                .map(note -> {
                    // Verify the consignation has been completed
                    if (note.getConsignationCompletedAt() == null) {
                        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                                .body(Map.of("error", "Consignation must be completed before deconsignation can start"));
                    }
                    
                    // Verify the current user is the assigned user or an admin
                    if (!currentUser.getRole().equals("ADMIN") && 
                        !note.getAssignedTo().getId().equals(currentUser.getId())) {
                        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                                .body(Map.of("error", "Only the assigned user or an admin can start deconsignation"));
                    }
                    
                    note.setDeconsignationStartedAt(LocalDateTime.now());
                    LockoutNote updatedNote = lockoutNoteRepository.save(note);
                    
                    // Log the action in MongoDB
                    Map<String, Object> details = new HashMap<>();
                    details.put("noteId", updatedNote.getId().toString());
                    details.put("posteHt", updatedNote.getPosteHt());
                    details.put("startedBy", currentUser.getMatricule());
                    auditService.logAction("DECONSIGNATION_STARTED", currentUser.getId().toString(), details);
                    
                    // Send notification to note creator and validators
                    notificationService.notifyDeconsignationStarted(updatedNote);
                    
                    return ResponseEntity.ok(updatedNote);
                })
                .orElse(ResponseEntity.notFound().build());
    }
    
    // Complete the deconsignation process
    @PutMapping("/{id}/deconsignation/complete")
    @PreAuthorize("hasAnyAuthority('ADMIN', 'CHARGE_CONSIGNATION')")
    public ResponseEntity<?> completeDeconsignation(@PathVariable UUID id) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String currentUserMatricule = authentication.getName();
        
        User currentUser = userRepository.findByMatricule(currentUserMatricule)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        return lockoutNoteRepository.findById(id)
                .map(note -> {
                    // Verify the deconsignation has been started
                    if (note.getDeconsignationStartedAt() == null) {
                        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                                .body(Map.of("error", "Deconsignation must be started before it can be completed"));
                    }
                    
                    // Verify the current user is the assigned user or an admin
                    if (!currentUser.getRole().equals("ADMIN") && 
                        !note.getAssignedTo().getId().equals(currentUser.getId())) {
                        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                                .body(Map.of("error", "Only the assigned user or an admin can complete deconsignation"));
                    }
                    
                    note.setDeconsignationCompletedAt(LocalDateTime.now());
                    LockoutNote updatedNote = lockoutNoteRepository.save(note);
                    
                    // Log the action in MongoDB
                    Map<String, Object> details = new HashMap<>();
                    details.put("noteId", updatedNote.getId().toString());
                    details.put("posteHt", updatedNote.getPosteHt());
                    details.put("completedBy", currentUser.getMatricule());
                    auditService.logAction("DECONSIGNATION_COMPLETED", currentUser.getId().toString(), details);
                    
                    // Send notification to note creator and validators
                    notificationService.notifyDeconsignationCompleted(updatedNote);
                    
                    return ResponseEntity.ok(updatedNote);
                })
                .orElse(ResponseEntity.notFound().build());
    }
    
    // AssignNoteRequest moved to com.steg.loto.backend.dto.AssignNoteRequest
}
