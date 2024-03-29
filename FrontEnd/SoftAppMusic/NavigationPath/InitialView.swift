//
//  InitialView.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 3/26/24.
//

import Foundation
import SwiftData
import SwiftUI

struct InitialView: View {
    @EnvironmentObject private var appData: AppData
    @Environment(\.modelContext) var dbContext
    @Query var masterSettingsModel: [MasterSettingsModel]
    
//    private func querySettings() async {
//        print("This function is called")
//        if masterSettingsModel.isEmpty {
//            dbContext.insert(MasterSettingsModel())
//        } else if !masterSettingsModel.first!.userProfileCreated {
////                appData.viewPath.append(CreateUserProfileView())
//        }
//#warning("add logic to determine if saved login")
//        
//        let updatedWorkoutTypes = await FetchWorkoutTypes.fetchUpdatedWorkoutTypes()
//        appData.workoutTypes = updatedWorkoutTypes ?? masterSettingsModel.first!.previousWorkoutTypes
//        
//        let updatedMusicTypes = await FetchMusicTypes.fetchUpdatedMusicTypes()
//        appData.musicTypes = updatedMusicTypes ?? masterSettingsModel.first!.previousMusicTypes
//
//    }
    
    var body: some View {
        NavigationStack(path: $appData.viewPath) {
            VStack {
                if masterSettingsModel.first!.userProfileCreated {
                    LoginView()
                        
                } else {
                    CreateUserLoginView()
                }
            }
            .navigationDestination(for: NavigationViews.self) { destination in
                switch destination {
                case .loginView:
                    LoginView()
                case .createLoginView:
                    CreateUserLoginView()
                case .userProfileView(let createUserProfile):
                    UserProfileView(isCreatingUserProfile: createUserProfile)
                case .workoutPormpt:
                    WorkoutPromptView()
                case .workoutView(workoutType: let workoutType, musicType: let musicType):
                    WorkoutView(workoutType: workoutType, musicType: musicType)
                }
            }
        }
//        .onAppear {
//            if masterSettingsModel.isEmpty {
//                dbContext.insert(MasterSettingsModel())
//            } else if !masterSettingsModel.first!.userProfileCreated {
////                appData.viewPath.append(CreateUserProfileView())
//            }
//#warning("add logic to determine if saved login")
//
//            Task {
//                let updatedWorkoutTypes = await FetchWorkoutTypes.fetchUpdatedWorkoutTypes()
//                appData.workoutTypes = updatedWorkoutTypes ?? masterSettingsModel.first!.previousWorkoutTypes
//
//                let updatedMusicTypes = await FetchMusicTypes.fetchUpdatedMusicTypes()
//                appData.musicTypes = updatedMusicTypes ?? masterSettingsModel.first!.previousMusicTypes
//            }
//        }
        
    }
}
