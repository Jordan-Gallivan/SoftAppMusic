//
//  FetchMusicPreferences.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/5/24.
//

import Foundation

class FetchMusicTypes: ObservableObject {
    
    @Published var result: AsyncStatus<MusicTypes> = .empty
    @Published var musicPreferences: MusicTypes?
    let pageName = "Music Preferences"
    
    func fetchEmptyPreferences() async {
        // MARK: update with GET call
        do {
            result = .inProgress(page: pageName)
            result = .success(musicPreferences!)
        } catch {
            result = .failure(error)
        }
    }
    
    func fetchUserPreferences(userEmail: String) async {
        // MARK: update with GET call
        do {
            result = .inProgress(page: pageName)
            result = .success(musicPreferences!)
        } catch {
            result = .failure(error)
        }
    }
    
    func updateUserPreferences() {
        // MARK: update with PUT Call
        do {
            result = .inProgress(page: pageName)
            result = .success(musicPreferences!)
        } catch {
            result = .failure(error)
        }
    }
}
