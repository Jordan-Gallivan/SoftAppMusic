//
//  FetchWorkoutTypes.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/26/24.
//

import Foundation
import SwiftUI

enum FetchWorkoutTypes {
    private struct workoutTypes: Decodable {
        let types: [String]
    }
    
    static func fetchUpdatedWorkoutTypes() async -> [String]? {
        return ["HIIT", "Tempo Run", "Long Run", "WeightLifting"]
        do {
            let (data, urlResponse) = try await HTTPRequests.GET(urlString: "\(APIConstants.API_URL)/\(APIConstants.WORKOUT_TYPES)", token: nil)
            guard let httpResponse = urlResponse as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                return nil
            }
            
            let updatedWorkoutTypes = try JSONDecoder().decode(workoutTypes.self, from: data)
            return updatedWorkoutTypes.types
        } catch  {
            NSLog("Error Fetching workout types.  \(error.localizedDescription)")
            return nil
        }
    }
}
