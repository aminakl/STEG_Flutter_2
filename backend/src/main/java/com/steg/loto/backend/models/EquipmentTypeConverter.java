package com.steg.loto.backend.models;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

/**
 * Custom converter for EquipmentType enum to ensure proper database storage
 * Handles both formats (with spaces and with underscores)
 */
@Converter
public class EquipmentTypeConverter implements AttributeConverter<LockoutNote.EquipmentType, String> {

    @Override
    public String convertToDatabaseColumn(LockoutNote.EquipmentType attribute) {
        if (attribute == null) {
            return null;
        }
        
        // Convert to the display name format (with spaces) for database storage
        return attribute.getDisplayName();
    }

    @Override
    public LockoutNote.EquipmentType convertToEntityAttribute(String dbData) {
        if (dbData == null) {
            return null;
        }
        
        // Handle both formats (with spaces and with underscores)
        return LockoutNote.EquipmentType.fromDisplayName(dbData);
    }
}
