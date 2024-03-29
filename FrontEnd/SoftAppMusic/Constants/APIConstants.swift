//
//  APIConstants.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/13/24.
//

import Foundation

enum APIConstants {
    static let API_URL = "https://music-app-24st.onrender.com"
    static let LOGIN = "login"
    static let CREATE_LOGIN = "create_user_login"
    static let MUSIC_TYPES = "music_types"
    static let WORKOUT_TYPES = "workout_types"
    static let USER_PROFILE = "user_profile"
    static func INITIATE_WORKOUT_SESSION(email: String) -> String {
        return "init_session/\(email)"
    }
    static func USER_MUSIC_PREFERENCES(email: String) -> String {
        return "\(USER_PROFILE)/\(email)/music_preferences"
    }
    static func PUT_USER_PROFILE(email: String) -> String {
        return "\(USER_PROFILE)/\(email)"
    }
    
    
    static let WORKOUT_SESSION_SOCKET = ""
}

/*
 guard HTTPRequests.validateHTTPResponseCode(urlResponse, errorString: "Fetch Music Types") else {
     return nil
 }

 NSLog("Music Types received: \(String(data: data, encoding: .utf8) ?? "UNABLE TO PARSE")")

 */

