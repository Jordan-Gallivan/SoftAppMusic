package com.example.demo.User;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import org.springframework.transaction.annotation.Transactional;

import com.example.demo.Preference.Preference;
import com.google.gson.Gson;
import com.google.gson.JsonSyntaxException;

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
    	if(userOptional.isEmpty()) {
    		throw new IllegalStateException("Find user exception: User does not exist");
        }
		return userOptional.get();
    }
    
    @SuppressWarnings("unchecked")
	@Transactional
    public void updateUser(String username, String updatedUserInfo) {
    	// use this to update non-preference related settings, such as spotifyConsent, email, etc,.
    	return;
    }
    
    @SuppressWarnings("unchecked")
	@Transactional
    public void updateUserMusicPreferences(String username, String userPreferenceSettingsJson) {
    	Optional<User> userOptional = userRepository.findUserByUsername(username);
        if(userOptional.isEmpty()) {
            throw new IllegalStateException("Attempting to update User which does not exist");
        }
        
        Gson gson = new Gson();
        User user = userOptional.get();
        Map<String, List<String>> userPreferences = null;
        
        // try/catch to verify JSON is in proper format
        try {
            userPreferences = gson.fromJson(userPreferenceSettingsJson, Map.class);
    	} catch (JsonSyntaxException e) {
        	throw new IllegalStateException("Invalid JSON format provided.");
    	}
        
        // verify only allowed music and workout types are provided with JSON
        try {
            List<String> workoutType = Preference.getWorkoutType();
            List<String> musicType = Preference.getMusicType();
            List<String> musicPreferenceList;
            for (Map.Entry<String, List<String>> workoutMusicPreference : userPreferences.entrySet()) {
               if (!workoutType.contains(workoutMusicPreference.getKey())) {
            	   throw new Exception("Invalid workout types provided.");
               }
               try {
            	   musicPreferenceList = workoutMusicPreference.getValue();
               } catch (Exception e) {
            	   throw new Exception("Format does not conform to HashMap<String, List<String>>.");
               }
               
        	   for (String musicPreference : musicPreferenceList) {
        		   if (!musicType.contains(musicPreference)) {
        			   throw new Exception("Invalid music types provided.");
        		   }
        	   }

           }
        } catch (Exception e) {
        	throw new IllegalStateException(e.getMessage());
        }
        
		// Should we allow empty preference JSON?
    	if (userPreferences == null || userPreferences.size() == 0) {
    		throw new IllegalStateException("Provided JSON Array is empty.");
    	}
    	
		user.setUserPreferences(userPreferences);
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
