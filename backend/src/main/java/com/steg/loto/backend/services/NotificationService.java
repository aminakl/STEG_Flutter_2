package com.steg.loto.backend.services;

import com.steg.loto.backend.models.LockoutNote;
import com.steg.loto.backend.models.Notification;
import com.steg.loto.backend.models.User;
import com.steg.loto.backend.models.WorkAttestation;
import com.steg.loto.backend.repositories.NotificationRepository;
import com.steg.loto.backend.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
public class NotificationService {

    @Autowired
    private NotificationRepository notificationRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    /**
     * Create a notification for a specific user
     */
    public Notification createNotification(String title, String message, 
                                          Notification.NotificationType type, 
                                          User user, UUID relatedNoteId) {
        Notification notification = new Notification();
        notification.setTitle(title);
        notification.setMessage(message);
        notification.setType(type);
        notification.setUser(user);
        notification.setRelatedNoteId(relatedNoteId);
        notification.setRead(false);
        
        return notificationRepository.save(notification);
    }
    
    /**
     * Create notifications for users with a specific role
     */
    public void createNotificationsForRole(String title, String message, 
                                          Notification.NotificationType type, 
                                          String role, UUID relatedNoteId) {
        List<User> users = userRepository.findByRole(role);
        for (User user : users) {
            createNotification(title, message, type, user, relatedNoteId);
        }
    }
    
    /**
     * Get all notifications for a user
     */
    public List<Notification> getUserNotifications(User user) {
        return notificationRepository.findByUserOrderByCreatedAtDesc(user);
    }
    
    /**
     * Get unread notifications for a user
     */
    public List<Notification> getUnreadNotifications(User user) {
        return notificationRepository.findByUserAndReadOrderByCreatedAtDesc(user, false);
    }
    
    /**
     * Mark a notification as read
     */
    public Notification markAsRead(UUID notificationId) {
        Notification notification = notificationRepository.findById(notificationId)
            .orElseThrow(() -> new RuntimeException("Notification not found"));
        
        notification.setRead(true);
        return notificationRepository.save(notification);
    }
    
    /**
     * Mark all notifications as read for a user
     */
    public void markAllAsRead(User user) {
        List<Notification> unreadNotifications = notificationRepository.findByUserAndReadOrderByCreatedAtDesc(user, false);
        for (Notification notification : unreadNotifications) {
            notification.setRead(true);
            notificationRepository.save(notification);
        }
    }
    
    /**
     * Count unread notifications for a user
     */
    public long countUnreadNotifications(User user) {
        return notificationRepository.countUnreadNotifications(user);
    }
    
    /**
     * Create notification for note creation
     */
    public void notifyNoteCreated(LockoutNote note) {
        // Notify all Chef de Base users
        createNotificationsForRole(
            "New Note Created",
            "A new note for " + note.getPosteHt() + " has been created and requires validation.",
            Notification.NotificationType.NOTE_CREATED,
            "CHEF_DE_BASE",
            note.getId()
        );
    }
    
    /**
     * Create notification for note validation by Chef de Base
     */
    public void notifyNoteValidatedByChefBase(LockoutNote note) {
        // Notify all Charge Exploitation users
        createNotificationsForRole(
            "Note Validated by Chef de Base",
            "Note for " + note.getPosteHt() + " has been validated by Chef de Base and requires your review.",
            Notification.NotificationType.NOTE_VALIDATED_CHEF_BASE,
            "CHARGE_EXPLOITATION",
            note.getId()
        );
        
        // Notify the creator
        if (note.getCreatedBy() != null) {
            createNotification(
                "Your Note Has Been Validated",
                "Your note for " + note.getPosteHt() + " has been validated by Chef de Base.",
                Notification.NotificationType.NOTE_VALIDATED_CHEF_BASE,
                note.getCreatedBy(),
                note.getId()
            );
        }
    }
    
    /**
     * Create notification for note validation by Charge Exploitation
     */
    public void notifyNoteValidatedByChargeExploitation(LockoutNote note) {
        // Notify the assigned Charge Consignation
        if (note.getAssignedTo() != null) {
            createNotification(
                "Note Assigned to You",
                "Note for " + note.getPosteHt() + " has been validated and assigned to you.",
                Notification.NotificationType.NOTE_VALIDATED_CHARGE_EXPLOITATION,
                note.getAssignedTo(),
                note.getId()
            );
        }
        
        // Notify the creator
        if (note.getCreatedBy() != null) {
            createNotification(
                "Your Note Has Been Fully Validated",
                "Your note for " + note.getPosteHt() + " has been fully validated and assigned for consignation.",
                Notification.NotificationType.NOTE_VALIDATED_CHARGE_EXPLOITATION,
                note.getCreatedBy(),
                note.getId()
            );
        }
    }
    
