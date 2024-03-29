//
//  NotificationsRequiredView.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 3/25/24.
//

import Foundation
import SwiftUI

func requetAuthorizationForNotifications() -> Bool {
    var currRequestAuthorized = false
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, _ in
        currRequestAuthorized = granted
    }
    return currRequestAuthorized
}

struct NotificationsRequiredView: View {
    
    var updateNotificationSettings: () -> Bool
    
    var body: some View {
        VStack {
            Text("Notifications are required to continue.")
                .font(.title)
            Button("Click to update Notification Settings") {
                updateNotificationSettings()
            }
        }
    }
    
}
