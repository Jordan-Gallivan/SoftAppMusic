package com.example.demo.Preference;
import static java.util.Map.entry;
import java.util.Arrays;
import java.util.List;
import java.util.Map;

import com.google.gson.Gson; 

public class Preference {
	private static final List<String> musicTypes = Arrays.asList("Rock", "Rap", "Pop", "Electro");		
	private static final List<String> workoutTypes = Arrays.asList("Long Run", "Sprint", "HIIT");		

	public Preference() { }
	
    @SuppressWarnings("unchecked")
    public static List<String> getMusicType() {
    	// Create deep copy of defaultPreferences using GSON
		Gson gson = new Gson();
		String jsonPreferenceSettings = gson.toJson(musicTypes);
    	return gson.fromJson(jsonPreferenceSettings, List.class);
    }
    
    @SuppressWarnings("unchecked")
    public static List<String> getWorkoutType() {
    	// Create deep copy of defaultPreferences using GSON
		Gson gson = new Gson();
		String jsonPreferenceSettings = gson.toJson(workoutTypes);
    	return gson.fromJson(jsonPreferenceSettings, List.class);
    }
}
