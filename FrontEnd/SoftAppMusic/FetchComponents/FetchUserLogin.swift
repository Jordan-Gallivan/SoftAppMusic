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

enum ErrorStates {
    case empty
    case valid
    case invalid
    case tooManyAttempts
    case passwordsDoNotMatch
}

struct Token: Decodable {
    let token: String
}


@MainActor
class FetchUserLogin: ObservableObject {
   
    enum UsernameStatus {
        static let ValidUsername = ""
        static let NoUsername = "Please enter a username"
        static let InvalidUsername = "Username not recognized"
    }

    enum PasswordStatus {
        static let ValidPassword = ""
        static let NoPassword = "Please enter a password"
        static let PasswordDoesNotMatchUsername = "Password does not match username"
        static let TooManyAttempts = "Too many attempts.  Account has been locked."
    }
    
    @Published var status: LoginStatus = .empty
    @Published var enteredUserName = ""
    @Published var enteredPassword = ""
    @Published var usernameStatus: ErrorStates = .valid
    @Published var passwordStatus: ErrorStates = .valid
    
    private var attempts = 0
    @Published var usernamePreviouslyEmpty = false
    private var passwordPreviouslyEmpty = false
    
    /// structs to decode/encode JSON
    private struct UsernameAndPassword: Encodable {
        let username: String
        let password: String
    }
    private struct InvalidUsernamePasswordResponse: Decodable {
        let username: Bool
        let password: Bool
    }
    
    /// Validates user login data and returns a JWT token if login is valid
    /// Published JSON:
    /// `{`
    /// `  "username": "exampleUserName"
    /// `  "password": "examplePassword"
    /// `}`
    ///
    /// Expected Response JSON:
    /// ` { "token": String }
    /// - Returns: JWT token String if login is valid and class variable status is set to .success.
    /// Otherwise class variable status is set to .error or .failure and nil is returned.
    public func attemptLogin(token: String?) async -> String? {

        // validate number of attempted logins
        guard attempts <= 3 else {
            passwordStatus = .tooManyAttempts
            return nil
        }
        
        // validate user entered a username and password
        guard enteredUserName.count > 0 && enteredPassword.count > 0 else {
            if enteredUserName.count == 0 {
                usernamePreviouslyEmpty = true
                usernameStatus = .empty
            }
            if enteredPassword.count == 0 {
                passwordPreviouslyEmpty = true
                passwordStatus = .empty
            }
            return nil
        }
        
        let message = UsernameAndPassword(username: enteredUserName, password: enteredPassword)
        
        do {
            let (data, urlResponse) = try await HTTPRequests.POST(urlString: "\(APIConstants.API_URL)/\(APIConstants.LOGIN)",
                                                                       message: message,
                                                                       token: token)
            
            guard let response_status = urlResponse as? HTTPURLResponse else {
                NSLog("Corrupt HTTP Response Code")
                status = .error(FetchError.HTTPResponseError(message: "Corrupt HTTP Response Code"))
                return nil
            }
            
            // verify 200 HTTP Response code
            guard response_status.statusCode >= 200 && response_status.statusCode < 300 else {
                if response_status.statusCode == 401 {
                    NSLog("INVALID LOGIN: \(String(data: data, encoding: .utf8) ?? "UNABLE TO PARSE")")
                    let usernamePasswordResponse = try JSONDecoder().decode(
                        InvalidUsernamePasswordResponse.self,
                        from: data)
                    handleInvalidUserNamePassword(usernamePasswordResponse)
                } else {
                    print(String(data: data, encoding: .utf8)!)
                    print(response_status.statusCode)
                    status = .error(FetchError.HTTPResponseError(message: "HTTP Response Code: \(response_status.statusCode)"))
                }
                return nil
            }
            let token = try JSONDecoder().decode(Token.self, from: data)
            status = .success(token.token)
            
            return token.token
            
        } catch {
            NSLog("Error parsing Token")
            status = .error(error)
        }
        return nil
        
    }
    
    
    /// Creates a user with given username and password.  Username and password requirements are validated locally.  Only 3 attempts are allowed.
    /// Any errors are captured in the .status attribute.
    /// Posted JSON:
    /// `{`
    /// `  "username": "exampleUserName"
    /// `  "password": "examplePassword"
    /// `}`
    /// - Returns: True if user creation is successful.
    func createUser() async -> Bool {
        // validate number of attempted logins
        guard attempts <= 3 else {
            passwordStatus = .tooManyAttempts
            return false
        }
        
        // validate user entered a username and password
        guard enteredUserName.count > 0 && enteredPassword.count > 0 else {
            if enteredUserName.count == 0 {
                usernamePreviouslyEmpty = true
                usernameStatus = .empty
            }
            if enteredPassword.count == 0 {
                passwordPreviouslyEmpty = true
                passwordStatus = .empty
            }
            return false
        }
        
        let message = UsernameAndPassword(username: enteredUserName, password: enteredPassword)
        do {
            let (_, response) = try await HTTPRequests.POST(urlString: "\(APIConstants.API_URL)/\(APIConstants.CREATE_LOGIN)",
                                                                       message: message,
                                                                       token: nil)
            
            guard let response_status = response as? HTTPURLResponse else {
                NSLog("Corrupt HTTP Response Code")
                status = .error(FetchError.HTTPResponseError(message: "Corrupt HTTP Response Code"))
                return false
            }
            
            // verify 200 HTTP Response code
            guard response_status.statusCode >= 200 && response_status.statusCode < 300 else {
                NSLog("HTTP Response Code: \(response_status.statusCode)")
                if response_status.statusCode == 409 {
                    usernameStatus = .invalid
                    status = .failure
                } else {
                    status = .error(FetchError.HTTPResponseError(message: "HTTP Response Code: \(response_status.statusCode)"))
                }
                return false
            }
            status = .success("")
        } catch {
            status = .error(error)
        }
        return true
        
    }
    
    private func handleInvalidUserNamePassword(_ response: InvalidUsernamePasswordResponse) {
        if !response.username {
            attempts = 0
            usernameStatus = .invalid
            passwordStatus = .valid
            return
        }
        usernameStatus = .valid
        passwordStatus = .invalid
        attempts += 1
    }
    
    func clearUsernameStatus() {
        usernameStatus = .valid
    }
    
}
