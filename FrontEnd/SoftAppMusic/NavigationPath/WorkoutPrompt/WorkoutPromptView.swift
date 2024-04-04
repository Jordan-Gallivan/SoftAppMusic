//
//  WorkoutPrompt.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 3/4/24.
//

import Foundation
import SwiftUI

struct WorkoutPromptView: View {
    private enum Status {
        case loading
        case initialized
        case invalidTosConsent
    }
    
    @EnvironmentObject private var appData: AppData
    @ObservedObject private var fetchUserData = FetchUserData()
    private var initialUse: Bool
    
    @State private var status: Status = .loading
    
    @State private var selectedWorkout: String = ""
    @State private var selectedMusic: String = ""
    private var matchesForSelectedWorkout: Set<String> {
        guard let workoutMusicMatches = appData.workoutMusicMatches?.userPreferences,
              let matchesForSelectedWorkout = workoutMusicMatches[selectedWorkout] else {
            return []
        }
        return matchesForSelectedWorkout
    }
    
    init(initialUse: Bool) {
        self.initialUse = initialUse
    }
    
    // computed property prompt for view
    private var whatAreYouFeelingString: String {
        if selectedWorkout.contains("Run") {
            return "What Type of music are you feeling for a \(selectedWorkout)?"
        } else {
            return "What Type of music are you feeling for \(selectedWorkout)?"
        }
    }
    
    // computed property that updates the available music choices by sorting user prefered choices at the top of the list
    private var musicChoices: [String] {
        var musicChoices: [String] = appData.musicTypes
        // validate user has workoutMusic match preferences
        guard let workoutMusicMatches = appData.workoutMusicMatches?.userPreferences,
              let matchesForSelectedWorkout = workoutMusicMatches[selectedWorkout] else {
            return musicChoices
        }
        
        // move matched music to top of list
        var swapIndex = 0
        for i in 0..<musicChoices.count {
            if matchesForSelectedWorkout.contains(musicChoices[i]) {
                musicChoices.swapAt(i, swapIndex)
                swapIndex += 1
            }
        }
        return musicChoices
        
    }
    
    var body: some View {
        Group {
            switch self.status {
            case .loading:
                LoadingView(prompt: "Gathering preferences")
            case .invalidTosConsent:
                VStack {
                    Text("No valid Spotify Credentials.  Please update below")
                }
                Button("Update Profile") {
                    appData.viewPath.append(NavigationViews.userProfileView(createUserProfile: false, invalidCredentials: true))
                }
            case .initialized:
                VStack {
                    Spacer()
                    Text("What Type of Workout are you doing today?")
                        .font(.title)
                        .multilineTextAlignment(.center)
                    Picker("Workouts", selection: $selectedWorkout) {
                        ForEach(appData.workoutTypes, id: \.self) {
                            Text($0)
                        }
                    }
                    if !selectedWorkout.isEmpty {
                        Text(whatAreYouFeelingString)
                            .font(.title)
                            .multilineTextAlignment(.center)
                        Picker("Music", selection: $selectedMusic) {
                            ForEach(musicChoices, id: \.self) { music in
                                HStack {
                                    if matchesForSelectedWorkout.contains(music) {
                                        Image(systemName: "star")
                                            .symbolRenderingMode(.palette)
                                            .foregroundStyle(.yellow)
                                    }
                                    Text(music)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    Spacer()
                    if !selectedWorkout.isEmpty && !selectedMusic.isEmpty {
                        Button("Let's Move") {
                            NSLog("Navigatingn to workout view")
                            appData.viewPath.append(NavigationViews.workoutView(workoutType: selectedWorkout, musicType: selectedMusic))
                        }
                        .buttonStyle(DefaultButtonStyling(buttonColor: StyleConstants.DarkBlue, borderColor: StyleConstants.DarkBlue, textColor: .white))
                    }
                }
            }
        }
        .onAppear {
            Task { await self.initializeWorkoutPrompt() }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    appData.viewPath.append(NavigationViews.userProfileView(createUserProfile: false))
                }, label: {
                    Image(systemName: "gearshape")
                })
            }
        }
    }
    
    private func initializeWorkoutPrompt() async  -> Bool{
        self.status = .loading
        
        if !self.initialUse {
            guard await verifyTosConset() else {
                self.status = .invalidTosConsent
//                appData.viewPath.append(NavigationViews.userProfileView(createUserProfile: false, invalidCredentials: true))
                return false
            }
        }
        
        await buildWorkOutMusicMatches()
        self.status = .initialized
        return true
    }
    
    private func buildWorkOutMusicMatches() async {
        NSLog("Populating workout/music matches")
        if appData.workoutMusicMatches != nil {
            NSLog("Initial or recently updated matches.  Populating from AppData")
            return
        }
        let workoutMusicMatches = await FetchMusicAndWorkoutMatches.fetchUserPreferences(email: appData.currentUserEmail, token: appData.currentToken)
        if workoutMusicMatches == nil {
            NSLog("Failure fetching workout/music matches.  Initializing options to nil.")
        } else {
            NSLog("Success fetching workout/music matches.")
        }
        appData.workoutMusicMatches = workoutMusicMatches
        self.status = .initialized
    }
    
    private func verifyTosConset() async -> Bool {
        NSLog("Validating Spotify Login")
        if appData.validSpotifyConsent {
            NSLog("Spotify Login validated - initial app usage")
            return true
        }
        let profileData = await fetchUserData.fetchUserData(email: appData.currentUserEmail, token: appData.currentToken)
        
        guard let profileData, profileData.spotifyConsent else {
            NSLog("Invalid Spotify credentials")
            return false
        }
        appData.validSpotifyConsent = true
        NSLog("Valid Spotify credentials")
        return true
    }
}
