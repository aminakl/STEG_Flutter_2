package com.steg.loto.backend.models;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "manoeuver_sheets")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ManoeuverSheet {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne
    @JoinColumn(name = "lockout_note_id", nullable = false)
    private LockoutNote lockoutNote;

    @ManyToOne
    @JoinColumn(name = "created_by_id", nullable = false)
    private User createdBy;

    @Column(nullable = false)
    private String equipmentType;

    @Column(nullable = false)
    private boolean epiVerified = false;

    @Column(name = "epi_verified_at")
    private LocalDateTime epiVerifiedAt;

    @Column(nullable = false)
    private boolean consignationStarted = false;

    @Column(name = "consignation_started_at")
    private LocalDateTime consignationStartedAt;

    @Column(nullable = false)
    private boolean consignationCompleted = false;

    @Column(name = "consignation_completed_at")
    private LocalDateTime consignationCompletedAt;

    @Column(nullable = false)
    private boolean deconsignationStarted = false;

    @Column(name = "deconsignation_started_at")
    private LocalDateTime deconsignationStartedAt;

    @Column(nullable = false)
    private boolean deconsignationCompleted = false;

    @Column(name = "deconsignation_completed_at")
    private LocalDateTime deconsignationCompletedAt;

    @Column(name = "work_attestation_id")
    private UUID workAttestationId;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @Transient
    private WorkAttestation workAttestation;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }

    public String getSchemaImagePath() {
        switch (equipmentType) {
            case "TRANSFORMATEUR":
                return "assets/schemas/TRANSFORMATEUR.png";
            case "COUPLAGE":
                return "assets/schemas/COUPLAGE.png";
            case "LIGNE_HT":
                return "assets/schemas/LIGNE_HT.png";
            default:
                return "assets/schemas/TRANSFORMATEUR.png"; // Default schema
        }
    }

    public UUID getWorkAttestationId() {
        return workAttestationId;
    }

    public void setWorkAttestationId(UUID workAttestationId) {
        this.workAttestationId = workAttestationId;
    }

    public WorkAttestation getWorkAttestation() {
        return workAttestation;
    }

    public void setWorkAttestation(WorkAttestation workAttestation) {
        this.workAttestation = workAttestation;
    }
} 