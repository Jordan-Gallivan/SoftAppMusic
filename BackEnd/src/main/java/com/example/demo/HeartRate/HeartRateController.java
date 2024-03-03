package com.example.demo.HeartRate;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.stereotype.Controller;

@Controller
public class HeartRateController {

    @MessageMapping("/heartRate")
    @SendTo("/topic/musicSuggestion")
    public String sendHeartRate(HeartRateMessage message) throws Exception {
        int heartRate = message.getHeartRate();

        return "Current Heart Rate: " + heartRate;
    }
}
