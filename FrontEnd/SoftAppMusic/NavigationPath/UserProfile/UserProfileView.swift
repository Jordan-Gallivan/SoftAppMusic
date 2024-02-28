//
//  UserProfileView.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/26/24.
//

import Foundation
import SwiftUI

struct UserProfileView: View {
    var isCreatingUserProfile: Bool
    
    @EnvironmentObject private var appData: AppData
    @ObservedObject private var fetchUserData = FetchUserData()
    
    @State private var userProfileData = UserProfileData()
    @State private var workoutMusicMatches: WorkoutMusicMatches = WorkoutMusicMatches(workoutTypes: [])
    
    @State private var makeWorkoutMusicMatches = false
    
    var body: some View {
        VStack {
            switch fetchUserData.result {
            case .empty:
                EmptyView()
            case .inProgress(let page):
                LoadingView(pageName: page)
            case .success(_):
                // MARK: left off here
                VStack {
                    Form {
                        TextField("Email", text: $userProfileData.email)
                            .disabled(true)
                        TextField("First Name", text: $userProfileData.firstName)
                        TextField("Last Name", text: $userProfileData.lastName)
                        TextField("Age", text: $userProfileData.age)
                        
                        
                    }
                    
                    Button(action: {
                        makeWorkoutMusicMatches.toggle()
                    }, label: {
                        Text("Update Workout and Music Preferences")
                    })
                    .buttonStyle(
                        DefaultButtonStyling(buttonColor: Color.clear,
                                             borderColor: StyleConstants.DarkBlue,
                                             textColor: StyleConstants.DarkBlue))
                    Spacer()
                    
                    Button(action: {
                        if isCreatingUserProfile {
                            // MARK: navigate to app Main Screen
                        } else {
                            appData.viewPath.removeLast()
                        }
                    }, label: {
                        Text(isCreatingUserProfile ? "Get Moving" : "Save")
                    })
                    .buttonStyle(
                        DefaultButtonStyling(buttonColor: StyleConstants.DarkBlue,
                                             borderColor: StyleConstants.DarkBlue,
                                             textColor: Color.white))
                }
            case .failure(_):
                ErrorView(pageName: "User Profile")
            }
                
        }
        .navigationBarBackButtonHidden(isCreatingUserProfile)
        .task {
            // check if first time updating user profile
            if isCreatingUserProfile {
                userProfileData = fetchUserData.createUserRequest(email: appData.currentUserEmail)
                updateWorkoutsAndMusic(userPreferences: [:])
                return
            }                 
            
            // fetches current user data.  If unsuccessful, a default user profile is instantiated.
            userProfileData = await fetchUserData.fetchUserData(email: appData.currentUserEmail, token: appData.currentToken)
                                    ?? fetchUserData.createUserRequest(email: appData.currentUserEmail)
            
            // update current workout-music type matching if available
            if case .success(let successfulUserData) = fetchUserData.result {
                updateWorkoutsAndMusic(userPreferences: successfulUserData.workoutMusicMatches)
            } else {
                updateWorkoutsAndMusic(userPreferences: [:])
            }
        }
        .sheet(isPresented: $makeWorkoutMusicMatches) {
            WorkoutMusicMatchView(
                workoutMusicMatches: $workoutMusicMatches, 
                musicTypes: [appData.musicTypes.decades, appData.musicTypes.genres].flatMap { $0 })
            .presentationDetents([.medium])
        }
    }
    
    private func updateWorkoutsAndMusic(userPreferences: [String: [String]]) {
        appData.workoutTypes.forEach { workoutMusicMatches.userPreferences[$0] = [] }
        guard !userPreferences.isEmpty else { return }
        userPreferences.keys.forEach {
            workoutMusicMatches.userPreferences[$0] = Set(userPreferences[$0] ?? [])
        }
    }

}
