//
//  MultiSelectionView.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/25/24.
//

import Foundation
import SwiftUI

struct MultiSelectionView<T: Identifiable & Hashable>: View {
    let options: [T]
    let optionToString: (T) -> String
    
    @Binding var selected: Set<T>
    
    var body: some View {
        List {
            ForEach(options) { selectable in
                Button(action: { toggleSelection(selectedItem: selectable)} ) {
                    HStack {
                        Text(optionToString(selectable))
                            .foregroundStyle(.primary)
                        Spacer()
                        if selected.contains(where: { $0.id == selectable.id }) {
                            Image(systemName: "checkmark")
                                .symbolRenderingMode(.monochrome)
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                }.tag(selectable.id)
            }
        }.listStyle(GroupedListStyle())
    }
    
    private func toggleSelection(selectedItem: T) {
        if let currentIndex = selected.firstIndex(where: { $0.id == selectedItem.id}) {
            selected.remove(at: currentIndex)
        } else {
            selected.insert(selectedItem)
        }
    }
}
