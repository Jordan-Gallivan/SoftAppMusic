package com.example.demo.HeartRate;

import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import java.security.Principal;

@Controller
public class HeartRateController {

    private final SimpMessagingTemplate messagingTemplate;

    public HeartRateController(SimpMessagingTemplate messagingTemplate) {
        this.messagingTemplate = messagingTemplate;
    }

    @MessageMapping("/heartRate")
    public void sendHeartRate(HeartRateMessage message, Principal principal) throws Exception {
        int heartRate = message.getHeartRate();
        String returnMessage = "Current Heart Rate: " + heartRate;

        messagingTemplate.convertAndSendToUser(
                principal.getName(),
                "/queue/musicSuggestion",
                returnMessage
        );
    }
}
