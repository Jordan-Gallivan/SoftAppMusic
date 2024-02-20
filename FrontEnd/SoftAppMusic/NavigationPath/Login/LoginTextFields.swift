//
//  LoginTextFields.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/19/24.
//

import Foundation
import SwiftUI

struct LoginTextFields: View {
    var title: String
    var isPassword: Bool
    @Binding var content: String
    @Binding var errorStatus: String
    @State private var height: CGFloat = 0
//    @State private var isEditing: Bool = false
    @FocusState private var isFocused: Bool
    private var isEditing: Binding<Bool> {
        Binding { isFocused }
        set: {isFocused = $0 }
    }
    

    init(_ title: String, content: Binding<String>, errorStatus: Binding<String>, isPassword: Bool = false) {
        self.title = title
        self._content = content
        self._errorStatus = errorStatus
        self.isPassword = isPassword
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            Text(title)
                .foregroundColor(content.isEmpty ? Color(.placeholderText): .accentColor)
                .offset(x: content.isEmpty ? 0 : -16,
                        y: content.isEmpty ? 0 : -height * 0.85)
                .scaleEffect(content.isEmpty ? 1 : 0.9, anchor: .leading)
                .padding()
                .font(content.isEmpty ? .body : .body.bold())
            
//            TextField("", text: $content) { _ in
//                withAnimation(.default) { isEditing.toggle() }
//            }
//            .modifier(LoginTextFieldModifier(isEditing: $isEditing, errorStatus: $errorStatus, height: $height))
            if isPassword {
                SecureField("", text: $content)
                    .focused($isFocused)
                    .modifier(LoginTextFieldModifier(isEditing: isEditing, errorStatus: $errorStatus, height: $height))
            } else {
                TextField("", text: $content) { _ in
                        withAnimation(.default) { isFocused = !isFocused }
                }
                .modifier(LoginTextFieldModifier(isEditing: isEditing, errorStatus: $errorStatus, height: $height))
            }
        }
        .background {
            Color(.secondarySystemBackground)
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                .shadow(radius: 2)
        }
        .animation(.default, value: content.isEmpty)
        .animation(.default, value: errorStatus.isEmpty)
        if !errorStatus.isEmpty {
            Text(errorStatus)
                .padding(.leading, 2)
                .font(.footnote)
                .foregroundStyle(Color(.systemRed))
        }
    }
}

struct LoginTextFieldModifier: ViewModifier {
    @Binding var isEditing: Bool
    @Binding var errorStatus: String
    @Binding var height: CGFloat
    
    func body(content: Content) -> some View {
        content
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(isEditing ? Color.accentColor : Color(.secondarySystemBackground), lineWidth: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(!errorStatus.isEmpty ? Color.red : Color.clear, lineWidth: 2)
            )
            .background(
                GeometryReader { geometry in
                    Color(.clear).onAppear {
                        height = geometry.size.height
                    }
                }
            )
    }
}
