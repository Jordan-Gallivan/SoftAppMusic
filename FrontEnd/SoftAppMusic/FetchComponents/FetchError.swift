//
//  FetchErrors.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/13/24.
//

import Foundation

enum FetchError: Error {
    case UrlError(message: String)
    case HTTPResponseError(message: String)
    case InvalidParsing(message: String)
}
