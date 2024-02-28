//
//  FetchUserData.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/5/24.
//

import Foundation

@MainActor
class FetchUserData: ObservableObject {
    
    @Published var result: AsyncStatus<UserProfileData> = .empty
    
    func fetchUserData(email: String, token: String?) async -> UserProfileData? {
        result = .inProgress(page: "User Profile")
        do {
            let (data, response) = try await HTTPRequests.GET(
                urlString: "\(APIConstants.API_URL)/\(APIConstants.USER_PROFILE)/\(email)",
                token: token)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw FetchError.HTTPResponseError(message: "HTTP Response error. \(response)")
                // MARK: Update error handling
            }
            
            let userProfileData = try JSONDecoder().decode(UserProfileData.self, from: data)
            result = .success(userProfileData)    
            return userProfileData
            
        } catch {
            NSLog("Error fetching user profile data \(error.localizedDescription)")
            result = .failure(error)
        }
        return nil
    }
    
    func createUserRequest(email: String) -> UserProfileData {
        print("function called")
        let userProfileData = UserProfileData(email: email)
        result = .success(userProfileData)
        return userProfileData
    }
}
