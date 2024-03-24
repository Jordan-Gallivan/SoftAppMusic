package com.example.demo.converter;

import javax.persistence.AttributeConverter;
import javax.persistence.Converter;

@Converter(autoApply = true)
public class JsonbConverter implements AttributeConverter<String, Object> {

    @Override
    public Object convertToDatabaseColumn(String attribute) {
        // Convert the String to a JSON object, PostgreSQL will handle it as jsonb
        return attribute; // Simple pass-through, enhance for actual JSON conversion
    }

    @Override
    public String convertToEntityAttribute(Object dbData) {
        // Convert the JSON object from the database to a String
        return dbData.toString(); // Simplified, needs actual JSON handling
    }
}
