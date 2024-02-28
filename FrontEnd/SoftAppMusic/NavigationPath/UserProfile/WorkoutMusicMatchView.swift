//
//  WorkoutMusicMatchView.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/27/24.
//

import Foundation
import SwiftUI

struct WorkoutMusicMatchView: View {
    // user profile data to be updated
    @Binding var workoutMusicMatches: WorkoutMusicMatches
    let musicTypes: [String]
    
    @State private var selectedWorkout: String? = nil
    // Binding set of selected music genres for the selected workout
    var selectedMusic: Binding<Set<String>> {
        Binding (
            get: { workoutMusicMatches.userPreferences[selectedWorkout ?? ""] ?? [] },
            set: {
                guard let selectedWorkout else {
                    return
                }
                workoutMusicMatches.userPreferences[selectedWorkout] = $0
            }
        )
    }

    
    var body: some View {
        HStack(spacing: 0) {
            List {
                ForEach(Array(workoutMusicMatches.userPreferences.keys), id: \.self) { workout in
                    HStack {
                        Text(workout)
                            .foregroundStyle(selectedWorkout == workout ? Color.white : Color.primary)
                        Spacer()
                    }
                    .contentShape(Rectangle())
                    .background(selectedWorkout == workout ? Color.accentColor : Color.clear)
                    .onTapGesture {
                        if selectedWorkout == workout {
                            selectedWorkout = nil
                        } else {
                            selectedWorkout = workout
                        }
                    }
                }
            } // end of list
            .listStyle(GroupedListStyle())
            
            Divider()
//                .frame(minWidth: 5.0)
//                .overlay(Color.gray)
 
            
            MultiSelectionView(
                options: musicTypes,
                optionToString: {"\($0)"},
                selected: selectedMusic)
            
        }
    }
}

extension String: Identifiable {
    public typealias ID = Int
    public var id: Int {
        return hash
    }
}
