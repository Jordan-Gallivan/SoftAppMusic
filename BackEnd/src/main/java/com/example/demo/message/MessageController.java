package com.example.demo.message;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;
import java.util.HashMap;
import java.util.Map;
import java.util.List;
import java.util.Arrays;

@RestController
@RequestMapping(path = "/")
public class MessageController {

    // Existing @GetMapping for "/hello"
    @GetMapping(path = "/hello")
    public Message helloWorld() {
        return new Message("hello world");
    }

    // New @GetMapping for "/music_type"
    @GetMapping(path = "/music_type")
    public Map<String, List<String>> getMusicType() {
        Map<String, List<String>> musicType = new HashMap<>();
        musicType.put("decades", Arrays.asList("60s", "70s", "80s", "90s", "2000s", "2010s"));
        musicType.put("genres", Arrays.asList("Pop", "Funk", "Grunge", "Rock", "Rap", "Techno"));
        return musicType;
    }

    // New @GetMapping for "/workout_type"
    @GetMapping(path = "/workout_type")
    public List<String> getWorkoutType() {
        return Arrays.asList("Weight Lifting", "Powerlifting", "HIIT", "Sprints", "Distance Running", "Bodyweight Exercises");
    }
}

