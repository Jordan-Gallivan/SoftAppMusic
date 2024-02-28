//
//  CreateUserLoginView.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/9/24.
//

import Foundation
import SwiftData
import SwiftUI

struct PasswordRequirements: View {
    var requirement: String
    @Binding var requirementSatisfied: Bool
    @Binding var submissionAttempt: Bool
    
    var body: some View {
        HStack {
            Image(systemName: requirementSatisfied ? "checkmark.square" : "square")
                .symbolRenderingMode(.monochrome)
                .foregroundStyle(requirementSatisfied ? .primary : Color.red)
            Text(requirement)
                .foregroundStyle(submissionAttempt && !requirementSatisfied ? .red : Color.primary)
        }
        
    }
}


struct CreateUserLoginView: View {
    @ObservedObject var userLogin = FetchUserLogin()
    
    // MARK: User Application Seettings
    @EnvironmentObject private var appData: AppData
    @Environment(\.modelContext) private var dbContext
    @Query private var masterSettingsModel: [MasterSettingsModel]
    private var settings: MasterSettingsModel { masterSettingsModel.first! }
    private var userProfileCreated: Binding<Bool> {
        Binding { settings.userProfileCreated }
        set: { settings.userProfileCreated = $0 }
    }
    
    
    // MARK: username and password status
    private var usernameErrorStatus: Binding<String> {
        Binding {
            switch userLogin.usernameStatus {
            case .empty:
                return userLogin.enteredUserName.isEmpty ? "Please enter a username" : ""
            case .valid:
                return ""
            default:
                return "Username already in use"
            }
        }
        set: { _ in return}
    }
    @State private var eightCharacters = false
    @State private var specialCharacter = false
    @State private var number = false
    @State private var passwordsMatch = false
    
    private var password1: Binding<String> {
        Binding { userLogin.enteredPassword }
        set: {
            passwordsMatch = enteredPassword2 == $0 && !enteredPassword2.isEmpty
            eightCharacters = $0.count >= 8
            specialCharacter = $0.contains(/[!@#\$%\^&\*\(\),\.'"]/)
            number = $0.contains(/\d/)
            userLogin.enteredPassword = $0
        }
    }
    @State private var enteredPassword2: String = ""
    private var password2: Binding<String> {
        Binding { enteredPassword2 }
        set: {
            passwordsMatch = userLogin.enteredPassword == $0 && !enteredPassword2.isEmpty
            enteredPassword2 = $0
        }
    }
    
    @State private var submissionAttempt = false
    
    private var passwordErrorStatus: Binding<String> {
        Binding {
            switch userLogin.passwordStatus {
            case .empty:
                return userLogin.enteredPassword.isEmpty ? "Please enter a password" : ""
            case .valid:
                return ""
            case .invalid:
                return "Password does not match username"
            case .tooManyAttempts:
                return "Too many attempts.  Account has been locked."
            default:
                return ""
            }
        }
        set: { _ in return}
    }
  
    
    var body: some View {
        VStack {
            Spacer()
            Spacer()
            Image("logo")
            Spacer()
            Spacer()
            
            LoginTextFields("Username",
                            content: $userLogin.enteredUserName,
                            errorStatus: usernameErrorStatus.wrappedValue)
            .padding()
            
            LoginTextFields("Password",
                            content: password1,
                            errorStatus: "",
                            isPassword: true)
            .padding()
            
            VStack(alignment: .leading){
                PasswordRequirements(requirement: "8 characters", requirementSatisfied: $eightCharacters, submissionAttempt: $submissionAttempt)
                PasswordRequirements(requirement: "One Number", requirementSatisfied: $number, submissionAttempt: $submissionAttempt)
                PasswordRequirements(requirement: "One Special Character", requirementSatisfied: $specialCharacter, submissionAttempt: $submissionAttempt)
                PasswordRequirements(requirement: "Passwords Match", requirementSatisfied: $passwordsMatch, submissionAttempt: $submissionAttempt)
            }
            
            LoginTextFields("Password",
                            content: password2,
                            errorStatus: "",
                            isPassword: true)
            .padding()
            
            Button(action: {
                submissionAttempt = true
                guard eightCharacters && number && specialCharacter && passwordsMatch else {
                    return
                }
                Task {
                    let token = await userLogin.attemptLogin(token: nil)
                    guard let token else { return }
                    
                    appData.currentToken = token
                    appData.currentUserEmail = userLogin.enteredUserName
                    // MARK: Update navigation link
                }
            }, label: {
                Text("Let's Move")
            })
            .padding()
            .background(StyleConstants.DarkBlue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 5))
            

            
            Spacer()
            
            Text("Already a user? Click here to log in.")
            NavigationLink("Log in") {
                LoginView()
            }
            
            Spacer()
            Spacer()
        }
        .navigationBarBackButtonHidden()
    }
}
