//
//  Item.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/2/24.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
