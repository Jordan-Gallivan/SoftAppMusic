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
        
    @Published var musicTypes: MusicTypes = MusicTypes(genres: [])
    @Published var workoutTypes: [String] = []
    @Published var workoutMusicMatches: WorkoutMusicMatches? = nil
    
    func updateUserMusicPreferences(_ newMatches: WorkoutMusicMatches) {
        self.workoutMusicMatches = newMatches
    }
    
}
