//
//  FetchMusicPreferences.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/5/24.
//

import Foundation

enum FetchMusicAndWorkoutMatches {
    
    /// Fetches Updated music types as MusicTypes Struct.  Expected JSON String from API:
    /// 
    /// `{"genres": ["genre1", "genre2", "genre3"] }`
    /// - Returns: MusicTypes Struct with updated genres if successful, otherwise nil.
    static func fetchUpdatedMusicTypes() async -> [String]? {
        do {
            let (data, urlResponse) = try await HTTPRequests.GET(urlString: "\(APIConstants.API_URL)/\(APIConstants.MUSIC_TYPES)", token: nil)
            guard HTTPRequests.validateHTTPResponseCode(urlResponse, errorString: "Fetch Music Types") else {
                return nil
            }
            NSLog("Music Types received: \(String(data: data, encoding: .utf8) ?? "UNABLE TO PARSE")")
            let updatedMusicTypes = try JSONDecoder().decode([String].self, from: data)
            return updatedMusicTypes
            
        } catch {
            NSLog("Error Fetching music types.  \(error.localizedDescription)")
            return nil
        }
    }
    

    
    /// Fetches Updated workout types.  Expected JSON:
    /// `{`
    /// `  "types": ["type1", "type2", "type3"]
    /// `}`
    /// - Returns: An array of workout types or nil if fetch is unsuccessful 
    static func fetchUpdatedWorkoutTypes() async -> [String]? {
        do {
            let (data, urlResponse) = try await HTTPRequests.GET(urlString: "\(APIConstants.API_URL)/\(APIConstants.WORKOUT_TYPES)", token: nil)
            guard HTTPRequests.validateHTTPResponseCode(urlResponse, errorString: "Fetch Workout Types") else {
                return nil
            }
            
            NSLog("Workout Types received: \(String(data: data, encoding: .utf8) ?? "UNABLE TO PARSE")")
            let updatedWorkoutTypes = try JSONDecoder().decode([String].self, from: data)
            return updatedWorkoutTypes
        } catch  {
            NSLog("Error Fetching workout types.  \(error.localizedDescription)")
            return nil
        }
    }
    
    
    /// Fetches User's workout and music preferences.  Expected JSON:
    /// `{
    /// `  "workoutType1": ["musicChoice1", "musicChoice2"],
    /// `  "workoutType2": ["musicChoice3", "musicChoice4"]
    /// `}`
    /// - Parameters:
    ///   - userEmail:
    ///   - token:
    /// - Returns: A WorkoutMusicMatches Struct if successful, otherwise nil.
    static func fetchUserPreferences(email: String, token: String) async -> WorkoutMusicMatches? {
        
        do {
            let (data, urlResponse) = try await HTTPRequests.GET(
                urlString: "\(APIConstants.API_URL)/\(APIConstants.USER_MUSIC_PREFERENCES(email: email))",
                token: token)
            
            // validate HTTP response code
            guard HTTPRequests.validateHTTPResponseCode(urlResponse, errorString: "Fetch Music Preferences") else {
                return nil
            }
            
            NSLog("Music Preferences received: \(String(data: data, encoding: .utf8) ?? "UNABLE TO PARSE")")
            // parse returned JSON
            let userPreferences = try JSONDecoder().decode([String:[String]].self, from: data)
            guard !userPreferences.isEmpty else {
                NSLog("ERROR fetching Musci Preferences.  Error parsing data, empty dictionary.")
                return nil
            }
            
            return WorkoutMusicMatches(existingWorkoutMusicMatches: userPreferences)
        } catch {
            NSLog("ERROR fetching user preferences.  \(error.localizedDescription)")
            return nil
        }
    }
    
    
    /// Converts WorkoutMusicMatches to a JSON encodable string and then puts to BE.
    /// JSON String example:
    /// `{ 
    /// `  "workoutType1": ["musicChoice1", "musicChoice2"],
    /// `  "workoutType2": ["musicChoice3", "musicChoice4"]
    /// `}`
    /// - Parameters:
    ///   - email: 
    ///   - matches: Struct containing updated workout to music Matches to be put
    ///   - token: current Token
    static func updateUserPreferences(email: String, matches: WorkoutMusicMatches, token: String) async -> Bool {
        // convert music preferences to dictionary {String : [String] }
        var jsonToBeEncoded: [String: [String]] = [:]
        for key in matches.userPreferences.keys {
            jsonToBeEncoded[key] = Array(matches.userPreferences[key]!)
        }

        do {
            let (_, urlResponse) = try await HTTPRequests.POST(
                urlString: "\(APIConstants.API_URL)/\(APIConstants.USER_MUSIC_PREFERENCES(email: email))",
                message: jsonToBeEncoded,
                token: token)
            guard HTTPRequests.validateHTTPResponseCode(urlResponse, errorString: "Post Music Preferences") else {
                return false
            }
        } catch {
            NSLog("ERROR posting Music Preferences.  JSON String: \(jsonToBeEncoded).  \(error.localizedDescription)")
            return false
        }
        NSLog("Music Preferences successfully updated.")
        return true
    }
}
