package com.example.demo.User;

import java.util.List;
import java.util.Map;

import com.example.demo.Preference.*;
import com.google.gson.Gson;

import jakarta.persistence.*;

@Entity
@Table(name = "app_user")
public class User {
	@Id
	@SequenceGenerator(name = "user_sequence", sequenceName = "user_sequence", allocationSize = 1)

	private String username;
	private String firstName;
	private String lastName;
	private String userEmail;
	private String password;
	private String spotifyConsent;
	
	@Lob
	// Better? option is to have separate table for user preferences instead of serializing as JSON
	private String userPreferenceSettingsJson;
	@Transient
	private Map<String, List<String>> userPreferences;
	//private Map<String, Map<String, Boolean>> userPreferenceSettings;

	@SuppressWarnings("unchecked")
	public User(String username, String firstName, String lastName, String userEmail, String password,
			String spotifyConsent, String userPreferenceSettingsJson) {
		this.username = username;
		this.firstName = firstName;
		this.lastName = lastName;
		this.userEmail = userEmail;
		this.password = password;
		this.spotifyConsent = spotifyConsent;
		// should parse and validate JSON before setting it
		this.userPreferenceSettingsJson = userPreferenceSettingsJson;
		this.userPreferences = new Gson().fromJson(userPreferenceSettingsJson, Map.class);
	}

	public User() {

	}

	public Map<String, List<String>>  getUserPreferences() {
		return userPreferences;
	}

	public void setUserPreferences(Map<String, List<String>>  userPreferences) {
		this.userPreferences = userPreferences;
	}
	
	public String getUserPreferenceSettingsJson() {
		return userPreferenceSettingsJson;
	}

	public void setUserPreferenceSettingsJson(String userPreferenceSettingsJson) {
		this.userPreferenceSettingsJson = userPreferenceSettingsJson;
	}

	public String getSpotifyConsent() {
		return spotifyConsent;
	}

	public void setSpotifyConsent(String spotifyConsent) {
		this.spotifyConsent = spotifyConsent;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public String getUserEmail() {
		return userEmail;
	}

	public void setUserEmail(String userEmail) {
		this.userEmail = userEmail;
	}

	public String getLastName() {
		return lastName;
	}

	public void setLastName(String lastName) {
		this.lastName = lastName;
	}

	public String getFirstName() {
		return firstName;
	}

	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}

	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}
}
