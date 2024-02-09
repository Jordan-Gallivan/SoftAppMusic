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
    @Published var userData: UserProfileData = UserProfileData()
    
    
}
