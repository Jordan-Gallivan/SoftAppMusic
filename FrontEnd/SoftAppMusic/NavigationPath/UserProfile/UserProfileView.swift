//
//  UserProfileView.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/26/24.
//

import Foundation
import SwiftUI
import AuthenticationServices

struct UserProfileView: View {
    var isCreatingUserProfile: Bool
    var invalidSpotifyCredentials: Bool
    var errorPrompt: Bool = false
    
    @EnvironmentObject private var appData: AppData
    @ObservedObject private var fetchUserData = FetchUserData()
    
    @State private var userProfileData = UserProfileData()
    @State private var spotifyLoginIsEmpty: Bool = false
    @State private var workoutMusicMatches: WorkoutMusicMatches = WorkoutMusicMatches(workoutTypes: [])
    private var age: Binding<String> {
        Binding { String(userProfileData.age) }
        set: {
            guard let age = Int($0) else {
                NSLog("Age input is not an integer")
                return
            }
            userProfileData.age = age
        }
    }
    @State private var ageIsEmpty: Bool = false
    @State private var makeWorkoutMusicMatches = false
    
    private var viewController = SpotifyLoginViewModel()
    @State private var pendingSpotifyResponse: Bool = false
    @State private var SpotifyCode: String? = nil
    
    init(isCreatingUserProfile: Bool, invalidSpotifyCredentials: Bool = false) {
        self.isCreatingUserProfile = isCreatingUserProfile
        self.invalidSpotifyCredentials = invalidSpotifyCredentials
        if invalidSpotifyCredentials {
            self.errorPrompt = true
            self.spotifyLoginIsEmpty = true
        }
    }
    
    var body: some View {
        VStack {
            switch fetchUserData.result {
            case .empty:
                EmptyView()
            case .inProgress(_):
                LoadingView(prompt: "Gather Profile Information")
            case .success(_):
                VStack {
                    Form {
                        // immutable field
                        TextField("Email", text: $userProfileData.email)
                            .disabled(true)
                        TextField("First Name", text: $userProfileData.firstName)
                        TextField("Last Name", text: $userProfileData.lastName)
                        TextField(text: age) {
                            if ageIsEmpty {
                                Text("Age")
                                    .padding([.leading], 20)
                                    .border(.red, width: 2)
                                    .tint(.red)
                            } else {
                                Text("Age")
                            }
                        }
                    }
                    if errorPrompt {
                        Text("Spotify Credentials are required")
                            .font(.title2)
                            .foregroundStyle(.red)
                    }
                    
                    Button("Update Spotify Credentials") { self.authSpotify() }
                    .buttonStyle(
                        DefaultButtonStyling(buttonColor: .clear,
                                             borderColor: spotifyLoginIsEmpty ? .red : StyleConstants.DarkBlue,
                                             textColor: spotifyLoginIsEmpty ? .red : StyleConstants.DarkBlue)
                    )
                    
                    Button("Update Workout and Music Preferences") { makeWorkoutMusicMatches.toggle() }
                    .buttonStyle(
                        DefaultButtonStyling(buttonColor: Color.clear,
                                             borderColor: StyleConstants.DarkBlue,
                                             textColor: StyleConstants.DarkBlue))
                    Spacer()
                    
                    if pendingSpotifyResponse {
                        HStack{
                            Text("Verifying Spotify Credentials...")
                            ProgressView()
                        }
                    } else {
                        Button(action: {
                            Task {
                                // validate and update user data
                                guard self.validateUserData() else { return }
                                guard await updateUserData() else { return }
                                
                                // update application data with user's selected workout matches
                                appData.updateUserMusicPreferences(workoutMusicMatches)
                                
                                // navigate to next view
                                if isCreatingUserProfile {
                                    appData.viewPath.append(NavigationViews.workoutPormpt(initialUse: isCreatingUserProfile))
                                } else {
                                    appData.viewPath.removeLast()
                                }
                            }
                        }, label: { Text(isCreatingUserProfile ? "Get Moving" : "Save") })
                        .buttonStyle(
                            DefaultButtonStyling(buttonColor: StyleConstants.DarkBlue,
                                                 borderColor: StyleConstants.DarkBlue,
                                                 textColor: Color.white))
                    }
                }
            case .failure(_):
                ErrorView(pageName: "User Profile") {
                    await initializeUserData()
                }
            }
                
        }
        .onAppear {
            Task { await self.initializeUserData() }
        }
        .navigationBarBackButtonHidden(isCreatingUserProfile)
        .sheet(isPresented: $makeWorkoutMusicMatches) {
            VStack {
                WorkoutMusicMatchView(
                    workoutMusicMatches: $workoutMusicMatches,
                    musicTypes: appData.musicTypes)
                
                Button("Save") { makeWorkoutMusicMatches.toggle() }
                    .buttonStyle(DefaultButtonStyling(buttonColor: StyleConstants.DarkBlue, borderColor: StyleConstants.DarkBlue, textColor: Color.white))
            }
            .presentationDetents([.medium])
        }
    }
    
