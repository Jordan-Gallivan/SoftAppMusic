//
//  FetchUserData.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/5/24.
//

import Foundation

@MainActor
class FetchUserData: ObservableObject {
    
    struct SpotifyCredentials: Codable {
        var code: String
    }
    
    @Published var result: AsyncStatus<UserProfileData?> = .empty
    
    /// Fetches updated user profile information.  Expected JSON:
    ///
    /// `{ 
    /// `  "email": "example@email.com",
    /// `  "firstName": "exampleName",
    /// `  "lastName": "exampleName",
    /// `  "age": 30,
    /// `  "spotifyConsent": true,
    /// `}`
    ///
    /// - Parameters:
    ///   - email:
    ///   - token:
    /// - Returns: UserProfileData Struct if successful, otherwise nil.
    func fetchUserData(email: String, token: String?) async -> UserProfileData? {
        result = .inProgress(page: "User Profile")
        do {
            let (data, urlResponse) = try await HTTPRequests.GET(
                urlString: "\(APIConstants.API_URL)/\(APIConstants.PUT_USER_PROFILE(email: email))",
                token: token)
            
            guard HTTPRequests.validateHTTPResponseCode(urlResponse, errorString: "Fetch User Data") else {
                self.result = .failure(FetchError.HTTPResponseError(message: "HTTP Response error. \(urlResponse)"))
                return nil
            }
            
            NSLog("User Data: \(String(data: data, encoding: .utf8) ?? "UNABLE TO PARSE")")
            
            let userProfileData = try JSONDecoder().decode(UserProfileData.self, from: data)
            result = .success(userProfileData)
            
            NSLog("User Profile Data successfully fetched.")
            return userProfileData
            
        } catch {
            NSLog("Error fetching user profile data \(error.localizedDescription)")
            result = .failure(error)
        }
        return nil
    }
    
    func updateUserData(userProfileData: UserProfileData, email: String, token: String) async -> Bool {
        result = .inProgress(page: "Updating User Profile")
        do {
            let (data, urlResponse) = try await HTTPRequests.POST(
                urlString: "\(APIConstants.API_URL)/\(APIConstants.PUT_USER_PROFILE(email: email))",
                message: userProfileData,
                token: token)
            guard HTTPRequests.validateHTTPResponseCode(urlResponse, errorString: "Update User Data") else {
                result = .failure(FetchError.HTTPResponseError(message: "HTTP Response error. \(urlResponse)"))
                print("response body: \(String(data: data, encoding: .utf8))")
                return false
            }
            
        } catch {
            NSLog("Error fetching user profile data \(error.localizedDescription)")
            result = .failure(error)
            return false
        }
        
        NSLog("User Profile Data successfully updated.")
        result = .success(userProfileData)
        return true
    }
    
    func createUserRequest(email: String) -> UserProfileData {
        let userProfileData = UserProfileData(email: email)
        result = .success(userProfileData)
        return userProfileData
    }
    
    
    /// Updates the user's spotify login credentials.  Outbound JSON:
    /// `{
    /// `  "spotifyUserName": String,
    /// `  "spotifyPassword": String,
    /// `}
    /// - Parameters:
    ///   - email:
    ///   - spotifyCredentials:
    ///   - token:
    /// - Returns: true if successful.
    func updateSpotifyCredentials(code: String, email: String, token: String) async -> Bool {
        result = .inProgress(page: "Updating Spotify Login")
        do  {
            let (data, urlResponse) = try await HTTPRequests.POST(
                urlString: "\(APIConstants.API_URL)/\(APIConstants.SPOTIFY_CREDENTIALS(email: email))",
                message: SpotifyCredentials(code: code),
                token: token)
            guard HTTPRequests.validateHTTPResponseCode(urlResponse, errorString: "Update Spotify Login") else {
                result = .failure(FetchError.HTTPResponseError(message: "HTTP Response error. \(urlResponse)"))
                print("response body: \(String(data: data, encoding: .utf8))")
                return false
            }
            
        } catch {
            NSLog("Error fetching user profile data \(error.localizedDescription)")
            result = .failure(error)
            return false
        }
        
        NSLog("Spotify Login successfully updated")
        result = .success(nil)
        return true
    }
}
