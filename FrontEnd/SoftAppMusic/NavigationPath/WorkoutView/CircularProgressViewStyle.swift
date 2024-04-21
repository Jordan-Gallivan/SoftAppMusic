//
//  CircularProgressViewStyle.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 4/10/24.
//

import Foundation
import SwiftUI

struct CircularProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .trim(from: 0.0, to: CGFloat(configuration.fractionCompleted ?? 0))
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 5))
                .rotationEffect(.degrees(-90.0))
                .frame(width: 275)
        }
    }
}
