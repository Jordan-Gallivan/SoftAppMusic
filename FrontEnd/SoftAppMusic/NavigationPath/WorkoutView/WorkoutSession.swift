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
    
    private struct WorkoutMusicChoice: Codable {
        var workoutType: String
        var musicType: String
    }
    
    private struct WebSocketMessage: Codable {
        var request: Int
        var message: String
    }
    
    @Published var status: SocketStatus = .empty
    private var socketToken: String = ""
    @Published var messages = [String]()
    private var socket: URLSessionWebSocketTask?
    private var notificationNumber: Int = 0
    private var currentRequest: Int = 0
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
            guard let url = URL(string: APIConstants.INITIATE_WORKOUT_SESSION(email: email)) else {
                NSLog("Error creating url")
                return
            }
            let data = try JSONEncoder().encode(WorkoutMusicChoice(workoutType: workoutType, musicType: musicType))
            // initiate websocket connection
            NSLog("Connecting to WebSocket")
            self.connect(email: email, token: token, url: url, data: data)
        } catch {
            status = .error(error)
        }
    }
    
    private func connect(email: String,
                         token: String,
                         url: URL,
                         data: Data) {
        
        var request = URLRequest(url: url)
        request.setValue( "Bearer \(socketToken)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = data
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        socket = URLSession.shared.webSocketTask(with: request)
        guard socket != nil else {
            NSLog("Unable to connect to WebSocket")
            self.status = .error(SocketError.unableToConnect)
            return
        }
        NSLog("\(socket?.state)")
        socket?.sendPing() { error in
            if let error {
                NSLog("Ping Error: \(error.localizedDescription)")
            } else {
                NSLog("Ping successful!")
            }
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
                    Task {
                        await self.processMessage(data)
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
            case .failure(let error):
//                print("Receive Error. \(error.localizedDescription)")
                self.receiveMessages()
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
    
    private func processMessage(_ data: Data) async {
        do {
            let socketMessage = try JSONDecoder().decode(WebSocketMessage.self, from: data)
            self.currentRequest = socketMessage.request
            await self.notifyUser(message: socketMessage.message)
        } catch {
            NSLog("error processing message: \(error.localizedDescription)")
        }
    }
    
    func acceptChanges() {
        NSLog("User accepted changes")
        self.deactivateNotification()
        guard let data = buildMessage(message: "accept") else {
            return
        }
        self.sendMessages(data: data, message: "accept")
//        #warning("remove after testing")
    }
    
    func rejectChanges() {
        NSLog("User rejected changes")
        self.deactivateNotification()
        #warning("come back here")
    }
    
    private func buildMessage(message: String) -> Data? {
        do {
            let data = try JSONEncoder().encode(WebSocketMessage(request: self.currentRequest, message: message))
            return data
        } catch {
            NSLog("Error building message: \(message).  Error: \(error.localizedDescription)")
            return nil
        }
        
    }
    
    /// Sends provided message via websocket
    /// - Parameter message: string message to be sent.  Must be .utf8 encodable
    /// - Returns: true if message is successfully sent.  
    @discardableResult
    func sendMessages(data: Data, message: String) -> Bool {
        NSLog("...sending \(message)")
        var success = true
        socket?.send(.data(data)) { error in
            if let error {
                NSLog("Error sending message. \(error.localizedDescription)")
                success = false
            }
        }
        return success
    }
    
}
