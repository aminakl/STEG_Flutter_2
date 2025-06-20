package com.steg.loto.backend.controllers;

import com.steg.loto.backend.models.*;
import com.steg.loto.backend.repositories.*;
import com.steg.loto.backend.services.AuditService;
import com.steg.loto.backend.services.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import java.util.UUID;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/work-attestations")
public class WorkAttestationController {
    @Autowired
    private WorkAttestationRepository workAttestationRepository;

    @Autowired
    private ManoeuverSheetRepository manoeuverSheetRepository;

    @Autowired
    private WorkRepository workRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private AuditService auditService;

    @Autowired
    private NotificationService notificationService;

    @PostMapping
    @PreAuthorize("hasRole('CHARGE_CONSIGNATION')")
    public ResponseEntity<?> createWorkAttestation(
            @RequestBody WorkAttestationRequest request,
            @RequestAttribute("userId") Long userId) {
        ManoeuverSheet manoeuverSheet = manoeuverSheetRepository.findById(request.getManoeuverSheetId())
                .orElseThrow(() -> new RuntimeException("Manoeuver sheet not found"));

        Work work = workRepository.findById(request.getWorkId())
                .orElseThrow(() -> new RuntimeException("Work not found"));

        User worker = userRepository.findById(request.getWorkerId())
                .orElseThrow(() -> new RuntimeException("Worker not found"));

        // Convert equipment types to backend format
        List<String> formattedEquipmentTypes = request.getEquipmentTypes().stream()
                .map(type -> type.replace(" ", "_").toUpperCase())
                .collect(Collectors.toList());

        WorkAttestation workAttestation = new WorkAttestation();
        workAttestation.setManoeuverSheet(manoeuverSheet);
        workAttestation.setWork(work);
        workAttestation.setWorker(worker);
        workAttestation.setEquipmentTypes(formattedEquipmentTypes);

        workAttestation = workAttestationRepository.save(workAttestation);

        Map<String, Object> details = new HashMap<>();
        details.put("workAttestationId", workAttestation.getId().toString());
        details.put("workId", work.getId().toString());

        auditService.logAction(
                userId.toString(),
                "CREATE_WORK_ATTESTATION",
                details
        );

        notificationService.notifyWorkAttestationCreated(workAttestation);

        return ResponseEntity.ok(workAttestation);
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasAnyRole('CHARGE_CONSIGNATION', 'CHEF_EXPLOITATION', 'CHEF_BASE')")
    public ResponseEntity<?> getWorkAttestation(@PathVariable UUID id) {
        WorkAttestation workAttestation = workAttestationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Work attestation not found"));

        // Convert equipment types to display format before returning
        List<String> displayEquipmentTypes = workAttestation.getEquipmentTypes().stream()
                .map(type -> type.replace("_", " "))
                .collect(Collectors.toList());
        workAttestation.setEquipmentTypes(displayEquipmentTypes);

        return ResponseEntity.ok(workAttestation);
    }
}

class WorkAttestationRequest {
    private UUID manoeuverSheetId;
    private UUID workId;
    private Long workerId;
    private List<String> equipmentTypes;

    // Getters and setters
    public UUID getManoeuverSheetId() {
        return manoeuverSheetId;
    }

    public void setManoeuverSheetId(UUID manoeuverSheetId) {
        this.manoeuverSheetId = manoeuverSheetId;
    }

    public UUID getWorkId() {
        return workId;
    }

    public void setWorkId(UUID workId) {
        this.workId = workId;
    }

    public Long getWorkerId() {
        return workerId;
    }

    public void setWorkerId(Long workerId) {
        this.workerId = workerId;
    }

    public List<String> getEquipmentTypes() {
        return equipmentTypes;
    }

    public void setEquipmentTypes(List<String> equipmentTypes) {
        this.equipmentTypes = equipmentTypes;
    }
} 