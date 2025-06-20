package com.steg.loto.backend.controllers;

import com.steg.loto.backend.models.LockoutNote;
import com.steg.loto.backend.models.User;
import com.steg.loto.backend.repositories.LockoutNoteRepository;
import com.steg.loto.backend.repositories.NotificationRepository;
import com.steg.loto.backend.repositories.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin/dashboard")
@PreAuthorize("hasAuthority('ADMIN')")
public class AdminDashboardController {

    @Autowired
    private LockoutNoteRepository lockoutNoteRepository;

    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private NotificationRepository notificationRepository;

    /**
     * Get overall statistics for the admin dashboard
     */
    @GetMapping("/stats")
    public ResponseEntity<Map<String, Object>> getDashboardStats() {
        Map<String, Object> stats = new HashMap<>();
        
        // Count users by role
        Map<String, Long> usersByRole = userRepository.findAll().stream()
                .collect(Collectors.groupingBy(User::getRole, Collectors.counting()));
        stats.put("usersByRole", usersByRole);
        
        // Count notes by status
        Map<String, Long> notesByStatus = lockoutNoteRepository.findAll().stream()
                .collect(Collectors.groupingBy(note -> note.getStatus().toString(), Collectors.counting()));
        stats.put("notesByStatus", notesByStatus);
        
        // Count notes created in the last 30 days
        LocalDateTime thirtyDaysAgo = LocalDateTime.now().minus(30, ChronoUnit.DAYS);
        long recentNotes = lockoutNoteRepository.findAll().stream()
                .filter(note -> note.getCreatedAt().isAfter(thirtyDaysAgo))
                .count();
        stats.put("notesLast30Days", recentNotes);
        
        // Average time for validation (from creation to validation)
        List<LockoutNote> validatedNotes = lockoutNoteRepository.findAll().stream()
                .filter(note -> note.getStatus() == LockoutNote.NoteStatus.VALIDATED)
                .collect(Collectors.toList());
        
        if (!validatedNotes.isEmpty()) {
            double avgValidationTimeHours = validatedNotes.stream()
                    .filter(note -> note.getValidatedAtChargeExploitation() != null)
                    .mapToDouble(note -> 
                        ChronoUnit.HOURS.between(note.getCreatedAt(), note.getValidatedAtChargeExploitation()))
                    .average()
                    .orElse(0);
            stats.put("avgValidationTimeHours", avgValidationTimeHours);
        } else {
            stats.put("avgValidationTimeHours", 0);
        }
        
        // Average time for consignation process
        List<LockoutNote> consignedNotes = lockoutNoteRepository.findAll().stream()
                .filter(note -> note.getConsignationCompletedAt() != null)
                .collect(Collectors.toList());
        
        if (!consignedNotes.isEmpty()) {
            double avgConsignationTimeHours = consignedNotes.stream()
                    .filter(note -> note.getConsignationStartedAt() != null)
                    .mapToDouble(note -> 
                        ChronoUnit.HOURS.between(note.getConsignationStartedAt(), note.getConsignationCompletedAt()))
                    .average()
                    .orElse(0);
            stats.put("avgConsignationTimeHours", avgConsignationTimeHours);
        } else {
            stats.put("avgConsignationTimeHours", 0);
        }
        
        // Average time for deconsignation process
        List<LockoutNote> deconsignedNotes = lockoutNoteRepository.findAll().stream()
                .filter(note -> note.getDeconsignationCompletedAt() != null)
                .collect(Collectors.toList());
        
        if (!deconsignedNotes.isEmpty()) {
            double avgDeconsignationTimeHours = deconsignedNotes.stream()
                    .filter(note -> note.getDeconsignationStartedAt() != null)
                    .mapToDouble(note -> 
                        ChronoUnit.HOURS.between(note.getDeconsignationStartedAt(), note.getDeconsignationCompletedAt()))
                    .average()
                    .orElse(0);
            stats.put("avgDeconsignationTimeHours", avgDeconsignationTimeHours);
        } else {
            stats.put("avgDeconsignationTimeHours", 0);
        }
        
        // Total number of notifications
        long totalNotifications = notificationRepository.count();
        stats.put("totalNotifications", totalNotifications);
        
        // Total number of unread notifications
        long unreadNotifications = notificationRepository.countByRead(false);
        stats.put("unreadNotifications", unreadNotifications);
        
        return ResponseEntity.ok(stats);
    }
    