    /**
     * Create notification for note rejection
     */
    public void notifyNoteRejected(LockoutNote note, String rejectionReason) {
        // Notify the creator
        if (note.getCreatedBy() != null) {
            createNotification(
                "Your Note Has Been Rejected",
                "Your note for " + note.getPosteHt() + " has been rejected. Reason: " + rejectionReason,
                Notification.NotificationType.NOTE_REJECTED,
                note.getCreatedBy(),
                note.getId()
            );
        }
        
        // Notify all Chef d'Exploitation users
        createNotificationsForRole(
            "Note Rejected",
            "A note for " + note.getPosteHt() + " has been rejected. Reason: " + rejectionReason,
            Notification.NotificationType.NOTE_REJECTED,
            "CHEF_EXPLOITATION",
            note.getId()
        );
    }
    
    /**
     * Create notification for note assignment
     */
    public void notifyNoteAssigned(LockoutNote note) {
        // Notify the assigned Charge Consignation
        if (note.getAssignedTo() != null) {
            createNotification(
                "New Note Assigned to You",
                "A note for " + note.getPosteHt() + " has been assigned to you for consignation.",
                Notification.NotificationType.NOTE_ASSIGNED,
                note.getAssignedTo(),
                note.getId()
            );
        }
    }
    
    /**
     * Create notification for consignation started
     */
    public void notifyConsignationStarted(LockoutNote note) {
        // Notify the creator
        if (note.getCreatedBy() != null) {
            createNotification(
                "Consignation Started",
                "Consignation has started for your note for " + note.getPosteHt() + ".",
                Notification.NotificationType.CONSIGNATION_STARTED,
                note.getCreatedBy(),
                note.getId()
            );
        }
        
        // Notify Charge Exploitation users
        createNotificationsForRole(
            "Consignation Started",
            "Consignation has started for note " + note.getPosteHt() + ".",
            Notification.NotificationType.CONSIGNATION_STARTED,
            "CHARGE_EXPLOITATION",
            note.getId()
        );
    }
    
    /**
     * Create notification for consignation completed
     */
    public void notifyConsignationCompleted(LockoutNote note) {
        // Notify the creator
        if (note.getCreatedBy() != null) {
            createNotification(
                "Consignation Completed",
                "Consignation has been completed for your note for " + note.getPosteHt() + ".",
                Notification.NotificationType.CONSIGNATION_COMPLETED,
                note.getCreatedBy(),
                note.getId()
            );
        }
        
        // Notify Charge Exploitation users
        createNotificationsForRole(
            "Consignation Completed",
            "Consignation has been completed for note " + note.getPosteHt() + ".",
            Notification.NotificationType.CONSIGNATION_COMPLETED,
            "CHARGE_EXPLOITATION",
            note.getId()
        );
    }
    
    /**
     * Create notification for deconsignation started
     */
    public void notifyDeconsignationStarted(LockoutNote note) {
        // Notify the creator
        if (note.getCreatedBy() != null) {
            createNotification(
                "Deconsignation Started",
                "Deconsignation has started for your note for " + note.getPosteHt() + ".",
                Notification.NotificationType.DECONSIGNATION_STARTED,
                note.getCreatedBy(),
                note.getId()
            );
        }
        
        // Notify Charge Exploitation users
        createNotificationsForRole(
            "Deconsignation Started",
            "Deconsignation has started for note " + note.getPosteHt() + ".",
            Notification.NotificationType.DECONSIGNATION_STARTED,
            "CHARGE_EXPLOITATION",
            note.getId()
        );
    }
    
    /**
     * Create notification for deconsignation completed
     */
    public void notifyDeconsignationCompleted(LockoutNote note) {
        // Notify the creator
        if (note.getCreatedBy() != null) {
            createNotification(
                "Deconsignation Completed",
                "Deconsignation has been completed for your note for " + note.getPosteHt() + ".",
                Notification.NotificationType.DECONSIGNATION_COMPLETED,
                note.getCreatedBy(),
                note.getId()
            );
        }
        
        // Notify Charge Exploitation users
        createNotificationsForRole(
            "Deconsignation Completed",
            "Deconsignation has been completed for note " + note.getPosteHt() + ".",
            Notification.NotificationType.DECONSIGNATION_COMPLETED,
            "CHARGE_EXPLOITATION",
            note.getId()
        );
        
        // Notify Chef de Base users
        createNotificationsForRole(
            "Deconsignation Completed",
            "The complete workflow has been finished for note " + note.getPosteHt() + ".",
            Notification.NotificationType.DECONSIGNATION_COMPLETED,
            "CHEF_DE_BASE",
            note.getId()
        );
    }
    
    /**
     * Create notification for work attestation creation
     */
    public void notifyWorkAttestationCreated(WorkAttestation workAttestation) {
        // Notify the creator
        if (workAttestation.getWorker() != null) {
            createNotification(
                "Work Attestation Created",
                "A work attestation has been created for your work.",
                Notification.NotificationType.NOTE_CREATED,
                workAttestation.getWorker(),
                workAttestation.getManoeuverSheet().getLockoutNote().getId()
            );
        }
        
        // Notify Charge Exploitation users
        createNotificationsForRole(
            "Work Attestation Created",
            "A work attestation has been created for note " + workAttestation.getManoeuverSheet().getLockoutNote().getPosteHt() + ".",
            Notification.NotificationType.NOTE_CREATED,
            "CHARGE_EXPLOITATION",
            workAttestation.getManoeuverSheet().getLockoutNote().getId()
        );
    }
}
