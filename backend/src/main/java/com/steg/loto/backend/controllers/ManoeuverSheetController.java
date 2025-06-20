package com.steg.loto.backend.controllers;

import com.steg.loto.backend.models.ManoeuverSheet;
import com.steg.loto.backend.models.LockoutNote;
import com.steg.loto.backend.models.User;
import com.steg.loto.backend.models.Notification;
import com.steg.loto.backend.models.WorkAttestation;
import com.steg.loto.backend.repositories.ManoeuverSheetRepository;
import com.steg.loto.backend.repositories.LockoutNoteRepository;
import com.steg.loto.backend.repositories.UserRepository;
import com.steg.loto.backend.repositories.WorkAttestationRepository;
import com.steg.loto.backend.services.AuditService;
import com.steg.loto.backend.services.NotificationService;
import com.steg.loto.backend.exception.ResourceNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;
import java.util.List;

@RestController
@RequestMapping("/api/manoeuver-sheets")
public class ManoeuverSheetController {

    @Autowired
    private ManoeuverSheetRepository manoeuverSheetRepository;

    @Autowired
    private LockoutNoteRepository lockoutNoteRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private WorkAttestationRepository workAttestationRepository;

    @Autowired
    private AuditService auditService;

    @Autowired
    private NotificationService notificationService;

    @PostMapping("/{lockoutNoteId}")
    public ResponseEntity<?> createManoeuverSheet(@PathVariable UUID lockoutNoteId) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String currentUserMatricule = authentication.getName();
        
