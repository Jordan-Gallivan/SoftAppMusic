//
//  UserSettingsModel.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/16/24.
//

import Foundation
import SwiftData

@Model
class MasterSettingsModel: Identifiable {
    // MARK: Identifiable
    var id: UUID = UUID()
    
    // MARK: Application Settings
    var userProfileCreated: Bool = false
    var stayLoggedIn: Bool = false
    var token: String = ""
    
    init() { }
}
