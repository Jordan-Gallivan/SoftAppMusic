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
    @ObservedObject private var userLogin = FetchUserLogin()
    
    
    /// User Application Seettings
    @EnvironmentObject private var appData: AppData
    @Environment(\.modelContext) var dbContext
    @Query var masterSettingsModel: [MasterSettingsModel]
    @State var errorDuringLoginAttempt: Bool = false
    private var settings: MasterSettingsModel { masterSettingsModel.first! }
    private var stayLoggedIn: Binding<Bool> {
        Binding { settings.stayLoggedIn }
        set: { settings.stayLoggedIn = $0 }
    }
    
    
    /// username and password status
    private var usernameErrorStatus: Binding<String> {
        Binding {
            switch userLogin.usernameStatus {
            case .empty:
                return userLogin.enteredUserName.isEmpty ? "Please enter a username" : ""
            case .valid:
                return ""
            default:
                return "Username not recognized"
            }
        }
        set: { _ in return}
    }
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
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            Spacer()
            Spacer()
            if errorDuringLoginAttempt {
                Text("Error during login. Please try again")
                    .foregroundStyle(.red)
                    .font(.footnote)
            }
            LoginTextFields("Username",
                            content: $userLogin.enteredUserName,
                            errorStatus: usernameErrorStatus.wrappedValue)
            .padding()
            
            LoginTextFields("Password",
                            content: $userLogin.enteredPassword,
                            errorStatus: passwordErrorStatus.wrappedValue,
                            isPassword: true)
            .padding()
            
            Button(action: {
                Task {
                    let token = await userLogin.attemptLogin(token: nil)
                    guard let token else {
                        errorDuringLoginAttempt = true
                        return
                    }
                    appData.currentToken = token
                    appData.currentUserEmail = userLogin.enteredUserName
                    
                    // navigate to next page
                    appData.viewPath.append(NavigationViews.workoutPormpt(initialUse: false))
                }
            }, label: {
                if case .inprogress = userLogin.status {
                    ProgressView()
                } else {
                    Text("Let's Move")
                }
            })
            .disabled( {
                if case .inprogress = userLogin.status {
                    return true
                } else {
                    return false
                }
            }())
            .buttonStyle(DefaultButtonStyling(buttonColor: StyleConstants.DarkBlue, borderColor: StyleConstants.DarkBlue, textColor: Color.white))
            
            Toggle(isOn: stayLoggedIn) {
                Text("Stay logged in")
            }
            .padding()
            
            Spacer()
            
            Text("First time? Click to create a profile.")
            NavigationLink("Create User", value: NavigationViews.createLoginView)
            
            Spacer()
            Spacer()
        }
        .navigationBarBackButtonHidden()

    }
    

}
