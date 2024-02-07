//
//  CreateUserView.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/5/24.
//

import Foundation
import SwiftUI

/// TODO:
///     o async enum
///         - loading(pageName: String)
///     o async load struct
///     o context
///     o environment app data
///     o 
///
///

struct CreateUserView: View {
    @State var userProfileData = UserProfileData()
    
    var body: some View {
        Form {
            TextField("First Name", text: $userProfileData.firstName)
            TextField("Last Name", text: $userProfileData.lastName)
            Button(action: {
                // MARK: add action to pop-up alert for consent
            }, label: {
                Text("Spotify Consent")
            })
            // MARK: music preferences Bottom form
            // MARK: work out types Bottom Form
            Button(action: {
                
            }, label: {
                Text("Get Moving")
            })
        }
    }
    
}
