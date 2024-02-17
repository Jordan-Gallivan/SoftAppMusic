package com.example.demo.User;

import jakarta.persistence.*;

@Entity
@Table(name = "app_user")
public class User {
    @Id
    @SequenceGenerator(
            name = "user_sequence",
            sequenceName = "user_sequence",
            allocationSize = 1
    )

    private String username;
    private String firstName;
    private String lastName;
    private String userEmail;
    private String password;
    private String spotifyConsent;

    public User(String username, String firstName, String lastName, String userEmail, String password, String spotifyConsent) {
        this.username = username;
        this.firstName = firstName;
        this.lastName = lastName;
        this.userEmail = userEmail;
        this.password = password;
        this.spotifyConsent = spotifyConsent;
    }

    public User() {

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
