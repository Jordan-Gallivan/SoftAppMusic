package com.example.demo.Spotify;

import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpEntity;
import org.springframework.http.MediaType;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;

import java.util.List;

@Service
public class SpotifyService {

    private String accessToken;
    private final String clientId = "YOUR_CLIENT_ID";
    private final String clientSecret = "YOUR_CLIENT_SECRET";

    private RestTemplate restTemplate = new RestTemplate();

    public void authenticate() {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_FORM_URLENCODED);
        headers.setBasicAuth(clientId, clientSecret);

        MultiValueMap<String, String> map = new LinkedMultiValueMap<>();
        map.add("grant_type", "client_credentials");

        HttpEntity<MultiValueMap<String, String>> entity = new HttpEntity<>(map, headers);

        ResponseEntity<SpotifyTokenResponse> response = restTemplate.postForEntity("https://accounts.spotify.com/api/token", entity, SpotifyTokenResponse.class);

        this.accessToken = response.getBody().getAccessToken();
    }

    // Placeholder for SpotifyTokenResponse inner class
    // This class will be used to capture the JSON response from Spotify
    private static class SpotifyTokenResponse {
        private String access_token;
        private String token_type;
        private int expires_in;

        public String getAccessToken() {
            return access_token;
        }

        public String getTokenType() {
            return token_type;
        }

        public int getExpiresIn() {
            return expires_in;
        }

    }

    public List<Track> searchTracks(String query) {
        if (accessToken == null) {
            authenticate();
        }

        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(accessToken);
        HttpEntity<String> entity = new HttpEntity<>(headers);

        ResponseEntity<SpotifySearchResponse> response = restTemplate.exchange(
                "https://api.spotify.com/v1/search?q=" + query + "&type=track",
                HttpMethod.GET,
                entity,
                SpotifySearchResponse.class
        );

        return response.getBody().getTracks().getItems();
    }

    // Placeholder for SpotifySearchResponse and related inner classes
    // These classes will be used to capture the JSON response from Spotify
    private static class SpotifySearchResponse {
        private Tracks tracks;

        public Tracks getTracks() {
            return tracks;
        }
    }

    private static class Tracks {
        private List<Track> items;

        public List<Track> getItems() {
            return items;
        }
    }

    public static class Track {
        private String id;
        private String name;
        // other relevant fields

        // getters
        public String getId() {
            return id;
        }

        public String getName() {
            return name;
        }
    }

    // In the SpotifyService class
    public AudioFeatures fetchAudioFeatures(String trackId) {
        if (accessToken == null) {
            authenticate();
        }

        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(accessToken);
        HttpEntity<String> entity = new HttpEntity<>(headers);

        ResponseEntity<AudioFeatures> response = restTemplate.exchange(
                "https://api.spotify.com/v1/audio-features/" + trackId,
                HttpMethod.GET,
                entity,
                AudioFeatures.class
        );

        return response.getBody();
    }

    // Placeholder for AudioFeatures class
// This class will be used to capture the JSON response from Spotify
    public static class AudioFeatures {
        private float energy;
        // other audio features

        // getters
        public float getEnergy() {
            return energy;
        }
    }

}

