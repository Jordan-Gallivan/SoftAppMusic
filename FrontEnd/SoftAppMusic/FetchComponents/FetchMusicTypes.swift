//
//  FetchMusicPreferences.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/5/24.
//

import Foundation

enum FetchMusicTypes {
    
    static func fetchUpdatedMusicTypes() async -> MusicTypes? {
        return MusicTypes(decades: ["1980s", "1990s", "2000s", "2010s", "2020s"], genres: ["rock", "pop", "rap", "punk"])
        do {
            let (data, urlResponse) = try await HTTPRequests.GET(urlString: "\(APIConstants.API_URL)/\(APIConstants.MUSIC_TYPES)", token: nil)
            guard let httpResponse = urlResponse as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return nil
            }
            
            let updatedMusicTypes = try JSONDecoder().decode(MusicTypes.self, from: data)
            return updatedMusicTypes
            
        } catch {
            NSLog("Error Fetching music types.  \(error.localizedDescription)")
            return nil
        }
    }
    
    static func fetchUserPreferences(userEmail: String) async {
        // MARK: update with GET call
        do {
            
        } catch {
        }
    }
    
    static func updateUserPreferences() {
        // MARK: update with PUT Call
        do {
            
        } catch {
        }
    }
}
