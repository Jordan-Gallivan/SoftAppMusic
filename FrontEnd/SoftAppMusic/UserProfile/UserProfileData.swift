//
//  UserProfileData.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/5/24.
//

import Foundation

struct UserProfileData: Codable {
    private var userEmail: String = ""
    var email: String { return userEmail }
    var password: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var spotifyConsent: Bool = false
    
    mutating func setEmail(_ newEmail: String) -> Bool {
        if newEmail.firstMatch(of: EmailRegex)?.count == 0 {
            return false
        }
        self.userEmail = newEmail
        return true
    }
}
