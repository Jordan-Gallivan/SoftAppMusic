//
//  WorkoutMusicMatches.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/26/24.
//

import Foundation

struct WorkoutMusicMatches: Codable {
    var userPreferences: [String: Set<String>]
    var isEmpty: Bool { return userPreferences.isEmpty }
    
    init(workoutTypes: [String]) {
        userPreferences = [:]
        workoutTypes.forEach { userPreferences[$0] = [] }
    }
    
    init(existingWorkoutMusicMatches matches: [String: [String]]) {
        userPreferences = [:]
        for key in matches.keys {
            userPreferences[key] = Set(matches[key] ?? [])
        }
    }
}
