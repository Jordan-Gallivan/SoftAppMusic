//
//  FetchWebSocket.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 3/27/24.
//

import Foundation

enum FetchWebSocket {
    
    private struct WebSocketToken: Codable {
        var wsToken: String
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
    static func fecthWebSocketToken(email: String, token: String) async throws -> String {
        
        // make put request with user selected workout type and music selections
        let (data, urlResponse) = try await HTTPRequests.GET(
            urlString: APIConstants.AUTH_WEBSOCKET(email: email),
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
        
        NSLog("WebSocket Token received: \(String(data: data, encoding: .utf8) ?? "UNABLE TO PARSE")")
        // parse websocket url
        let webSocketToken = try JSONDecoder().decode(WebSocketToken.self, from: data).wsToken
        
        NSLog("WebSocket Token retreived")
        return webSocketToken
    }
}
