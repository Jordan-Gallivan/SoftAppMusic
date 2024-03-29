//
//  ContentView.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/2/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    private enum status {
        case loading
        case initialized
    }
    
    @EnvironmentObject private var appData: AppData
    @Environment(\.modelContext) private var dbContext
    @Query private var masterSettingsModel: [MasterSettingsModel]
    @State private var status: status = .loading
    
        
    var body: some View {
        VStack {
            switch self.status {
            case .loading:
                LoadingView(prompt: "Initializing Application")
            case .initialized:
                InitialView()
            }
        }
        .onAppear {
            self.status = .loading
            if masterSettingsModel.isEmpty {
                dbContext.insert(MasterSettingsModel())
            } else if !masterSettingsModel.first!.userProfileCreated {
//                appData.viewPath.append(CreateUserProfileView())
            }
#warning("add logic to determine if saved login")

            Task {
                let updatedWorkoutTypes = await FetchMusicAndWorkoutMatches.fetchUpdatedWorkoutTypes()
                appData.workoutTypes = updatedWorkoutTypes ?? masterSettingsModel.first!.previousWorkoutTypes

                let updatedMusicTypes = await FetchMusicAndWorkoutMatches.fetchUpdatedMusicTypes()
                appData.musicTypes = updatedMusicTypes ?? masterSettingsModel.first!.previousMusicTypes
                
            }
            self.status = .initialized
        }        
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
