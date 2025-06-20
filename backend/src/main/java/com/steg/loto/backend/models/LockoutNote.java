package com.steg.loto.backend.models;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "lockout_notes")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class LockoutNote {
    @Id
    private UUID id;

    @NotBlank
    private String posteHt;

    @Enumerated(EnumType.STRING)
    private NoteStatus status;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "created_by")
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private User createdBy;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "validated_by_chef_base")
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private User validatedByChefBase;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "validated_by_charge_exploitation")
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private User validatedByChargeExploitation;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "assigned_to")
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private User assignedTo;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "work_id")
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
    private Work work;

    private String rejectionReason;
    
    @Convert(converter = EquipmentTypeConverter.class)
    private EquipmentType equipmentType;
    
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

    private LocalDateTime createdAt;
    
    private LocalDateTime validatedAtChefBase;
    
    private LocalDateTime validatedAtChargeExploitation;
    
    private LocalDateTime assignedAt;
    
    private LocalDateTime consignationStartedAt;
    
    private LocalDateTime consignationCompletedAt;
    
    private LocalDateTime deconsignationStartedAt;
    
    private LocalDateTime deconsignationCompletedAt;

    public enum NoteStatus {
        DRAFT, PENDING_CHEF_BASE, PENDING_CHARGE_EXPLOITATION, VALIDATED, REJECTED
    }
    
    public enum EquipmentType {
        TRANSFORMATEUR_MD("TRANSFORMATEUR MD"), 
        COUPLAGE_HT_MD("COUPLAGE HT/MD"), 
        LIGNE_HT_MD("LIGNE HT/MD");
        
        private final String displayName;
        
        EquipmentType(String displayName) {
            this.displayName = displayName;
        }
        
        public String getDisplayName() {
            return displayName;
        }
        
        @Override
        public String toString() {
            return name(); // Return the enum name (with underscores) instead of the display name
        }
        
        public static EquipmentType fromDisplayName(String displayName) {
            if (displayName == null) {
                return null;
            }
            
            for (EquipmentType type : values()) {
                if (type.getDisplayName().equals(displayName) || type.name().equals(displayName)) {
                    return type;
                }
            }
            
            return null;
        }
    }

    @PrePersist
    protected void onCreate() {
        if (id == null) {
            id = UUID.randomUUID();
        }
        createdAt = LocalDateTime.now();
        if (status == null) {
            status = NoteStatus.DRAFT;
        }
    }
    
    public LockoutNote(String posteHt, NoteStatus status) {
        this.posteHt = posteHt;
        this.status = status;
    }
}
