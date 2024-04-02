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
    var previousMusicTypes: [String] = []
    
    // Workout Types
    var previousWorkoutTypes: [String] = []
    
    // Workout to Music Matches
    var previousWorkoutMusicMatches: WorkoutMusicMatches = WorkoutMusicMatches(workoutTypes: [])
    
    init() {
        self.setDefaults()
    }
    
    func setDefaults() {
        self.previousMusicTypes = self.defaultMusicTypes()
        self.previousWorkoutTypes = ["HIIT", "Tempo Run", "Long Run", "WeightLifting"]
    }
    
    func defaultMusicTypes() -> [String] {
        return ["rock", "pop", "rap", "punk"]
    }
    
    func defaultWorkoutTypes() -> [String] {
        return ["HIIT", "Tempo Run", "Long Run", "WeightLifting"]
    }
}
