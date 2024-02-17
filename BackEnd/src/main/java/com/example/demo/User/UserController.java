package com.example.demo.User;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RequestMapping(path = "user")
@RestController
public class UserController {

    private final UserService userService;

    @Autowired
    public UserController(UserService usersService) {
        this.userService = usersService;
    }

    @GetMapping
    public List<User> getUser() { return userService.getUser(); }

    @PostMapping(path = "create_user_login")
    public ResponseEntity<?> createNewUser(@RequestBody User user) {
        try {
            userService.addNewUser(user);
            return new ResponseEntity<>(HttpStatus.CREATED);
        } catch (IllegalStateException e) {
            return ResponseEntity
                    .status(HttpStatus.CONFLICT)
                    .body(e.getMessage());
        }
    }
}
