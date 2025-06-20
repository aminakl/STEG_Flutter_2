package com.steg.loto.backend.services;

import com.steg.loto.backend.models.AuditLog;
import com.steg.loto.backend.repositories.AuditLogRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@Service
public class AuditService {

    @Autowired
    private AuditLogRepository auditLogRepository;

    public AuditLog logAction(String action, String userId, Map<String, Object> details) {
        AuditLog auditLog = new AuditLog(action, userId, details);
        return auditLogRepository.save(auditLog);
    }

    public List<AuditLog> findByUserId(String userId) {
        return auditLogRepository.findByUserId(userId);
    }

    public List<AuditLog> findByAction(String action) {
        return auditLogRepository.findByAction(action);
    }

    public List<AuditLog> findByTimeRange(LocalDateTime start, LocalDateTime end) {
        return auditLogRepository.findByTimestampBetween(start, end);
    }

    public List<AuditLog> findAll() {
        return auditLogRepository.findAll();
    }
}
