package com.example.demo.storage;

import org.springframework.stereotype.Service;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class ThresholdStorage {
    private final ConcurrentHashMap<String, Integer[]> userThresholds = new ConcurrentHashMap<>();

    public void setThresholds(String username, Integer[] thresholds) {
        userThresholds.put(username, thresholds);
    }

    public Integer[] getThresholds(String username) {
        return userThresholds.getOrDefault(username, new Integer[0]);
    }
}
