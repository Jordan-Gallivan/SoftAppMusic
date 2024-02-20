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
    @ObservedObject var userLogin = FetchUserLogin()
  
    
    var body: some View {
        VStack {
            Spacer()
            Image("logo")
            Spacer()
            LoginTextFields("Username", 
                            content: $userLogin.enteredUserName,
                            errorStatus: $userLogin.usernameStatus)
            .padding()
            
            LoginTextFields("Password",
                            content: $userLogin.enteredPassword,
                            errorStatus: $userLogin.passwordStatus,
                            isPassword: true
            )
            .padding()
            Button(action: {
                Task {
                    await userLogin.attemptLogin(token: nil)
                }
            }, label: {
                Text("Let's Move")
            })
            
            Text("First time? Click to create a profile.")
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                Text("Create User")
            })
            

        }
    }
    

}
