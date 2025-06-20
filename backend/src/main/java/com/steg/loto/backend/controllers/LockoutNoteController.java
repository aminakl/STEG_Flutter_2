package com.steg.loto.backend.controllers;

import com.steg.loto.backend.models.LockoutNote;
import com.steg.loto.backend.models.User;
import com.steg.loto.backend.models.Work;
import com.steg.loto.backend.repositories.LockoutNoteRepository;
import com.steg.loto.backend.repositories.UserRepository;
import com.steg.loto.backend.repositories.WorkRepository;
import com.steg.loto.backend.services.AuditService;
import com.steg.loto.backend.services.NotificationService;
import jakarta.validation.Valid;
import lombok.Data;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/notes")
public class LockoutNoteController {

    @Autowired
    private LockoutNoteRepository lockoutNoteRepository;

    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private AuditService auditService;
    
    @Autowired
    private NotificationService notificationService;

    @Autowired
    private WorkRepository workRepository;

    @GetMapping
    public List<LockoutNote> getAllNotes() {
        return lockoutNoteRepository.findAll();
    }

    @GetMapping("/status/{status}")
    public List<LockoutNote> getNotesByStatus(@PathVariable LockoutNote.NoteStatus status) {
        return lockoutNoteRepository.findByStatus(status);
    }

