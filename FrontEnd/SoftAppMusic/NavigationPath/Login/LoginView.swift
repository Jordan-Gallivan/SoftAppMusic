//
//  LoginView.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/19/24.
//

import Foundation
import SwiftData
import SwiftUI

struct LoginView: View {
    @Environment(\.modelContext) var dbContext
    @Query var masterSettingsModel: [MasterSettingsModel]
    @State var userLogin: FetchUserLogin = FetchUserLogin()
    
    var body: some View {
        VStack {
            Spacer()
            Image("logo")
            Spacer()
            LoginTextFields("Username", 
                            content: $userLogin.enteredUserName,
                            errorStatus: $userLogin.usernameStatus)
//            LoginTextFields("Password",
//                            content: $userLogin.enteredPassword,
//                            errorStatus: $userLogin.passwordStatus,
//                            isPassword: true
//            )
        }
    }
}
