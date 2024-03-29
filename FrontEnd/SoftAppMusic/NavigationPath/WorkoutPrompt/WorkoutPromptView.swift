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
    }
    
    @EnvironmentObject private var appData: AppData
    @ObservedObject private var fetchUserData = FetchUserData()
    
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
        var musicChoices: [String] = appData.musicTypes.genres
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
            self.status = .loading
            Task {
                await buildWorkOutMusicMatches()
                self.status = .initialized
            }
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
    
    private func buildWorkOutMusicMatches() async {
        let workoutMusicMatches = await FetchMusicAndWorkoutMatches.fetchUserPreferences(email: appData.currentUserEmail, token: appData.currentToken)
        appData.workoutMusicMatches = workoutMusicMatches
    }
}
