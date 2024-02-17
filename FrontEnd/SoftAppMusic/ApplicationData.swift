//
//  ApplicationData.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/13/24.
//

import Foundation
import SwiftUI

class AppData: ObservableObject {
    /// Navigation Path
    @Published var viewPath = NavigationPath()
}
