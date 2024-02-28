//
//  ContentView.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/2/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @EnvironmentObject private var appData: AppData
    @Environment(\.modelContext) var dbContext
    @Query var masterSettingsModel: [MasterSettingsModel]
    
    var body: some View {
        NavigationStack(path: $appData.viewPath) {
            Group {
                if masterSettingsModel.first!.userProfileCreated {
                    LoginView()
                } else {
                    CreateUserLoginView()
                }
            }
            .navigationDestination(for: String.self) { destination in
                if destination == "user profile create" {
                    UserProfileView(isCreatingUserProfile: true)
                } else if destination == "user profile" {
                    UserProfileView(isCreatingUserProfile: false)
                }
            }
        }
        .onAppear {
            if masterSettingsModel.isEmpty {
                dbContext.insert(MasterSettingsModel())
            } else if !masterSettingsModel.first!.userProfileCreated {
//                appData.viewPath.append(CreateUserProfileView())
            }
            // MARK: add logic to determine if saved login
            
            Task {
                let updatedWorkoutTypes = await FetchWorkoutTypes.fetchUpdatedWorkoutTypes()
                appData.workoutTypes = updatedWorkoutTypes ?? masterSettingsModel.first!.previousWorkoutTypes
                
                let updatedMusicTypes = await FetchMusicTypes.fetchUpdatedMusicTypes()
                appData.musicTypes = updatedMusicTypes ?? masterSettingsModel.first!.previousMusicTypes
            }
        }
        
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
