package com.example.demo.song;

public class Song {
    private String title;
    private String artist;
    private String genre;

    public Song(String title, String artist, String genre) {
        this.title = title;
        this.artist = artist;
        this.genre = genre;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getArtist() {
        return artist;
    }

    public void setArtist(String title) {
        this.artist = artist;
    }

    public String getGenre() {
        return genre;
    }

    public void setGenre(String title) {
        this.genre = genre;
    }

    @Override
    public String toString() {
        return "Song{" +
                "title=" + title + '\n' +
                ", artist='" + artist + '\n' +
                ", genre='" + genre + '\n' +
                '}';
    }
}
