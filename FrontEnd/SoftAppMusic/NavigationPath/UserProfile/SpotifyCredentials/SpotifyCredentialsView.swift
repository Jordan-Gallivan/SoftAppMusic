//
//  SpotifyConsentView.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 3/31/24.
//

import Foundation
import SwiftUI

struct SpotifyCredentialsView: View {
    @Binding var spotifyLogin: SpotifyLogin
    @Binding var invalidCredentials: Bool
    @State private var viewTermsOfService: Bool = false

    var body: some View {
        VStack {
            Spacer()
            if invalidCredentials {
                Text("Spotify Credentials are required to utilize the funcitonality of the SoftApp Music app.")
                    .foregroundStyle(.red)
            }
            Button("Credentials are used per the Terms of Service") {
                viewTermsOfService = true
            }
            if viewTermsOfService {
                TermsOfServiceView(viewOnly: true) {
                    viewTermsOfService = false
                }
            }
            
            LoginTextFields("Spotify Username", 
                            content: $spotifyLogin.spotifyUserName,
                            errorStatus: invalidCredentials ? "Username Required" : "")
            LoginTextFields("Spotify Password",
                            content: $spotifyLogin.spotifyPassword,
                            errorStatus: invalidCredentials ? "Password Required" : "",
                            isPassword: true)
        }
    }
}
