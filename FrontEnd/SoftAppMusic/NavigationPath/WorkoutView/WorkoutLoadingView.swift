//
//  WorkoutLoadingView.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 3/27/24.
//

import Foundation
import SwiftUI

struct WorkoutLoadingView: View {
    
    let text: String
    
    var body: some View {
        VStack {
            Text(text)
                .font(.headline)
            ProgressView()
        }
    }
}
