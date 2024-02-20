//
//  ContentView.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/2/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) var dbContext
    @Query var masterSettingsModel: [MasterSettingsModel]
    
    var body: some View {
        Group {
            LoginView()
        }
        .onAppear {
            if masterSettingsModel.isEmpty {
                dbContext.insert(MasterSettingsModel())
            }
            // MARK: add logic to determine if saved login
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
