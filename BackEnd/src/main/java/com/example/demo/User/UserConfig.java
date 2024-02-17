package com.example.demo.User;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class UserConfig {

    @Bean
    CommandLineRunner commandLineRunner(UserRepository repository) {
        return args -> {
            User johnSmith = new User(
                    "username",
                    "john",
                    "smith",
                    "test@email.com",
                    "password",
                    "no"
            );

            repository.save(johnSmith);
        };
    }
}
