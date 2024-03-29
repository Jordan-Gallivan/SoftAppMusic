//
//  LoadingPage.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/26/24.
//

import Foundation
import SwiftUI

struct LoadingView: View {
    var prompt: String
    
    var body: some View {
        VStack {
            ProgressView("\(prompt)")
        }
    }
}
