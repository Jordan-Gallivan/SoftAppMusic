package com.example.demo.User;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import org.springframework.transaction.annotation.Transactional;

import com.google.gson.Gson;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class UserService {

   private final UserRepository userRepository;

   @Autowired
    public UserService(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public List<User> getUser() {
        return userRepository.findAll();
    }
    
    public User getUserByUsername(String username) {
    	Optional<User> userOptional = userRepository.findUserByUsername(username);
    	if(!userOptional.isPresent()) {
    		throw new IllegalStateException("Find user exception: User does not exist");
        }
		return userOptional.get();
    }
    
    @SuppressWarnings("unchecked")
	@Transactional
    public void updateUser(String username, String userPreferenceSettingsJson) {
    	Optional<User> userOptional = userRepository.findUserByUsername(username);
        if(!userOptional.isPresent()) {
            throw new IllegalStateException("Attempting to update User which does not exist");
        }
        Gson gson = new Gson();
        User user = userOptional.get();
        Map<String, List<String>> providedUserPreferences;
        Map<String, List<String>> validUserPreferences = new HashMap<String, List<String>>();
        Map<String, List<String>> existingUserPreferences = gson.fromJson(userPreferenceSettingsJson, Map.class);
        List<String> existingUserWorkoutPreferences = existingUserPreferences.get("workouts");
        try {
        	providedUserPreferences = gson.fromJson(userPreferenceSettingsJson, Map.class);
        	if (providedUserPreferences == null) {
        		throw new IllegalStateException("Improper or empty JSON provided");
        	} else {
        		// only update music preferences if decades and genres lists were provided
        		List<String> decadePreferences = providedUserPreferences.get("decades");
        		List<String> genrePreferences = providedUserPreferences.get("genres");
        		if (decadePreferences != null && genrePreferences != null) {
        			validUserPreferences.put("decades", decadePreferences);
        			validUserPreferences.put("genres", genrePreferences);
        			
        			// don't overwrite workout preferences when setting music preferences
        			if (existingUserWorkoutPreferences != null) {
        				validUserPreferences.put("workouts",  existingUserWorkoutPreferences);
        			}
        		}
        	}
        } catch (IllegalStateException e){
        	throw new IllegalStateException("Improper or empty JSON provided");
        }
        
		user.setUserPreferences(validUserPreferences);
		user.setUserPreferenceSettingsJson(gson.toJson(user.getUserPreferences(), Map.class));
    }

    public void addNewUser(User user) {
       Optional<User> userOptional = userRepository.findUserByUsername(user.getUsername());
       if(userOptional.isPresent()) {
           throw new IllegalStateException("Username Taken");
       }
       userRepository.save(user);
    }

    public boolean authenticateUser(User user) {
        Optional<User> userOptional = userRepository.findUserByUsername(user.getUsername());
        if(userOptional.isPresent()) {
            User request = userOptional.get();
            return request.getPassword().equals(user.getPassword());
        }
        return false;
    }
}
