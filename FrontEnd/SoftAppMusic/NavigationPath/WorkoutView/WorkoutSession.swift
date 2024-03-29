//
//  WorkoutSession.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 3/11/24.
//

import Foundation
import SwiftUI
import UserNotifications

enum SocketStatus {
    case empty
    case connecting
    case connected
    case disconnected
    case error(Error)
}
enum SocketError: Error {
    case urlError
    case invalidLoginToken
    case unableToConnect
}

class WorkoutSession: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    @Published var status: SocketStatus = .empty
    private var socketToken: String = ""
    @Published var messages = [String]()
    private var socket: URLSessionWebSocketTask?
    private var notificationNumber: Int = 0
//    @Published var notificationPending: Bool = false
    @Published var pendingNotificationMessage: String? = nil
    private var notificationPendingTrigger: (Bool) -> Void = { _ in }
    
    override init() {
        super.init()
        let center = UNUserNotificationCenter.current()
        center.delegate = self
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        return [.banner]
    }
    
    @MainActor
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let identifier = response.actionIdentifier
        if identifier == "acceptButton" {
            self.acceptChanges()
        } else if identifier == "continueButton" {
            self.rejectChanges()
        }
    }
    
    func testInit(notificationPendingTrigger: @escaping (Bool) -> Void ) {
        self.notificationPendingTrigger = notificationPendingTrigger
    }
    
    /// Connects to the websocket by first fetching the url and then initiating a websocket connection.  Outbound JSON:
    /// `{`
    /// `  "workoutType": "exampleWorkoutType",
    /// `  "musicType": "exampleMusicType",
    /// `}`
    /// Expected response JSON:
    /// `{`
    /// `  "url": "websocketURL"
    /// `}`
    ///
    /// - Parameters:
    ///   - email: current user's email
    ///   - token: current token
    ///   - workoutType: string description of selected workout
    ///   - musicType: string description of the selected music
    func initiateWorkOutSession(email: String,
                                token: String,
                                workoutType: String,
                                musicType: String,
                                notificationPendingTrigger: @escaping (Bool) -> Void ) async {
        
        self.notificationPendingTrigger = notificationPendingTrigger
        self.status = .connecting
        
        do {
            NSLog("Fetching WebSocket URL")
            let url = try await FetchWebSocket.fecthWebSocketURL(email: email, token: token, workoutType: workoutType, musicType: musicType)
            // initiate websocket connection
            NSLog("Connecting to WebSocket")
            self.connect(url)
        } catch {
            status = .error(error)
        }
    }
    
    private func connect(_ url: URL) {
        var request = URLRequest(url: url)
        request.setValue( "Bearer \(socketToken)", forHTTPHeaderField: "Authorization")
        socket = URLSession.shared.webSocketTask(with: request)
        guard socket != nil else {
            NSLog("Unable to connect to WebSocket")
            self.status = .error(SocketError.unableToConnect)
            return
        }
        
        NSLog("Connected to WebSocket")
        socket?.resume()
        self.status = .connected
        NSLog("Receiving Messages")
        self.receiveMessages()
    }
    
    /// Closes the websocket connection
    func disconnect() {
        NSLog("Disconnecting from WebSocket")
        self.socket?.cancel()
    }

    private func receiveMessages() {
        guard let socket = self.socket else { return }
        
        socket.receive { result in
            switch result {
            case .success(let message):
                self.status = .connected
                switch message {
                case .data(let data):
                    let str = String(decoding: data, as: UTF8.self)
                    self.messages.append(str)
                    Task {
                        await self.notifyUser(message: str)
                    }
                    self.receiveMessages()
                case .string(let messageString):
                    self.messages.append(messageString)
                    NSLog("----> Message received: \(messageString) <----")
                    Task {
                        await self.notifyUser(message: messageString)
                    }
                    self.receiveMessages()
                @unknown default:
                    print("unknown")
                }
            case .failure(_):
                print("failure")
            }
        }
    }
    
    func notifyUser(message: String) async {
        let center = UNUserNotificationCenter.current()
        
        // configure actions for notificaitons
        let groupID = "listActions"
        let actionContinue = UNNotificationAction(identifier: "continueButton", 
                                                  title: "Continue Current Playlist",
                                                  options: .destructive)
        let actionAcceptChanges = UNNotificationAction(identifier: "acceptButton", 
                                                       title: "Accept New Playlist",
                                                       options: .destructive)
        let category = UNNotificationCategory(identifier: groupID,
                                              actions: [actionContinue, actionAcceptChanges],
                                              intentIdentifiers: [],
                                              options: [])
        
        
        // configure content for notification
        let content = UNMutableNotificationContent()
        content.title = "Music Change Reqeust"
        content.body =
        """
        Looks like you're \(message).
        Keep the original Playlist?
        """
        content.sound = UNNotificationSound.default
        content.categoryIdentifier = groupID
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        notificationNumber += 1
        let id = "notification-\(notificationNumber)"
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        do {
            try await center.add(request)
        } catch {
            NSLog(error.localizedDescription)
        }
        
        self.notificationPendingTrigger(true)
        
        self.pendingNotificationMessage = content.body

        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            if self.pendingNotificationMessage != nil {
                print("deactivate initiated")
                self.deactivateNotification(id: id)
            }
        }
    }
    
    private func deactivateNotification(id: String = "") {

        self.notificationPendingTrigger(false)
        self.pendingNotificationMessage = nil
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    func acceptChanges() {
        NSLog("User accepted changes")
        self.deactivateNotification()
//        self.sendMessages(message: "ACCEPT")
        #warning("remove after testing")
    }
    
    func rejectChanges() {
        NSLog("User rejected changes")
        self.deactivateNotification()
    }
    
    /// Sends provided message via websocket
    /// - Parameter message: string message to be sent.  Must be .utf8 encodable
    /// - Returns: true if message is successfully sent.  
    @discardableResult
    func sendMessages(message: String) -> Bool {
        NSLog("...sending \(message)")
        guard let data = message.data(using: .utf8) else {
            NSLog("Error converting message")
            return false
        }
        var success = true
        socket?.send(.string(message)) { error in
            if let error {
                NSLog("Error sending message. \(error.localizedDescription)")
                success = false
            }
        }
        return success
    }
    
}
