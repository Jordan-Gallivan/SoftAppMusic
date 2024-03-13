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
                    "{\"Long Run High\" : [\"Rock\", \"Rap\", \"Pop\"], \"Long Run Mid\" : [\"Rock\"], \"Long Run Low\" : [\"Rap\", \"Pop\", \"Electro\"], \"Sprint High\" : [\"Rock\", \"Rap\", \"Electro\"], \"Sprint Low\" : [\"Electro\"], \"HIIT High\" : [\"Rock\", \"Rap\", \"Pop\", \"Electro\"], \"HITT Low\" : [\"Rap\", \"Electro\"]}"
            );
            repository.save(johnSmith);
        };
    }
}
