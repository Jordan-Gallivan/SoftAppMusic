package com.example.demo.Preference;
import static java.util.Map.entry;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.google.gson.Gson; 

public class Preference {
	private String userPreferenceSettingsJson;
	
	private static final Map<String, List<String>> defaultPreferences = Map.ofEntries(
		entry("decades", Arrays.asList("60s", "70s", "80s", "90s", "2000s", "2010s")),
		entry("genres", Arrays.asList("Pop", "Funk", "Grunge", "Rock", "Rap", "Techno")),
		entry("workouts", Arrays.asList("Weight Lifting", "Powerlifting", "HIIT", "Sprints", 
				"Distance Running", "Bodyweight Exercises"))
	);
	
	// this is unused and we instead decide false/true based on whether value is in list
	private static final Map<String, Map<String, Boolean>> defaultPreferenceSettings = Map.ofEntries(
		entry("decades", Map.ofEntries(
				entry("60s", false), 
				entry("70s", false), 
				entry("80s", false), 
				entry("90s", false), 
				entry("2000s", false), 
				entry("2010s", false)
			)
		),
		entry("genres", Map.ofEntries(
				entry("Pop", false), 
				entry("Funk", false), 
				entry("Grunge", false), 
				entry("Rock", false), 
				entry("Rap", false), 
				entry("Techno", false)
			)
		),
		entry("workouts", Map.ofEntries(
				entry("Weight Lifting", false), 
				entry("Powerlifting", false), 
				entry("HIIT", false), 
				entry("Sprints", false), 
				entry("Distance Running", false), 
				entry("Bodyweight Exercises", false)
			)
		)
	);
		
	public Preference() { }
	
    @SuppressWarnings("unchecked")
    public static Map<String, List<String>> getDefaultPreferences() {
    	// Create deep copy of defaultPreferences using GSON
		Gson gson = new Gson();
		String jsonPreferenceSettings = gson.toJson(defaultPreferences);
    	return gson.fromJson(jsonPreferenceSettings, Map.class);
    }
    
    @Override
    public String toString() {
    	String jsonPreferenceSettings = new Gson().toJson(defaultPreferences);
        return jsonPreferenceSettings;
    }
}
