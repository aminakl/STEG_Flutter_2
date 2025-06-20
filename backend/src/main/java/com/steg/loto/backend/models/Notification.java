package com.steg.loto.backend.models;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "notifications")
@Data
@NoArgsConstructor
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    @Column(nullable = false)
    private String title;

    @Column(nullable = false)
    private String message;

    @Column(name = "notification_type", nullable = false)
    @Enumerated(EnumType.STRING)
    private NotificationType type;

    @Column(name = "related_note_id")
    private UUID relatedNoteId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private User user;

    @Column(nullable = false)
    private boolean read = false;

    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt = LocalDateTime.now();

    public enum NotificationType {
        NOTE_CREATED,
        NOTE_VALIDATED_CHEF_BASE,
        NOTE_VALIDATED_CHARGE_EXPLOITATION,
        NOTE_REJECTED,
        NOTE_ASSIGNED,
        CONSIGNATION_STARTED,
        CONSIGNATION_COMPLETED,
        DECONSIGNATION_STARTED,
        DECONSIGNATION_COMPLETED,
        INCIDENT_REPORTED
    }
}