    /**
     * Get monthly statistics for the admin dashboard
     */
    @GetMapping("/monthly-stats")
    public ResponseEntity<Map<String, Object>> getMonthlyStats() {
        Map<String, Object> stats = new HashMap<>();
        
        // Get current month and year
        LocalDateTime now = LocalDateTime.now();
        int currentMonth = now.getMonthValue();
        int currentYear = now.getYear();
        
        // Count notes created per month for the last 6 months
        Map<String, Long> notesPerMonth = new HashMap<>();
        
        for (int i = 0; i < 6; i++) {
            int month = currentMonth - i;
            int year = currentYear;
            
            // Adjust for previous year
            if (month <= 0) {
                month += 12;
                year -= 1;
            }
            
            final int targetMonth = month;
            final int targetYear = year;
            
            long count = lockoutNoteRepository.findAll().stream()
                    .filter(note -> note.getCreatedAt().getMonthValue() == targetMonth 
                            && note.getCreatedAt().getYear() == targetYear)
                    .count();
            
            notesPerMonth.put(year + "-" + String.format("%02d", month), count);
        }
        
        stats.put("notesPerMonth", notesPerMonth);
        
        // Count notes by status per month
        Map<String, Map<String, Long>> statusPerMonth = new HashMap<>();
        
        for (int i = 0; i < 6; i++) {
            int month = currentMonth - i;
            int year = currentYear;
            
            // Adjust for previous year
            if (month <= 0) {
                month += 12;
                year -= 1;
            }
            
            final int targetMonth = month;
            final int targetYear = year;
            
            Map<String, Long> statusCounts = lockoutNoteRepository.findAll().stream()
                    .filter(note -> note.getCreatedAt().getMonthValue() == targetMonth 
                            && note.getCreatedAt().getYear() == targetYear)
                    .collect(Collectors.groupingBy(note -> note.getStatus().toString(), Collectors.counting()));
            
            statusPerMonth.put(year + "-" + String.format("%02d", month), statusCounts);
        }
        
        stats.put("statusPerMonth", statusPerMonth);
        
        return ResponseEntity.ok(stats);
    }
    
    /**
     * Get user performance statistics
     */
    @GetMapping("/user-performance")
    public ResponseEntity<Map<String, Object>> getUserPerformance() {
        Map<String, Object> stats = new HashMap<>();
        
        // Notes created by each user
        Map<String, Long> notesByCreator = lockoutNoteRepository.findAll().stream()
                .filter(note -> note.getCreatedBy() != null)
                .collect(Collectors.groupingBy(
                        note -> note.getCreatedBy().getMatricule(),
                        Collectors.counting()));
        stats.put("notesByCreator", notesByCreator);
        
        // Notes validated by each Chef de Base
        Map<String, Long> notesByChefBase = lockoutNoteRepository.findAll().stream()
                .filter(note -> note.getValidatedByChefBase() != null)
                .collect(Collectors.groupingBy(
                        note -> note.getValidatedByChefBase().getMatricule(),
                        Collectors.counting()));
        stats.put("notesByChefBase", notesByChefBase);
        
        // Notes validated by each Charge Exploitation
        Map<String, Long> notesByChargeExploitation = lockoutNoteRepository.findAll().stream()
                .filter(note -> note.getValidatedByChargeExploitation() != null)
                .collect(Collectors.groupingBy(
                        note -> note.getValidatedByChargeExploitation().getMatricule(),
                        Collectors.counting()));
        stats.put("notesByChargeExploitation", notesByChargeExploitation);
        
        // Notes assigned to each Charge Consignation
        Map<String, Long> notesByAssignee = lockoutNoteRepository.findAll().stream()
                .filter(note -> note.getAssignedTo() != null)
                .collect(Collectors.groupingBy(
                        note -> note.getAssignedTo().getMatricule(),
                        Collectors.counting()));
        stats.put("notesByAssignee", notesByAssignee);
        
        return ResponseEntity.ok(stats);
    }
}
