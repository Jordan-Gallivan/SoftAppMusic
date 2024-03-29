//
//  InitialView.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 3/26/24.
//

import Foundation
import SwiftData
import SwiftUI


/// Builds Navigation Path and routes initial View to either Login or Create Login View
struct InitialView: View {
    @EnvironmentObject private var appData: AppData
    @Environment(\.modelContext) var dbContext
    @Query var masterSettingsModel: [MasterSettingsModel]
       
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
    }
}
