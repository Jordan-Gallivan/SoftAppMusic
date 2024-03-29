//
//  PostRequest.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/16/24.
//

import Foundation

enum HTTPRequests {
    static func POST<T: Encodable>(urlString: String, message: T, token: String?) async throws -> (Data, URLResponse) {
        let data = try JSONEncoder().encode(message)
        return try await makeRequest(urlString: urlString, token: token, data: data)
    }
    
    static func GET(urlString: String, token: String?) async throws -> (Data, URLResponse) {
        return try await makeRequest(urlString: urlString, token: token)
    }
    
    private static func makeRequest(urlString: String, token: String?, data: Data? = nil ) async throws -> (Data, URLResponse) {
        let url = URL(string: urlString)
        guard let url else {
            NSLog("ERROR ESTABLISHING URL")
            throw FetchError.UrlError(message: "ERROR ESTABLISHING URL: \(urlString)")
        }
        var request = URLRequest(url: url)
        
        if let data {
            request.httpBody = data
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
        }
        
        if let token {
            request.setValue( "Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let (responseData, response) = try await URLSession.shared.data(for: request)
        
        return (responseData, response)
    }
    
    static func validateHTTPResponseCode(_ urlResponse: URLResponse, errorString: String) -> Bool {
        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            NSLog("\(errorString) invalid HTTP Response.")
            return false
        }
        guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
            NSLog("\(errorString) invalid HTTP Response.")
            return false
        }
        return true
    }
}
