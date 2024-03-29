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
            case .inProgress(_):
                LoadingView(prompt: "Gather Profile Information")
            case .success(let userProfileData):
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
                        Task {
                            guard await updateUserData() else { return }
                            appData.updateUserMusicPreferences(workoutMusicMatches)
                            if isCreatingUserProfile {
                                appData.viewPath.append(NavigationViews.workoutPormpt)
                            } else {
                                appData.viewPath.removeLast()
                            }
                        }
                    }, label: {
                        Text(isCreatingUserProfile ? "Get Moving" : "Save")
                    })
                    .buttonStyle(
                        DefaultButtonStyling(buttonColor: StyleConstants.DarkBlue,
                                             borderColor: StyleConstants.DarkBlue,
                                             textColor: Color.white))
                }
                .onAppear {
                    Task { await self.initializeUserData() }
                }
            case .failure(_):
                ErrorView(pageName: "User Profile") {
                    await initializeUserData()
                }
            }
                
        }
        .navigationBarBackButtonHidden(isCreatingUserProfile)
        .task {
            await initializeUserData()
        }
        .sheet(isPresented: $makeWorkoutMusicMatches) {
            VStack {
                WorkoutMusicMatchView(
                    workoutMusicMatches: $workoutMusicMatches,
                    musicTypes: appData.musicTypes.genres)
                
                Button("Save") { makeWorkoutMusicMatches.toggle() }
                    .buttonStyle(DefaultButtonStyling(buttonColor: StyleConstants.DarkBlue, borderColor: StyleConstants.DarkBlue, textColor: Color.white))
            }
            .presentationDetents([.medium])
        }
    }
    
    private func initializeUserData() async {
        // check if first time updating user profile
        if isCreatingUserProfile {
            userProfileData = fetchUserData.createUserRequest(email: appData.currentUserEmail)
            populateMusicPreferences(userPreferences: [:])
            return
        }
        
        // fetches current user data.  If unsuccessful, a default user profile is instantiated.
        var profileData = await fetchUserData.fetchUserData(email: appData.currentUserEmail, token: appData.currentToken)
        
        if profileData == nil {
            NSLog("Unable to fetch user profile data.  Creating Empty Profile")
        }
        userProfileData = profileData ?? fetchUserData.createUserRequest(email: appData.currentUserEmail)
        
        
        let music = await FetchMusicAndWorkoutMatches.fetchUserPreferences(email: appData.currentUserEmail, token: appData.currentToken)
        if music == nil {
            NSLog("Unable to fetch music preferences.  Creating Empty Music Matches")
        }
        
        // update music preferences
        populateMusicPreferences(userPreferences: music?.userPreferences ?? [:])
        
        NSLog("Profile and Music Preferences Successfully Loaded")
    }
    
    private func populateMusicPreferences(userPreferences: [String: Set<String>]) {
        // pull workout types
        appData.workoutTypes.forEach { workoutMusicMatches.userPreferences[$0] = [] }
        
        guard !userPreferences.isEmpty else { return }
        userPreferences.keys.forEach {
            workoutMusicMatches.userPreferences[$0] = Set(userPreferences[$0] ?? [])
        }
    }
    
    private func updateUserData() async -> Bool {
        guard await fetchUserData.updateUserData(
            userProfileData: userProfileData,
            email: userProfileData.email,
            token: appData.currentToken)
        else {
            NSLog("Unable to update profile data")
            return false
        }
        NSLog("Profile successfully updated.")
        
        guard await FetchMusicAndWorkoutMatches.updateUserPreferences(
            email: appData.currentUserEmail,
            matches: workoutMusicMatches,
            token: appData.currentToken)
        else {
            NSLog("Unable to update Music Preferences")
            return false
        }
        NSLog("Music Preferences successfully updated.")

        return true
    }

}
