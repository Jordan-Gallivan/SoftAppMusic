package com.example.demo.Workout;

import com.example.demo.Spotify.SpotifyService;
import com.example.demo.Spotify.SpotifyService.*;
import com.example.demo.User.User;
import com.example.demo.User.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.ResponseEntity;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import com.example.demo.storage.ThresholdStorage;

@RestController
public class WorkoutController {

    private SpotifyService spotifyService;
    private final UserRepository userRepository;
    private final ThresholdStorage thresholdStorage;

    // Constructor Injection
    @Autowired
    public WorkoutController(UserRepository userRepository, ThresholdStorage thresholdStorage) {
        this.userRepository = userRepository;
        this.thresholdStorage = thresholdStorage;
    }

    @PostMapping("/InitiateWorkout/{username}")
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

            // Spotify API handling here (track info & prep for 3 queues)
            List<Track> tracks = spotifyService.searchTracks(musicType + " music");

            // Categorize tracks based on energy level
            List<Track> slowTracks = new ArrayList<>();
            List<Track> midTracks = new ArrayList<>();
            List<Track> fastTracks = new ArrayList<>();

            for (Track track : tracks) {
                AudioFeatures features = spotifyService.fetchAudioFeatures(track.getId());
                // Assuming energy is a float value between 0.0 and 1.0
                if (features.getEnergy() < 0.33) {
                    slowTracks.add(track);
                } else if (features.getEnergy() < 0.66) {
                    midTracks.add(track);
                } else {
                    fastTracks.add(track);
                }
            }

            thresholdStorage.storeTracks(username,"slow", slowTracks);
            thresholdStorage.storeTracks(username,"mid", midTracks);
            thresholdStorage.storeTracks(username,"fast", fastTracks);


        } else {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body("User not found");
        }

        String responseMessage = "Preferences received for user " + username + ": " +
                "Workout Type - " + workoutType + ", " +
                "Music Type - " + musicType;

        return ResponseEntity.ok(responseMessage);
    }
}
