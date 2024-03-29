//
//  FetchWebSocket.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 3/27/24.
//

import Foundation

enum FetchWebSocket {
    
    private struct WebSocketURL: Codable {
        var url: String
    }
    
    private struct WorkoutMusicChoice: Codable {
        var workoutType: String
        var musicType: String
    }
    
    
    /// Fetches the URL Required to connect to the websocket.  Outbound JSON:
    /// `{
    /// `  “workoutType”: String
    /// `  “musicType”: String
    /// `}
    ///
    /// Expected response JSON:
    /// `{ “url”: String }
    /// - Parameters:
    ///   - email:
    ///   - token:
    ///   - workoutType:
    ///   - musicType:
    /// - Returns: URL object if successful.
    static func fecthWebSocketURL(email: String, token: String, workoutType: String, musicType: String) async throws -> URL {
        
        // make put request with user selected workout type and music selections
        let (data, urlResponse) = try await HTTPRequests.POST(
            urlString: APIConstants.INITIATE_WORKOUT_SESSION(email: email),
            message: WorkoutMusicChoice(workoutType: workoutType, musicType: musicType),
            token: token)
        
        // validate HTTP Response code
        guard let response_status = urlResponse as? HTTPURLResponse else {
            NSLog("Corrupt HTTP Response Code")
            throw FetchError.HTTPResponseError(message: "Corrupt HTTP Response Code")
        }
        guard response_status.statusCode >= 200 && response_status.statusCode < 300 else {
            if response_status.statusCode == 401 {
                NSLog("WebSocket URL: Invalid token")
                throw SocketError.invalidLoginToken
            } else {
                NSLog("WebSocket URL: HTTP Response Code \(response_status.statusCode)")
                throw FetchError.HTTPResponseError(message: "HTTP Response Code: \(response_status.statusCode)")
            }
        }
        
        NSLog("WebSocket URL received: \(String(data: data, encoding: .utf8) ?? "UNABLE TO PARSE")")
        // parse websocket url
        let webSocketUrl = try JSONDecoder().decode(WebSocketURL.self, from: data)
        guard let url = URL(string: webSocketUrl.url) else {
            NSLog("Unable to Parse URL")
            throw SocketError.urlError
        }
        
        NSLog("WebSocket URL retreived. \(webSocketUrl.url)")
        return url
    }
}
