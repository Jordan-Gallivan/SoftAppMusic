//
//  MusicPreferences.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/5/24.
//

import Foundation

struct MusicTypes: Codable {
    var decades: [String: Bool]
    var genres: [String: Bool]
}
