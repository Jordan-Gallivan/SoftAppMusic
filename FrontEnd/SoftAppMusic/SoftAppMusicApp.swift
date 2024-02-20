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

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [MasterSettingsModel.self])
    }
}
