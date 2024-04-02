//
//  ApplicationData.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/13/24.
//

import Foundation
import SwiftUI

class AppData: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    // Navigation Path
    @Published var viewPath = NavigationPath()
    
    // current user email
    @Published var currentUserEmail: String = ""
    @Published var currentToken: String = ""
        
    @Published var musicTypes: [String] = []
    @Published var workoutTypes: [String] = []
    @Published var workoutMusicMatches: WorkoutMusicMatches? = nil
    @Published var validSpotifyConsent: Bool = false
    
    func updateUserMusicPreferences(_ newMatches: WorkoutMusicMatches) {
        self.workoutMusicMatches = newMatches
    }
    
    func setDefaults() -> ([String], [String]) {
        let musicTypes = ["rock", "pop", "rap", "punk"]
        let workoutTypes = ["HIIT", "Tempo Run", "Long Run", "WeightLifting"]
        self.musicTypes = musicTypes
        self.workoutTypes = workoutTypes
        return (musicTypes, workoutTypes)
    }
}