        User currentUser = userRepository.findByMatricule(currentUserMatricule)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (!currentUser.getRole().equals("CHARGE_CONSIGNATION")) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Only CHARGE_CONSIGNATION can create manoeuver sheets"));
        }

        return lockoutNoteRepository.findById(lockoutNoteId)
                .map(lockoutNote -> {
                    ManoeuverSheet manoeuverSheet = new ManoeuverSheet();
                    manoeuverSheet.setLockoutNote(lockoutNote);
                    manoeuverSheet.setCreatedBy(currentUser);

                    // Map the equipment type from lockout note to manoeuver sheet
                    String manoeuverSheetEquipmentType;
                    String lockoutNoteType = lockoutNote.getEquipmentType().getDisplayName();
                    switch (lockoutNoteType) {
                        case "TRANSFORMATEUR MD":
                            manoeuverSheetEquipmentType = "TRANSFORMATEUR";
                            break;
                        case "COUPLAGE HT/MD":
                            manoeuverSheetEquipmentType = "COUPLAGE";
                            break;
                        case "LIGNE HT/MD":
                            manoeuverSheetEquipmentType = "LIGNE_HT";
                            break;
                        default:
                            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                                    .body(Map.of("error", "Invalid equipment type from lockout note"));
                    }
                    manoeuverSheet.setEquipmentType(manoeuverSheetEquipmentType);

                    ManoeuverSheet savedSheet = manoeuverSheetRepository.save(manoeuverSheet);

                    // Log the action
                    Map<String, Object> details = new HashMap<>();
                    details.put("manoeuverSheetId", savedSheet.getId().toString());
                    details.put("lockoutNoteId", lockoutNoteId.toString());
                    details.put("equipmentType", manoeuverSheetEquipmentType);
                    auditService.logAction("MANOEUVER_SHEET_CREATED", currentUser.getId().toString(), details);

                    return ResponseEntity.ok(savedSheet);
                })
                .orElseThrow(() -> new ResourceNotFoundException("Lockout note not found with id " + lockoutNoteId));
    }

    @PutMapping("/{id}/verify-epi")
    public ResponseEntity<?> verifyEPI(@PathVariable UUID id) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String currentUserMatricule = authentication.getName();
        
        User currentUser = userRepository.findByMatricule(currentUserMatricule)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (!currentUser.getRole().equals("CHARGE_CONSIGNATION")) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Only CHARGE_CONSIGNATION can verify EPI"));
        }

        return manoeuverSheetRepository.findById(id)
                .map(sheet -> {
                    sheet.setEpiVerified(true);
                    sheet.setEpiVerifiedAt(LocalDateTime.now());
                    
                    ManoeuverSheet updatedSheet = manoeuverSheetRepository.save(sheet);

                    // Log the action
                    Map<String, Object> details = new HashMap<>();
                    details.put("manoeuverSheetId", id.toString());
                    auditService.logAction("EPI_VERIFIED", currentUser.getId().toString(), details);

                    return ResponseEntity.ok(updatedSheet);
                })
                .orElseThrow(() -> new ResourceNotFoundException("Manoeuver sheet not found with id " + id));
    }

    @PutMapping("/{id}/start-consignation")
    public ResponseEntity<?> startConsignation(@PathVariable UUID id) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String currentUserMatricule = authentication.getName();
        
        User currentUser = userRepository.findByMatricule(currentUserMatricule)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (!currentUser.getRole().equals("CHARGE_CONSIGNATION")) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Only CHARGE_CONSIGNATION can start consignation"));
        }

        return manoeuverSheetRepository.findById(id)
                .map(sheet -> {
                    if (!sheet.isEpiVerified()) {
                        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                                .body(Map.of("error", "EPI must be verified before starting consignation"));
                    }

                    sheet.setConsignationStarted(true);
                    sheet.setConsignationStartedAt(LocalDateTime.now());
                    
                    ManoeuverSheet updatedSheet = manoeuverSheetRepository.save(sheet);

                    // Log the action
                    Map<String, Object> details = new HashMap<>();
                    details.put("manoeuverSheetId", id.toString());
                    auditService.logAction("CONSIGNATION_STARTED", currentUser.getId().toString(), details);

                    return ResponseEntity.ok(updatedSheet);
                })
                .orElseThrow(() -> new ResourceNotFoundException("Manoeuver sheet not found with id " + id));
    }

    @PutMapping("/{id}/complete-consignation")
    public ResponseEntity<?> completeConsignation(@PathVariable UUID id) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String currentUserMatricule = authentication.getName();
        
        User currentUser = userRepository.findByMatricule(currentUserMatricule)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (!currentUser.getRole().equals("CHARGE_CONSIGNATION")) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Only CHARGE_CONSIGNATION can complete consignation"));
        }

        return manoeuverSheetRepository.findById(id)
                .map(sheet -> {
                    if (!sheet.isConsignationStarted()) {
                        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                                .body(Map.of("error", "Consignation must be started before completing"));
                    }

                    sheet.setConsignationCompleted(true);
                    sheet.setConsignationCompletedAt(LocalDateTime.now());
                    
                    ManoeuverSheet updatedSheet = manoeuverSheetRepository.save(sheet);

                    // Log the action
                    Map<String, Object> details = new HashMap<>();
                    details.put("manoeuverSheetId", id.toString());
                    auditService.logAction("CONSIGNATION_COMPLETED", currentUser.getId().toString(), details);

                    return ResponseEntity.ok(updatedSheet);
                })
                .orElseThrow(() -> new ResourceNotFoundException("Manoeuver sheet not found with id " + id));
    }

    @PutMapping("/{id}/start-deconsignation")
    public ResponseEntity<?> startDeconsignation(@PathVariable UUID id) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String currentUserMatricule = authentication.getName();
        
        User currentUser = userRepository.findByMatricule(currentUserMatricule)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (!currentUser.getRole().equals("CHARGE_CONSIGNATION")) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Only CHARGE_CONSIGNATION can start deconsignation"));
        }

        return manoeuverSheetRepository.findById(id)
                .map(sheet -> {
                    if (!sheet.isConsignationCompleted()) {
                        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                                .body(Map.of("error", "Consignation must be completed before starting deconsignation"));
                    }

                    sheet.setDeconsignationStarted(true);
                    sheet.setDeconsignationStartedAt(LocalDateTime.now());
                    
                    ManoeuverSheet updatedSheet = manoeuverSheetRepository.save(sheet);

                    // Log the action
                    Map<String, Object> details = new HashMap<>();
                    details.put("manoeuverSheetId", id.toString());
                    auditService.logAction("DECONSIGNATION_STARTED", currentUser.getId().toString(), details);

                    return ResponseEntity.ok(updatedSheet);
                })
                .orElseThrow(() -> new ResourceNotFoundException("Manoeuver sheet not found with id " + id));
    }

    @PutMapping("/{id}/complete-deconsignation")
    public ResponseEntity<?> completeDeconsignation(@PathVariable UUID id) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String currentUserMatricule = authentication.getName();
        
        User currentUser = userRepository.findByMatricule(currentUserMatricule)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        if (!currentUser.getRole().equals("CHARGE_CONSIGNATION")) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN)
                    .body(Map.of("error", "Only CHARGE_CONSIGNATION can complete deconsignation"));
        }

        return manoeuverSheetRepository.findById(id)
                .map(sheet -> {
                    if (!sheet.isDeconsignationStarted()) {
                        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                                .body(Map.of("error", "Deconsignation must be started before completing"));
                    }

                    sheet.setDeconsignationCompleted(true);
                    sheet.setDeconsignationCompletedAt(LocalDateTime.now());
                    
                    // Create work attestation
                    WorkAttestation workAttestation = new WorkAttestation();
                    workAttestation.setManoeuverSheet(sheet);
                    workAttestation.setWork(sheet.getLockoutNote().getWork());
                    workAttestation.setWorker(sheet.getLockoutNote().getWork().getWorker());
                    workAttestation.setEquipmentTypes(List.of(sheet.getEquipmentType()));
                    
                    WorkAttestation savedAttestation = workAttestationRepository.save(workAttestation);
                    
                    // Update manoeuver sheet with work attestation
                    sheet.setWorkAttestationId(savedAttestation.getId());
                    ManoeuverSheet updatedSheet = manoeuverSheetRepository.save(sheet);

                    // Log the action
                    Map<String, Object> details = new HashMap<>();
                    details.put("manoeuverSheetId", id.toString());
                    details.put("workAttestationId", savedAttestation.getId().toString());
                    auditService.logAction("DECONSIGNATION_COMPLETED", currentUser.getId().toString(), details);

                    // Notify completion
                    notificationService.notifyDeconsignationCompleted(sheet.getLockoutNote());

                    return ResponseEntity.ok(updatedSheet);
                })
                .orElseThrow(() -> new ResourceNotFoundException("Manoeuver sheet not found with id " + id));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> getManoeuverSheet(@PathVariable UUID id) {
        return manoeuverSheetRepository.findById(id)
                .map(sheet -> {
                    if (sheet.getWorkAttestationId() != null) {
                        WorkAttestation attestation = workAttestationRepository.findById(sheet.getWorkAttestationId()).orElse(null);
                        sheet.setWorkAttestation(attestation);
                    }
                    return ResponseEntity.ok(sheet);
                })
                .orElseThrow(() -> new ResourceNotFoundException("Manoeuver sheet not found with id " + id));
    }

    @GetMapping("/by-lockout-note/{lockoutNoteId}")
    @PreAuthorize("hasRole('CHARGE_CONSIGNATION')")
    public ResponseEntity<?> getByLockoutNoteId(@PathVariable UUID lockoutNoteId) {
        ManoeuverSheet sheet = manoeuverSheetRepository.findByLockoutNoteId(lockoutNoteId)
            .orElse(null);
        if (sheet == null) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Manoeuver sheet not found");
        }
        if (sheet.getWorkAttestationId() != null) {
            WorkAttestation attestation = workAttestationRepository.findById(sheet.getWorkAttestationId()).orElse(null);
            sheet.setWorkAttestation(attestation);
        }
        return ResponseEntity.ok(sheet);
    }

    @PostMapping("/{id}/report-incident")
    public ResponseEntity<?> reportIncident(
            @PathVariable UUID id,
            @RequestBody Map<String, String> request) {
        try {
            // Retrieve the authenticated user directly from SecurityContextHolder
            Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
            User currentUser = (User) authentication.getPrincipal();

            ManoeuverSheet sheet = manoeuverSheetRepository.findById(id)
                    .orElseThrow(() -> new ResourceNotFoundException("Manoeuver sheet not found"));

            String description = request.get("description");
            if (description == null || description.trim().isEmpty()) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "Incident description is required"));
            }

            // Get the lockout note associated with this manoeuver sheet
            LockoutNote note = sheet.getLockoutNote();
            if (note == null) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "No lockout note associated with this manoeuver sheet"));
            }

            // Create incident notification for all involved users
            String title = "Incident Reported";
            String message = String.format("An incident has been reported during manoeuver at %s: %s",
                    note.getPosteHt(), description);

            // Notify the note creator
            if (note.getCreatedBy() != null) {
                notificationService.createNotification(
                        title, message, Notification.NotificationType.INCIDENT_REPORTED,
                        note.getCreatedBy(), note.getId());
            }

            // Notify the assigned user
            if (note.getAssignedTo() != null) {
                notificationService.createNotification(
                        title, message, Notification.NotificationType.INCIDENT_REPORTED,
                        note.getAssignedTo(), note.getId());
            }

            // Notify Chef de Base
            notificationService.createNotificationsForRole(
                    title, message, Notification.NotificationType.INCIDENT_REPORTED,
                    "CHEF_DE_BASE", note.getId());

            // Notify Chef d'Exploitation
            notificationService.createNotificationsForRole(
                    title, message, Notification.NotificationType.INCIDENT_REPORTED,
                    "CHEF_EXPLOITATION", note.getId());

            return ResponseEntity.ok().build();
        } catch (ResourceNotFoundException e) {
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(Map.of("error", e.getMessage()));
        }
    }
}