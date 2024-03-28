package com.example.demo.storage;

import com.example.demo.Spotify.SpotifyService;
import org.springframework.stereotype.Service;
import com.example.demo.Spotify.SpotifyService.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.List;

@Service
public class ThresholdStorage {
    private final ConcurrentHashMap<String, Integer[]> userThresholds = new ConcurrentHashMap<>();

    public void setThresholds(String username, Integer[] thresholds) {
        userThresholds.put(username, thresholds);
    }

    public Integer[] getThresholds(String username) {
        return userThresholds.getOrDefault(username, new Integer[0]);
    }

    // This could be a map of username to another map that maps the energy level to tracks
    private Map<String, Map<String, List<SpotifyService.Track>>> userTracks = new HashMap<>();

    public void storeTracks(String username, String energyLevel, List<Track> tracks) {
        userTracks.computeIfAbsent(username, k -> new HashMap<>()).put(energyLevel, tracks);
    }

    public List<Track> getTracks(String username, String energyLevel) {
        return userTracks.getOrDefault(username, new HashMap<>()).getOrDefault(energyLevel, new ArrayList<>());
    }
}
