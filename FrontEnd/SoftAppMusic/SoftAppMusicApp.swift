//
//  SoftAppMusicApp.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/2/24.
//

import SwiftUI
import SwiftData

@main
struct SoftAppMusicApp: App {
    @StateObject private var appData = AppData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appData)
        }
        .modelContainer(for: [MasterSettingsModel.self])
    }
}
