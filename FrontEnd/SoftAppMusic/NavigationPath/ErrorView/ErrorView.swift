//
//  ErrorPage.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/26/24.
//

import Foundation
import SwiftUI

struct ErrorView: View {
    var pageName: String
    var refreshFunction: () async -> Void
    
    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(.red)
            Text("Error Loading \(pageName)")
        }
        .refreshable {
            await refreshFunction()
        }
    }
}
