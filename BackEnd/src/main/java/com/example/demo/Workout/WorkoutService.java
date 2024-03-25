package com.example.demo.Workout;

import com.example.demo.User.User;
import java.util.HashMap;
import java.util.Map;

public class WorkoutService {

    // Define the zones in a Map for easy reference
    private static final Map<String, Integer[]> workoutZones = new HashMap<>();
    static {
        workoutZones.put("Sprint", new Integer[] { 75 }); // Only one threshold: 75%
        workoutZones.put("HIIT", new Integer[] { 75 });   // Only one threshold: 75%
        workoutZones.put("Long Run", new Integer[] { 50, 75 }); // Two thresholds: 50% and 75%
    }

    public Integer[] calculateHeartRateZones(String workoutType, User user) {
        Integer[] thresholdsPercentage = workoutZones.getOrDefault(workoutType, new Integer[0]);
        int maxHeartRate = user.calculateMaxHeartRate();
        Integer[] thresholds = new Integer[thresholdsPercentage.length];

        for (int i = 0; i < thresholdsPercentage.length; i++) {
            thresholds[i] = (int) (maxHeartRate * (thresholdsPercentage[i] / 100.0));
        }

        return thresholds; // Thresholds calculated as actual heart rates
    }
}
