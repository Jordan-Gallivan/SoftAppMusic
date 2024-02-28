//
//  DefaultButtonStyling.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/28/24.
//

import Foundation
import SwiftUI

struct DefaultButtonStyling: ButtonStyle {
    let buttonColor: Color
    let borderColor: Color
    let textColor: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(buttonColor)
            .border(borderColor, width: 2.0)
            .foregroundColor(textColor)
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}
