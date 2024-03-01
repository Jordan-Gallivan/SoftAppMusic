package com.example.demo.User;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.example.demo.Preference.Preference;

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
                    "no",
                    "{\"workouts\": [\"HIIT\", \"Weight Lifting\", \"Powerlifting\", \"Sprints\", \"Bodyweight Exercises\", \"Distance Running\"], \"decades\": [\"90s\", \"80s\", \"70s\", \"60s\", \"2010s\", \"2000s\"], \"genres\": [\"Funk\", \"Techno\", \"Rap\", \"Rock\", \"Grunge\", \"Pop\"]}"
            );
            //repository.save(johnSmith);
        };
    }
}
