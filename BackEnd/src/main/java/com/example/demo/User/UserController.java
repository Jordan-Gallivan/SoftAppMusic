package com.example.demo.User;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.google.gson.Gson;
import org.springframework.transaction.annotation.Transactional;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
public class UserController {

    private final UserService userService;

    @Autowired
    public UserController(UserService usersService) {
        this.userService = usersService;
    }

    @GetMapping
    public List<User> getUser() { return userService.getUser(); }

    @PostMapping(path = "/create_user_login")
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

    @PostMapping(path = "/login")
    public ResponseEntity<?> loginUser(@RequestBody User user) {
        boolean isAuthenticated = userService.authenticateUser(user);
        if (isAuthenticated) {
            Map<String, String> response = Collections.singletonMap("token", "authenticated");
            return ResponseEntity.ok(response);
        } else {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid username or password");
        }
    }
    
	@Transactional(readOnly = true)
    @GetMapping(path = "user_profile/{username}/music_preferences")
    @SuppressWarnings("unchecked")
    public ResponseEntity<?> getUserMusicPreferences(@PathVariable String username) {
    	try {
			User user = userService.getUserByUsername(username);
			Map<String, Map<String, Boolean>> userPreferences = new Gson().fromJson(user.getUserPreferenceSettingsJson(), Map.class);
			
			return ResponseEntity.ok(userPreferences);
    	} catch (IllegalStateException e) {
    	    return ResponseEntity.status(HttpStatus.CONFLICT).body("User does not exist");
		}
    }
	
	@Transactional(readOnly = true)
    @GetMapping(path = "user_profile/{username}")
    public ResponseEntity<?> getUserProperties(@PathVariable String username) {
    	try {
			User user = userService.getUserByUsername(username);
			HashMap<String, String> userProperties = new HashMap<>();
            userProperties.put("userEmail", user.getUserEmail());
			userProperties.put("firstName", user.getFirstName());
			userProperties.put("lastName", user.getLastName());
			userProperties.put("age", String.valueOf(user.getAge()));
			userProperties.put("spotifyConsent", user.getSpotifyConsent());
			
			return ResponseEntity.ok(userProperties);
    	} catch (IllegalStateException e) {
    	    return ResponseEntity.status(HttpStatus.CONFLICT).body("User does not exist");
		}
    }

    @PostMapping(path = "user_profile/{username}")
    public ResponseEntity<?> updateUserProperties(@PathVariable String username, @RequestBody String updates) {
        System.out.println(username);
        try {
            // persist changes using userService
            userService.updateUser(username, updates);

            // confirmation message
            return ResponseEntity.ok("User profile updated successfully");

        } catch (IllegalStateException e) {
            return ResponseEntity.status(HttpStatus.CONFLICT).body("User does not exist || " + e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body("Invalid request");
        }
    }
    
    @PostMapping(path = "user_profile/{username}/music_preferences")
    public  ResponseEntity<?>  updateUserMusicPreferences(@PathVariable String username, @RequestBody String userPreferenceSettingsJson) {
    	try {
        	userService.updateUserMusicPreferences(username, userPreferenceSettingsJson);
        	return ResponseEntity.ok("Updated user preferences");
    	} catch (IllegalStateException e) {
    		return ResponseEntity
                    .status(HttpStatus.CONFLICT)
                    .body(e.getMessage());
		}
    }
}
