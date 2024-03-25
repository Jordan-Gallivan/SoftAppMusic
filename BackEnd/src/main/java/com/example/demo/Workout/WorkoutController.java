package com.example.demo.Workout;

import com.example.demo.User.User;
import com.example.demo.User.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;
import java.util.Optional;
import com.example.demo.storage.ThresholdStorage;

@RestController
public class WorkoutController {

    private final UserRepository userRepository;
    private final ThresholdStorage thresholdStorage;

    // Constructor Injection
    @Autowired
    public WorkoutController(UserRepository userRepository, ThresholdStorage thresholdStorage) {
        this.userRepository = userRepository;
        this.thresholdStorage = thresholdStorage;
    }

    @PostMapping("/feelingToday/{username}")
    public ResponseEntity<String> updateUserPreferences(@PathVariable String username, @RequestBody String[] preferences) {
        if (preferences.length != 2) {
            return ResponseEntity.badRequest().body("Invalid preferences array. It should contain exactly two elements.");
        }

        String workoutType = preferences[0];
        String musicType = preferences[1];

        Optional<User> userOptional = userRepository.findUserByUsername(username);
        if (userOptional.isPresent()) {
            User user = userOptional.get();
            Integer[] heartRateZones = new WorkoutService().calculateHeartRateZones(workoutType, user);
            thresholdStorage.setThresholds(username, heartRateZones);
            // Now the threshold values are stored for later use

            // Spotify API handling here (track info & prep for 2 or 3 queues)
            // Endpoint needed for /next during runtime? Call through listener logic?
        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found");
        }

        String responseMessage = "Preferences received for user " + username + ": " +
                "Workout Type - " + workoutType + ", " +
                "Music Type - " + musicType;

        return ResponseEntity.ok(responseMessage);
    }
}