    @GetMapping("/{id}")
    public ResponseEntity<LockoutNote> getNoteById(@PathVariable UUID id) {
        return lockoutNoteRepository.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<?> createNote(@Valid @RequestBody CreateNoteRequest noteRequest) {
        try {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            String currentUserMatricule = authentication.getName();
            
            User currentUser = userRepository.findByMatricule(currentUserMatricule)
                    .orElseThrow(() -> new RuntimeException("User not found"));

            // Create work entity
            Work work = new Work();
            work.setDescription(noteRequest.getWorkNature());
            work.setWorker(currentUser);
            work = workRepository.save(work);

            LockoutNote note = new LockoutNote();
            note.setPosteHt(noteRequest.getPosteHt());
            note.setEquipmentType(noteRequest.getEquipmentType());
            note.setEquipmentDetails(noteRequest.getEquipmentDetails());
            note.setUniteSteg(noteRequest.getUniteSteg());
            note.setWorkNature(noteRequest.getWorkNature());
            note.setRetraitDate(noteRequest.getRetraitDate());
            note.setDebutTravaux(noteRequest.getDebutTravaux());
            note.setFinTravaux(noteRequest.getFinTravaux());
            note.setRetourDate(noteRequest.getRetourDate());
            note.setJoursIndisponibilite(noteRequest.getJoursIndisponibilite());
            note.setChargeRetrait(noteRequest.getChargeRetrait());
            note.setChargeConsignation(noteRequest.getChargeConsignation());
            note.setChargeTravaux(noteRequest.getChargeTravaux());
            note.setChargeEssais(noteRequest.getChargeEssais());
            note.setInstructionsTechniques(noteRequest.getInstructionsTechniques());
            note.setDestinataires(noteRequest.getDestinataires());
            note.setCoupureDemandeePar(noteRequest.getCoupureDemandeePar());
            note.setNoteTransmiseA(noteRequest.getNoteTransmiseA());
            note.setStatus(LockoutNote.NoteStatus.DRAFT);
            note.setCreatedBy(currentUser);
            note.setWork(work);
            
            LockoutNote savedNote = lockoutNoteRepository.save(note);
            
            // Log the action in MongoDB
            Map<String, Object> details = new HashMap<>();
            details.put("noteId", savedNote.getId().toString());
            details.put("posteHt", savedNote.getPosteHt());
            details.put("status", savedNote.getStatus().toString());
            details.put("createdBy", currentUser.getMatricule());
            auditService.logAction("NOTE_CREATED", currentUser.getId().toString(), details);
            
            return ResponseEntity.ok(savedNote);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", e.getMessage()));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateNote(@PathVariable UUID id, @Valid @RequestBody UpdateNoteRequest updateRequest) {
        try {
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            String currentUserMatricule = authentication.getName();
            
            User currentUser = userRepository.findByMatricule(currentUserMatricule)
                    .orElseThrow(() -> new RuntimeException("User not found"));
            
            return lockoutNoteRepository.findById(id)
                    .map(note -> {
                        // Check if user has permission to update the note
                        String userRole = currentUser.getRole();
                        boolean isCreator = note.getCreatedBy() != null && 
                                note.getCreatedBy().getId().equals(currentUser.getId());
                        boolean isChefDeBase = userRole.equals("CHEF_DE_BASE");
                        boolean isChefExploitation = userRole.equals("CHEF_EXPLOITATION");
                        boolean isAdmin = userRole.equals("ADMIN");
                        
                        // Only allow updates if note is in DRAFT status or by CHEF_DE_BASE when in PENDING_CHEF_BASE status
                        // or by ADMIN at any status
                        // Also allow CHEF_DE_BASE to modify notes in PENDING_CHEF_BASE status
                        if ((note.getStatus() == LockoutNote.NoteStatus.DRAFT && (isCreator || isChefDeBase || isChefExploitation)) || 
                            (note.getStatus() == LockoutNote.NoteStatus.PENDING_CHEF_BASE && (isChefDeBase || isAdmin)) ||
                            isAdmin) {
                            
                            if (updateRequest.getPosteHt() != null) {
                                note.setPosteHt(updateRequest.getPosteHt());
                            }
                            
                            if (updateRequest.getEquipmentType() != null) {
                                note.setEquipmentType(updateRequest.getEquipmentType());
                            }
                            
                            if (updateRequest.getEquipmentDetails() != null) {
                                note.setEquipmentDetails(updateRequest.getEquipmentDetails());
                            }
                            
                            if (updateRequest.getUniteSteg() != null) {
                                note.setUniteSteg(updateRequest.getUniteSteg());
                            }
                            
                            if (updateRequest.getWorkNature() != null) {
                                note.setWorkNature(updateRequest.getWorkNature());
                            }
                            
                            if (updateRequest.getRetraitDate() != null) {
                                note.setRetraitDate(updateRequest.getRetraitDate());
                            }
                            
                            if (updateRequest.getDebutTravaux() != null) {
                                note.setDebutTravaux(updateRequest.getDebutTravaux());
                            }
                            
                            if (updateRequest.getFinTravaux() != null) {
                                note.setFinTravaux(updateRequest.getFinTravaux());
                            }
                            
                            if (updateRequest.getRetourDate() != null) {
                                note.setRetourDate(updateRequest.getRetourDate());
                            }
                            
                            if (updateRequest.getJoursIndisponibilite() != null) {
                                note.setJoursIndisponibilite(updateRequest.getJoursIndisponibilite());
                            }
                            
                            if (updateRequest.getChargeRetrait() != null) {
                                note.setChargeRetrait(updateRequest.getChargeRetrait());
                            }
                            
                            if (updateRequest.getChargeConsignation() != null) {
                                note.setChargeConsignation(updateRequest.getChargeConsignation());
                            }
                            
                            if (updateRequest.getChargeTravaux() != null) {
                                note.setChargeTravaux(updateRequest.getChargeTravaux());
                            }
                            
                            if (updateRequest.getChargeEssais() != null) {
                                note.setChargeEssais(updateRequest.getChargeEssais());
                            }
                            
                            if (updateRequest.getInstructionsTechniques() != null) {
                                note.setInstructionsTechniques(updateRequest.getInstructionsTechniques());
                            }
                            
                            if (updateRequest.getDestinataires() != null) {
                                note.setDestinataires(updateRequest.getDestinataires());
                            }
                            
                            if (updateRequest.getCoupureDemandeePar() != null) {
                                note.setCoupureDemandeePar(updateRequest.getCoupureDemandeePar());
                            }
                            
                            if (updateRequest.getNoteTransmiseA() != null) {
                                note.setNoteTransmiseA(updateRequest.getNoteTransmiseA());
                            }
                            
                            // Handle rejection reason if provided (for Chef de Base)
                            if (isChefDeBase && updateRequest.getRejectionReason() != null) {
                                note.setRejectionReason(updateRequest.getRejectionReason());
                                note.setStatus(LockoutNote.NoteStatus.REJECTED);
                                
                                // Send notification to the creator about rejection with comment
                                try {
                                    notificationService.notifyNoteRejected(note, updateRequest.getRejectionReason());
                                } catch (Exception e) {
                                    System.err.println("Error sending rejection notification: " + e.getMessage());
                                }
                            }
                            
                            LockoutNote updatedNote = lockoutNoteRepository.save(note);
                            
                            // Log the action in MongoDB
                            try {
                                Map<String, Object> details = new HashMap<>();
                                details.put("noteId", updatedNote.getId().toString());
                                details.put("posteHt", updatedNote.getPosteHt());
                                details.put("updatedBy", currentUser.getMatricule());
                                if (updateRequest.getRejectionReason() != null) {
                                    details.put("rejectionReason", updateRequest.getRejectionReason());
                                }
                                auditService.logAction("NOTE_UPDATED", currentUser.getId().toString(), details);
                            } catch (Exception e) {
                                System.err.println("Error logging audit: " + e.getMessage());
                                // Continue even if audit logging fails
                            }
                            
                            return ResponseEntity.ok(updatedNote);
                        } else {
                            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                                    .body(Map.of("error", "You don't have permission to update this note in its current status"));
                        }
                    })
                    .orElse(ResponseEntity.notFound().build());
        } catch (Exception e) {
            System.err.println("Error updating note: " + e.getMessage());
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(Map.of("error", "Failed to update note: " + e.getMessage()));
        }
    }

    @PutMapping("/{id}/validate")
    public ResponseEntity<?> validateNote(@PathVariable UUID id, @Valid @RequestBody ValidateNoteRequest validateRequest) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String currentUserMatricule = authentication.getName();
        
        User currentUser = userRepository.findByMatricule(currentUserMatricule)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        System.out.println("Loading user with role: " + currentUser.getRole());
        System.out.println("Validating note: " + id + " with status: " + validateRequest.getStatus());
        
        return lockoutNoteRepository.findById(id)
                .map(note -> {
                    // Handle validation based on user role and current note status
                    String userRole = currentUser.getRole();
                    LockoutNote.NoteStatus newStatus = validateRequest.getStatus();
                    
                    // Check if user has permission to perform this action
                    boolean isAdmin = userRole.equals("ADMIN");
                    boolean isChefDeBase = userRole.equals("CHEF_DE_BASE");
                    boolean isChargeExploitation = userRole.equals("CHARGE_EXPLOITATION");
                    boolean isChefExploitation = userRole.equals("CHEF_EXPLOITATION");
                    
                    // Special case: Check if this is a return to draft action
                    boolean isReturningToDraft = note.getStatus() == LockoutNote.NoteStatus.REJECTED && 
                                                newStatus == LockoutNote.NoteStatus.DRAFT;
                    
                    // Log the action for debugging
                    System.out.println("User role: " + userRole);
                    System.out.println("Current note status: " + note.getStatus());
                    System.out.println("Requested new status: " + newStatus);
                    System.out.println("Is returning to draft: " + isReturningToDraft);
                    
                    // Admin can do anything
                    if (isAdmin) {
                        System.out.println("Admin user - permission granted");
                        // Continue with the action
                    }
                    // Special case: Allow Chef d'Exploitation to return a rejected note to draft
                    else if (isChefExploitation && isReturningToDraft) {
                        System.out.println("Chef d'Exploitation returning rejected note to draft - permission granted");
                        // Continue with the action
                    }
                    // Chef de Base can only validate/reject notes in PENDING_CHEF_BASE status
                    else if (isChefDeBase && note.getStatus() != LockoutNote.NoteStatus.PENDING_CHEF_BASE) {
                        System.out.println("Chef de Base trying to modify a note not in PENDING_CHEF_BASE status - permission denied");
                        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                                .body(Map.of("error", "You don't have permission to perform this action"));
                    }
                    // Charge Exploitation can only validate/reject notes in PENDING_CHARGE_EXPLOITATION status
                    else if (isChargeExploitation && note.getStatus() != LockoutNote.NoteStatus.PENDING_CHARGE_EXPLOITATION) {
                        System.out.println("Charge Exploitation trying to modify a note not in PENDING_CHARGE_EXPLOITATION status - permission denied");
                        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                                .body(Map.of("error", "You don't have permission to perform this action"));
                    }
                    // Chef d'Exploitation can submit draft notes for validation OR return rejected notes to draft
                    else if (isChefExploitation && 
                             !((note.getStatus() == LockoutNote.NoteStatus.DRAFT && newStatus == LockoutNote.NoteStatus.PENDING_CHEF_BASE) ||
                               (note.getStatus() == LockoutNote.NoteStatus.REJECTED && newStatus == LockoutNote.NoteStatus.DRAFT))) {
                        System.out.println("Chef d'Exploitation trying to perform an unauthorized action - permission denied");
                        System.out.println("Current status: " + note.getStatus() + ", Requested status: " + newStatus);
                        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                                .body(Map.of("error", "You don't have permission to perform this action"));
                    }
                    
                    // Handle rejection for any role
                    if (newStatus == LockoutNote.NoteStatus.REJECTED) {
                        note.setStatus(LockoutNote.NoteStatus.REJECTED);
                        
                        // Set rejection reason if provided
                        if (validateRequest.getRejectionReason() != null && !validateRequest.getRejectionReason().isEmpty()) {
                            note.setRejectionReason(validateRequest.getRejectionReason());
                        } else {
                            // Return error if no rejection reason is provided
                            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                                    .body(Map.of("error", "Rejection reason is required"));
                        }
                        
                        // Log the action in MongoDB
                        Map<String, Object> details = new HashMap<>();
                        details.put("noteId", note.getId().toString());
                        details.put("posteHt", note.getPosteHt());
                        details.put("status", note.getStatus().toString());
                        details.put("rejectedBy", currentUser.getMatricule());
                        details.put("rejectionReason", note.getRejectionReason());
                        auditService.logAction("NOTE_REJECTED", currentUser.getId().toString(), details);
                        
                        // Send notification about rejection
                        try {
                            notificationService.notifyNoteRejected(note, note.getRejectionReason());
                        } catch (Exception e) {
                            System.err.println("Error sending rejection notification: " + e.getMessage());
                        }
                    } 
                    // Handle Chef de Base validating
                    else if (userRole.equals("CHEF_DE_BASE") && 
                            (note.getStatus() == LockoutNote.NoteStatus.PENDING_CHEF_BASE)) {
                        if (newStatus == LockoutNote.NoteStatus.PENDING_CHARGE_EXPLOITATION) {
                            note.setStatus(LockoutNote.NoteStatus.PENDING_CHARGE_EXPLOITATION);
                            note.setValidatedByChefBase(currentUser);
                            note.setValidatedAtChefBase(LocalDateTime.now());
                            
                            // Update any additional fields if provided
                            updateNoteFields(note, validateRequest);
                            
                            // Log the action in MongoDB
                            Map<String, Object> details = new HashMap<>();
                            details.put("noteId", note.getId().toString());
                            details.put("posteHt", note.getPosteHt());
                            details.put("status", note.getStatus().toString());
                            details.put("validatedBy", currentUser.getMatricule());
                            auditService.logAction("NOTE_VALIDATED_BY_CHEF_BASE", currentUser.getId().toString(), details);
                            
                            // Send notification to Charge Exploitation users and note creator
                            notificationService.notifyNoteValidatedByChefBase(note);
                        } else if (newStatus == LockoutNote.NoteStatus.REJECTED) {
                            note.setStatus(LockoutNote.NoteStatus.REJECTED);
                            note.setRejectionReason(validateRequest.getRejectionReason());
                            
                            // Log the action in MongoDB
                            Map<String, Object> details = new HashMap<>();
                            details.put("noteId", note.getId().toString());
                            details.put("posteHt", note.getPosteHt());
                            details.put("status", note.getStatus().toString());
                            details.put("rejectedBy", currentUser.getMatricule());
                            details.put("rejectionReason", validateRequest.getRejectionReason());
                            auditService.logAction("NOTE_REJECTED_BY_CHEF_BASE", currentUser.getId().toString(), details);
                            
                            // Send rejection notification to note creator
                            notificationService.notifyNoteRejected(note, validateRequest.getRejectionReason());
                        } else {
                            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                                    .body(Map.of("error", "Invalid status transition"));
                        }
                    } 
                    // Handle Charge Exploitation validating
                    else if (userRole.equals("CHARGE_EXPLOITATION") && 
                            (note.getStatus() == LockoutNote.NoteStatus.PENDING_CHARGE_EXPLOITATION)) {
                        if (newStatus == LockoutNote.NoteStatus.VALIDATED) {
                            note.setStatus(LockoutNote.NoteStatus.VALIDATED);
                            note.setValidatedByChargeExploitation(currentUser);
                            note.setValidatedAtChargeExploitation(LocalDateTime.now());
                            
                            Map<String, Object> details = new HashMap<>();
                            details.put("noteId", note.getId().toString());
                            details.put("posteHt", note.getPosteHt());
                            details.put("status", note.getStatus().toString());
                            details.put("validatedBy", currentUser.getMatricule());
                            auditService.logAction("NOTE_VALIDATED_BY_CHARGE_EXPLOITATION", currentUser.getId().toString(), details);
                            
                            // Send notification to note creator
                            notificationService.notifyNoteValidatedByChargeExploitation(note);
                        } else if (newStatus == LockoutNote.NoteStatus.REJECTED) {
                            note.setStatus(LockoutNote.NoteStatus.REJECTED);
                            note.setRejectionReason(validateRequest.getRejectionReason());
                            
                            // Log the action in MongoDB
                            Map<String, Object> details = new HashMap<>();
                            details.put("noteId", note.getId().toString());
                            details.put("posteHt", note.getPosteHt());
                            details.put("status", note.getStatus().toString());
                            details.put("rejectedBy", currentUser.getMatricule());
                            details.put("rejectionReason", validateRequest.getRejectionReason());
                            auditService.logAction("NOTE_REJECTED_BY_CHARGE_EXPLOITATION", currentUser.getId().toString(), details);
                            
                            // Send rejection notification to note creator
                            notificationService.notifyNoteRejected(note, validateRequest.getRejectionReason());
                        } else {
                            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                                    .body(Map.of("error", "Invalid status transition"));
                        }
                    }
                    // Handle returning a rejected note to draft status
                    else if (userRole.equals("CHEF_EXPLOITATION") && 
                             note.getStatus() == LockoutNote.NoteStatus.REJECTED && 
                             newStatus == LockoutNote.NoteStatus.DRAFT) {
                        
                        System.out.println("Processing return to draft for rejected note: " + note.getId());
                        
                        // Update note status
                        note.setStatus(LockoutNote.NoteStatus.DRAFT);
                        
                        // Clear rejection reason
                        note.setRejectionReason(null);
                        
                        // Log the action in MongoDB
                        Map<String, Object> details = new HashMap<>();
                        details.put("noteId", note.getId().toString());
                        details.put("posteHt", note.getPosteHt());
                        details.put("status", note.getStatus().toString());
                        details.put("returnedBy", currentUser.getMatricule());
                        auditService.logAction("NOTE_RETURNED_TO_DRAFT", currentUser.getId().toString(), details);
                    }
                    // Handle Chef Exploitation submitting a draft note for validation
                    else if (userRole.equals("CHEF_EXPLOITATION") && 
                             note.getStatus() == LockoutNote.NoteStatus.DRAFT && 
                             newStatus == LockoutNote.NoteStatus.PENDING_CHEF_BASE) {
                        
                        // Update note status
                        note.setStatus(LockoutNote.NoteStatus.PENDING_CHEF_BASE);
                        
                        // Log the submission action in MongoDB
                        Map<String, Object> details = new HashMap<>();
                        details.put("noteId", note.getId().toString());
                        details.put("posteHt", note.getPosteHt());
                        details.put("status", note.getStatus().toString());
                        details.put("submittedBy", currentUser.getMatricule());
                        auditService.logAction("NOTE_SUBMITTED_FOR_VALIDATION", currentUser.getId().toString(), details);
                    }
                    // Handle Admin override (can change to any status)
                    else if (userRole.equals("ADMIN")) {
                        note.setStatus(newStatus);
                        
                        if (newStatus == LockoutNote.NoteStatus.VALIDATED) {
                            note.setValidatedByChefBase(currentUser);
                            note.setValidatedByChargeExploitation(currentUser);
                            note.setValidatedAtChefBase(LocalDateTime.now());
                            note.setValidatedAtChargeExploitation(LocalDateTime.now());
                        }
                        
                        // Log the action in MongoDB
                        Map<String, Object> details = new HashMap<>();
                        details.put("noteId", note.getId().toString());
                        details.put("posteHt", note.getPosteHt());
                        details.put("status", note.getStatus().toString());
                        details.put("adminAction", "Status changed by admin");
                        auditService.logAction("NOTE_STATUS_CHANGED_BY_ADMIN", currentUser.getId().toString(), details);
                    } else {
                        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                                .body(Map.of("error", "You don't have permission to perform this action"));
                    }
                    
                    LockoutNote updatedNote = lockoutNoteRepository.save(note);
                    return ResponseEntity.ok(updatedNote);
                })
                .orElse(ResponseEntity.notFound().build());
    }

    // Helper method to update note fields from validation request
    private void updateNoteFields(LockoutNote note, ValidateNoteRequest request) {
        if (request.getEquipmentType() != null) {
            note.setEquipmentType(request.getEquipmentType());
        }
        
        if (request.getEquipmentDetails() != null) {
            note.setEquipmentDetails(request.getEquipmentDetails());
        }
        
        if (request.getUniteSteg() != null) {
            note.setUniteSteg(request.getUniteSteg());
        }
        
        if (request.getWorkNature() != null) {
            note.setWorkNature(request.getWorkNature());
        }
        
        if (request.getRetraitDate() != null) {
            note.setRetraitDate(request.getRetraitDate());
        }
        
        if (request.getDebutTravaux() != null) {
            note.setDebutTravaux(request.getDebutTravaux());
        }
        
        if (request.getFinTravaux() != null) {
            note.setFinTravaux(request.getFinTravaux());
        }
        
        if (request.getRetourDate() != null) {
            note.setRetourDate(request.getRetourDate());
        }
        
        if (request.getJoursIndisponibilite() != null) {
            note.setJoursIndisponibilite(request.getJoursIndisponibilite());
        }
        
        if (request.getChargeRetrait() != null) {
            note.setChargeRetrait(request.getChargeRetrait());
        }
        
        if (request.getChargeConsignation() != null) {
            note.setChargeConsignation(request.getChargeConsignation());
        }
        
        if (request.getChargeTravaux() != null) {
            note.setChargeTravaux(request.getChargeTravaux());
        }
        
        if (request.getChargeEssais() != null) {
            note.setChargeEssais(request.getChargeEssais());
        }
        
        if (request.getInstructionsTechniques() != null) {
            note.setInstructionsTechniques(request.getInstructionsTechniques());
        }
        
        if (request.getDestinataires() != null) {
            note.setDestinataires(request.getDestinataires());
        }
        
        if (request.getCoupureDemandeePar() != null) {
            note.setCoupureDemandeePar(request.getCoupureDemandeePar());
        }
        
        if (request.getNoteTransmiseA() != null) {
            note.setNoteTransmiseA(request.getNoteTransmiseA());
        }
    }
    
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteNote(@PathVariable UUID id) {
        return lockoutNoteRepository.findById(id)
                .map(note -> {
                    lockoutNoteRepository.delete(note);
                    return ResponseEntity.ok().build();
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @Data
    public static class CreateNoteRequest {
        private String posteHt;
        private LockoutNote.EquipmentType equipmentType;
        private String equipmentDetails;
        private String uniteSteg;
        private String workNature;
        private LocalDateTime retraitDate;
        private LocalDateTime debutTravaux;
        private LocalDateTime finTravaux;
        private LocalDateTime retourDate;
        private Integer joursIndisponibilite;
        private String chargeRetrait;
        private String chargeConsignation;
        private String chargeTravaux;
        private String chargeEssais;
        private String instructionsTechniques;
        private String destinataires;
        private String coupureDemandeePar;
        private String noteTransmiseA;
    }

    @Data
    public static class ValidateNoteRequest {
        private LockoutNote.NoteStatus status;
        private String rejectionReason;
        private String equipmentDetails;
        // Additional fields that might be updated during validation
        private LockoutNote.EquipmentType equipmentType;
        private String uniteSteg;
        private String workNature;
        private LocalDateTime retraitDate;
        private LocalDateTime debutTravaux;
        private LocalDateTime finTravaux;
        private LocalDateTime retourDate;
        private Integer joursIndisponibilite;
        private String chargeRetrait;
        private String chargeConsignation;
        private String chargeTravaux;
        private String chargeEssais;
        private String instructionsTechniques;
        private String destinataires;
        private String coupureDemandeePar;
        private String noteTransmiseA;
    }

    @Data
    public static class UpdateNoteRequest {
        private String posteHt;
        private LockoutNote.EquipmentType equipmentType;
        private String equipmentDetails;
        private String uniteSteg;
        private String workNature;
        private LocalDateTime retraitDate;
        private LocalDateTime debutTravaux;
        private LocalDateTime finTravaux;
        private LocalDateTime retourDate;
        private Integer joursIndisponibilite;
        private String chargeRetrait;
        private String chargeConsignation;
        private String chargeTravaux;
        private String chargeEssais;
        private String instructionsTechniques;
        private String destinataires;
        private String coupureDemandeePar;
        private String noteTransmiseA;
        private String rejectionReason;
    }
}
