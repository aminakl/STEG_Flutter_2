package com.steg.loto.backend.controllers;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.HashMap;
import java.util.Map;
import java.util.List;

@RestController
@RequestMapping("/api/test/connection")
public class ConnectionTestController {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @GetMapping("/status")
    public ResponseEntity<Map<String, Object>> testConnection() {
        Map<String, Object> response = new HashMap<>();
        response.put("status", "success");
        response.put("message", "Backend is running and accessible");
        response.put("timestamp", System.currentTimeMillis());
        
        // Test database connection
        try {
            List<Map<String, Object>> result = jdbcTemplate.queryForList("SELECT COUNT(*) as user_count FROM users");
            response.put("database_connection", "success");
            response.put("database_info", result);
        } catch (Exception e) {
            response.put("database_connection", "failed");
            response.put("database_error", e.getMessage());
        }
        
        return ResponseEntity.ok(response);
    }
}