    private func initializeUserData() async {
        // check if first time updating user profile
        if isCreatingUserProfile {
            userProfileData = fetchUserData.createUserRequest(email: appData.currentUserEmail)
            userProfileData.spotifyConsent = false
            populateMusicPreferences(userPreferences: [:])
            return
        }
        
        // fetches current user data.  If unsuccessful, a default user profile is instantiated.
        let profileData = await fetchUserData.fetchUserData(email: appData.currentUserEmail, token: appData.currentToken)
        
        if profileData == nil {
            NSLog("Unable to fetch user profile data.  Creating Empty Profile")
        }
        userProfileData = profileData ?? fetchUserData.createUserRequest(email: appData.currentUserEmail)
        
        
        let music = await FetchMusicAndWorkoutMatches.fetchUserPreferences(email: appData.currentUserEmail, token: appData.currentToken)
        if music == nil {
            NSLog("Unable to fetch music preferences.  Creating Empty Music Matches")
        }
        
        // update music preferences
        populateMusicPreferences(userPreferences: music?.userPreferences ?? [:])
        
        NSLog("Profile and Music Preferences Successfully Loaded")
    }
    
    private func populateMusicPreferences(userPreferences: [String: Set<String>]) {
        // pull workout types
        appData.workoutTypes.forEach { workoutMusicMatches.userPreferences[$0] = [] }
        
        guard !userPreferences.isEmpty else { return }
        userPreferences.keys.forEach {
            workoutMusicMatches.userPreferences[$0] = Set(userPreferences[$0] ?? [])
        }
    }
    
    private func validateUserData() -> Bool {
        self.ageIsEmpty = self.userProfileData.age == 0
        
        if self.isCreatingUserProfile {
            return !self.ageIsEmpty && !self.spotifyLoginIsEmpty
        }
        
        return !self.ageIsEmpty
    }
    
    private func updateUserData() async -> Bool {
        guard await fetchUserData.updateUserData(
            userProfileData: userProfileData,
            email: userProfileData.email,
            token: appData.currentToken)
        else {
            NSLog("Unable to update profile data")
            return false
        }
        NSLog("Profile successfully updated.")
        
        guard await FetchMusicAndWorkoutMatches.updateUserPreferences(
            email: appData.currentUserEmail,
            matches: workoutMusicMatches,
            token: appData.currentToken)
        else {
            NSLog("Unable to update Music Preferences")
            return false
        }
        appData.workoutMusicMatches = workoutMusicMatches
        NSLog("Music Preferences successfully updated.")

        guard let code = self.SpotifyCode else {
            NSLog("No spotify credentials")
            self.spotifyLoginIsEmpty = true
            return false
        }
        guard await fetchUserData.updateSpotifyCredentials(code: code, email: appData.currentUserEmail, token: appData.currentToken)
        else {
            NSLog("Unable to update Spotify credentials.")
            return false
        }
        
        return true
    }
    
    func authSpotify() {
        self.pendingSpotifyResponse = true
        let scheme = "softAppSpring2024"
        let (url, state) = SpotifyURLBuilder.url()
        
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: scheme) { callbackURL, error in
            guard error == nil, let callbackURL else {
                NSLog("Callback failed.  \(error?.localizedDescription)  |  callbackURL = nil \(callbackURL == nil)")
                return
            }
            NSLog("Callback successful. URL: \(callbackURL.absoluteString)")
            guard let components = URLComponents(url: callbackURL, resolvingAgainstBaseURL: true) else {
                NSLog("Unable to access url components of callback url.")
                self.pendingSpotifyResponse = false
                return
            }
            let queryItems = components.queryItems
            guard let queryItems, queryItems.filter({ $0.name == "state" }).first?.value == state else {
                NSLog("Invalid state in response url.  provided state: \(state)")
                self.pendingSpotifyResponse = false
                return
            }
            guard let code = queryItems.filter({ $0.name == "code" }).first?.value else {
                NSLog("Code not provided in response url")
                self.pendingSpotifyResponse = false
                return
            }
            
            NSLog("State validated, code queried.  Publishing to BE")
            self.SpotifyCode = code
            
            self.userProfileData.spotifyConsent = true
            self.pendingSpotifyResponse = false
        }
        session.presentationContextProvider = viewController
        session.start()
    }

}
