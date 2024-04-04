//
//  SpotifyLoginViewModel.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 4/2/24.
//

import Foundation
import AuthenticationServices

class SpotifyLoginViewModel: NSObject, ObservableObject, ASWebAuthenticationPresentationContextProviding {

    // MARK: - ASWebAuthenticationPresentationContextProviding
    
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return ASPresentationAnchor()
    }

}

enum SpotifyURLBuilder {
    private static let domain = "accounts.spotify.com"
    private static let clientID = "f9fa4c46888643a4bbe9dac4ca54273d"
    private static let scope = "user-read-playback-state user-modify-playback-state user-read-currently-playing streaming"
    
    private static func url(_ state: String) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = domain
        components.path = "/authorize"
        components.queryItems = [
            "client_id": clientID,
            "response_type": "code",
            "redirect_uri": "softAppSpring2024://callback",
            "state": state
        ].map { URLQueryItem(name: $0, value: $1)}
        
        return components.url!
    }
    
    private static func randomString(_ length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
          return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    static func url() -> (URL, String) {
        let state = randomString(16)
        let url = url(state)
        return (url, state)
    }
}
