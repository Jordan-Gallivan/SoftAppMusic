//
//  FetchUserLogin.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/13/24.
//

import Foundation
import UIKit

enum LoginStatus {
    case empty
    case inprogress
    case success(String)
    case failure
    case error(Error)
}

class FetchUserLogin: ObservableObject {
   
    private enum UsernameStatus: String {
        case ValidUsername = ""
        case NoUsername = "Please enter a username"
        case InvalidUsername = "Username not recognized"
    }

    private enum PasswordStatus: String {
        case ValidPassword = ""
        case NoPassword = "Please enter a password"
        case PasswordDoesNotMatchUsername = "Password does not match username"
        case TooManyAttempts = "Too many attempts.  Account has been locked."
    }
    
    @Published var status: LoginStatus = .empty
    @Published var enteredUserName = ""
    @Published var enteredPassword = ""
    @Published var usernameStatus: String = ""
    @Published var passwordStatus: String = ""
    
    private var attempts = 0
    
    /// structs to decode/encode JSON
    private struct UsernameAndPassword: Encodable {
        let username: String
        let password: String
    }
    private struct InvalidUsernamePasswordResponse: Decodable {
        let username: Bool
        let password: Bool
    }
    private struct Token: Decodable {
        let token: String
    }
    
    /// Validates user login data and returns a JWT token if login is valid
    ///
    /// - Returns: JWT token String if login is valid and class variable status is set to .success.
    /// Otherwise class variable status is set to .error or .failure and nil is returned.
    @discardableResult
    public func attemptLogin(token: String?) async -> String? {
        // validate number of attempted logins
        guard attempts <= 3 else {
            passwordStatus = PasswordStatus.TooManyAttempts.rawValue
            return nil
        }
        
        // validate user entered a username and password
        guard enteredUserName.count > 0 && enteredPassword.count > 0 else {
            if enteredUserName.count == 0 {
                usernameStatus = UsernameStatus.NoUsername.rawValue
            }
            if enteredPassword.count == 0 {
                passwordStatus = PasswordStatus.NoPassword.rawValue
            }
            return nil
        }
        
        let message = UsernameAndPassword(username: enteredUserName, password: enteredPassword)
        
        do {
            let (responseData, response) = try await HTTPRequests.POST(urlString: "\(APIConstants.API_URL)/\(APIConstants.LOGIN_POST)",
                                                                       message: message,
                                                                       token: token)
            
            guard let response_status = response as? HTTPURLResponse else {
                NSLog("Corrupt HTTP Response Code")
                status = .error(FetchError.HTTPResponseError(message: "Corrupt HTTP Response Code"))
                return nil
            }
            
            // verify 200 HTTP Response code
            guard response_status.statusCode == 200 else {
                if response_status.statusCode == 401 {
                    let usernamePasswordResponse = try JSONDecoder().decode(
                        InvalidUsernamePasswordResponse.self,
                        from: responseData)
                    handleInvalidUserNamePassword(usernamePasswordResponse)
                } else {
                    status = .error(FetchError.HTTPResponseError(message: "HTTP Response Code: \(response_status.statusCode)"))
                }
                return nil
            }
            let token = try JSONDecoder().decode(Token.self, from: responseData)
            status = .success(token.token)
            return token.token
            
        } catch {
            status = .error(error)
        }
        return nil
        
    }
    
    private func handleInvalidUserNamePassword(_ response: InvalidUsernamePasswordResponse) {
        if !response.username {
            attempts = 0
            usernameStatus = UsernameStatus.InvalidUsername.rawValue
            passwordStatus = PasswordStatus.ValidPassword.rawValue
            return
        }
        usernameStatus = UsernameStatus.ValidUsername.rawValue
        passwordStatus = PasswordStatus.PasswordDoesNotMatchUsername.rawValue
        attempts += 1
    }
    
}
