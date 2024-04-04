//
//  APIConstants.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/13/24.
//

import Foundation

enum APIConstants {
    static let API_URL = "https://soft-music-app.onrender.com"
    static let LOGIN = "login"
    static let CREATE_LOGIN = "create_user_login"
    static let MUSIC_TYPES = "music_types"
    static let MUSIC_PREFERENCES = "music_preferences"
    static let WORKOUT_TYPES = "workout_types"
    static let USER_PROFILE = "user_profile"
    static let SPOTIFY = "spotify_credentials"
    static func AUTH_WEBSOCKET(email: String) -> String {
        return "\(API_URL)/init_session/\(email)/auth"
    }
    static func INITIATE_WORKOUT_SESSION(email: String, token: String) -> String {
         "wss://soft-music-app.onrender.com/init_session/\(email)?token=\(token)"
    }
    static func USER_MUSIC_PREFERENCES(email: String) -> String {
        return "\(USER_PROFILE)/\(email)/\(MUSIC_PREFERENCES)"
    }
    static func PUT_USER_PROFILE(email: String) -> String {
        return "\(USER_PROFILE)/\(email)"
    }
    
    static func SPOTIFY_CREDENTIALS(email: String) -> String {
        return "\(USER_PROFILE)/\(email)/\(SPOTIFY)"
    }
    
    static let WORKOUT_SESSION_SOCKET = ""
}

/*
 guard HTTPRequests.validateHTTPResponseCode(urlResponse, errorString: "Fetch Music Types") else {
     return nil
 }

 NSLog("Music Types received: \(String(data: data, encoding: .utf8) ?? "UNABLE TO PARSE")")

 */

