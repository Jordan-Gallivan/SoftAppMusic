//
//  UserSettingsModel.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/16/24.
//

import Foundation
import SwiftData

@Model
class MasterSettingsModel: Identifiable {
    // Identifiable
    var id: UUID = UUID()
    
    // Application Settings
    var userProfileCreated: Bool = false
    var stayLoggedIn: Bool = false
    var token: String = ""
    
    // Music Types
    var previousMusicTypes: MusicTypes = MusicTypes(decades: [], genres: [])
    
    // Workout Types
    var previousWorkoutTypes: [String] = []
    
    // Workout to Music Matches
    var previousWorkoutMusicMatches: WorkoutMusicMatches = WorkoutMusicMatches(workoutTypes: [])
    
    init() { }
    
    func setDefaults() {
        self.previousMusicTypes = MusicTypes(decades: ["1980s", "1990s", "2000s", "2010s", "2020s"], genres: ["rock", "pop", "rap", "punk"])
        self.previousWorkoutTypes = ["HIIT", "Tempo Run", "Long Run", "WeightLifting"]
    }
}
