package com.example.demo.message;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping(path = "/hello")
public class MessageController {

    @GetMapping
    public Message helloWorld() {
        return new Message("hello world");
    }
}
