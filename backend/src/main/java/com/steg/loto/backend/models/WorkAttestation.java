package com.steg.loto.backend.models;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;
import java.util.UUID;
import java.util.List;

@Entity
@Table(name = "work_attestations")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class WorkAttestation {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne
    @JoinColumn(name = "manoeuver_sheet_id", nullable = false)
    private ManoeuverSheet manoeuverSheet;

    @ManyToOne
    @JoinColumn(name = "work_id", nullable = false)
    private Work work;

    @ManyToOne
    @JoinColumn(name = "worker_id", nullable = false)
    private User worker;

    @ElementCollection
    @CollectionTable(name = "work_attestation_equipment_types")
    @Column(name = "equipment_type")
    private List<String> equipmentTypes;

    @Column(nullable = false)
    private LocalDateTime createdAt;

    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @PrePersist
    protected void onCreate() {
        createdAt = LocalDateTime.now();
        updatedAt = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        updatedAt = LocalDateTime.now();
    }
} 