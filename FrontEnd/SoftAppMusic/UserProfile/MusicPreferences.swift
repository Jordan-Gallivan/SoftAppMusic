//
//  MusicPreferences.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/5/24.
//

import Foundation

struct MusicPreferences: Codable {
    let userEmail: String
    var decades: [String: Bool]
    var genres: [String: Bool]
}
