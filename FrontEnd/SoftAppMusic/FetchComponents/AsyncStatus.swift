//
//  AsyncStatus.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 2/5/24.
//

import Foundation

enum AsyncStatus<Success> {
    case empty
    case inProgress(page: String)
    case success(Success)
    case failure(Error)
}
