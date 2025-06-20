package com.steg.loto.backend.repositories;

import com.steg.loto.backend.models.Notification;
import com.steg.loto.backend.models.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, UUID> {
    
    List<Notification> findByUserOrderByCreatedAtDesc(User user);
    
    List<Notification> findByUserAndReadOrderByCreatedAtDesc(User user, boolean read);
    
    @Query("SELECT COUNT(n) FROM Notification n WHERE n.user = ?1 AND n.read = false")
    long countUnreadNotifications(User user);
    
    List<Notification> findByRelatedNoteId(UUID noteId);
    
    long countByRead(boolean read);
}
