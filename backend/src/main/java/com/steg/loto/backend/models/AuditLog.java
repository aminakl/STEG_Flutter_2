package com.steg.loto.backend.models;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.Map;

@Document(collection = "audit_logs")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class AuditLog {
    
    @Id
    private String id;
    
    private String action;
    
    private String userId;
    
    private LocalDateTime timestamp;
    
    private Map<String, Object> details;
    
    public AuditLog(String action, String userId, Map<String, Object> details) {
        this.action = action;
        this.userId = userId;
        this.timestamp = LocalDateTime.now();
        this.details = details;
    }
}
