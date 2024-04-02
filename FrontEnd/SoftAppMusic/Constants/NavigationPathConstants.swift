//
//  NavigationPathConstants.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/20/24.
//

import Foundation

enum NavigationViews: Hashable {
    case loginView
    case createLoginView
    case userProfileView(createUserProfile: Bool, invalidCredentials: Bool = false)
    case workoutPormpt(initialUse: Bool)
    case workoutView(workoutType: String, musicType: String)
}
