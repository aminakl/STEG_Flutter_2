package com.steg.loto.backend.controllers;

import com.steg.loto.backend.models.Notification;
import com.steg.loto.backend.models.User;
import com.steg.loto.backend.repositories.UserRepository;
import com.steg.loto.backend.services.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@RestController
@RequestMapping("/api/notifications")
public class NotificationController {

    @Autowired
    private NotificationService notificationService;

    @Autowired
    private UserRepository userRepository;

    /**
     * Get all notifications for the current user
     */
    @GetMapping
    public ResponseEntity<List<Notification>> getUserNotifications() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String currentUserMatricule = authentication.getName();
        
        User currentUser = userRepository.findByMatricule(currentUserMatricule)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        List<Notification> notifications = notificationService.getUserNotifications(currentUser);
        return ResponseEntity.ok(notifications);
    }

    /**
     * Get unread notifications for the current user
     */
    @GetMapping("/unread")
    public ResponseEntity<List<Notification>> getUnreadNotifications() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String currentUserMatricule = authentication.getName();
        
        User currentUser = userRepository.findByMatricule(currentUserMatricule)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        List<Notification> notifications = notificationService.getUnreadNotifications(currentUser);
        return ResponseEntity.ok(notifications);
    }

    /**
     * Get unread notification count for the current user
     */
    @GetMapping("/count")
    public ResponseEntity<Map<String, Long>> getUnreadNotificationCount() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String currentUserMatricule = authentication.getName();
        
        User currentUser = userRepository.findByMatricule(currentUserMatricule)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        long count = notificationService.countUnreadNotifications(currentUser);
        Map<String, Long> response = new HashMap<>();
        response.put("count", count);
        
        return ResponseEntity.ok(response);
    }

    /**
     * Mark a notification as read
     */
    @PutMapping("/{id}/read")
    public ResponseEntity<Notification> markAsRead(@PathVariable UUID id) {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String currentUserMatricule = authentication.getName();
        
        // Verify user exists
        userRepository.findByMatricule(currentUserMatricule)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        Notification notification = notificationService.markAsRead(id);
        return ResponseEntity.ok(notification);
    }

    /**
     * Mark all notifications as read for the current user
     */
    @PutMapping("/read-all")
    public ResponseEntity<Map<String, String>> markAllAsRead() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        String currentUserMatricule = authentication.getName();
        
        User currentUser = userRepository.findByMatricule(currentUserMatricule)
                .orElseThrow(() -> new RuntimeException("User not found"));
        
        notificationService.markAllAsRead(currentUser);
        
        Map<String, String> response = new HashMap<>();
        response.put("message", "All notifications marked as read");
        
        return ResponseEntity.ok(response);
    }
}
