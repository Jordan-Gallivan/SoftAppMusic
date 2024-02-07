package com.example.demo.song;

import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class SongService {
    public List<Song> getSong() {
        return List.of(
                new Song(
                        "Never Gonna Give You Up",
                        "Rick Astley",
                        "Dance Pop"
                )
        );
    }
}
