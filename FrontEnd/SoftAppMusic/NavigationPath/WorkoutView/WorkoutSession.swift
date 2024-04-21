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
    @Published var messages = [String]()
    private var socket: URLSessionWebSocketTask?
    private var pendingSocketAuthorization = true
    private var notificationNumber: Int = 0
    private var currentRequest: Int = 0
//    @Published var notificationPending: Bool = false
    @Published var pendingNotificationMessage: String? = nil
    private var notificationPendingTrigger: (Bool) -> Void = { _ in }
    private var notificationTimeLimit: Double = 0.0
    
    override init() {
        super.init()
        let center = UNUserNotificationCenter.current()
        center.delegate = self
    }
    
    deinit {
        socket?.cancel()
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
                                notificationTimeLimit: Double,
                                notificationPendingTrigger: @escaping (Bool) -> Void ) async {
        self.notificationTimeLimit = notificationTimeLimit
        self.notificationPendingTrigger = notificationPendingTrigger
        self.status = .connecting
        
        do {
            NSLog("Fetching WebSocket Token")
            let singleUseToken = try await FetchWebSocket.fecthWebSocketToken(email: email, token: token)
//            NSLog("URL to fetch single use token: \(APIConstants.AUTH_WEBSOCKET(email: email))")
            guard let url = URL(string: APIConstants.INITIATE_WORKOUT_SESSION(email: email, token: singleUseToken)) else {
                NSLog("Error building url: \(APIConstants.INITIATE_WORKOUT_SESSION(email: email, token: singleUseToken))")
                status = .error(SocketError.urlError)
                return
            }
            NSLog("URL to connect to websocket: \(url)")
//            return
//            #warning("REMOVE ABOVE AFTER TESTING")
            let data = try JSONEncoder().encode(WorkoutMusicChoice(workoutType: workoutType, musicType: musicType))
            // initiate websocket connection
            NSLog("Connecting to WebSocket")
            await self.connect(email: email, token: token, url: url, data: data)
        } catch {
            status = .error(error)
        }
    }
    
    private func connect(email: String,
                         token: String,
                         url: URL,
                         data: Data) async {
        
        var request = URLRequest(url: url)
        socket = URLSession.shared.webSocketTask(with: request)
        
        guard socket != nil else {
            NSLog("Unable to connect to WebSocket")
            self.status = .error(SocketError.unableToConnect)
            return
        }
        
        NSLog("Connected to WebSocket")
        socket?.resume()

        NSLog("Receiving Messages")
        self.receiveMessages()
        NSLog("Pausing until handshake complete")
        while self.pendingSocketAuthorization { }
        NSLog("Handshake complete.  Initiating Workout.")
        self.sendMessages(data: data, message: "\(String(data: data, encoding: .utf8) ?? "Initial Data")")
        
        self.status = .connected
            
    }
    
    /// Closes the websocket connection
    func disconnect() {
        NSLog("Disconnecting from WebSocket")
        self.socket?.cancel()
        self.socket = nil
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
                    Task {
                        await self.processMessage(Data(messageString.utf8))
                    }
                    self.receiveMessages()
                @unknown default:
                    print("unknown")
                }
            case .failure(let error):
                NSLog("Receive Error. \(error.localizedDescription)")
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + notificationTimeLimit) {
            if self.pendingNotificationMessage != nil {
                print("deactivate initiated")
                self.deactivateNotification(id: id)
                self.rejectChanges()
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
            NSLog("----> Message received: \(String(data: data, encoding: .utf8) ?? "DEFAULTVALUE") <----")
            let socketMessage = try JSONDecoder().decode(WebSocketMessage.self, from: data)
            if socketMessage.message == "success" {
                self.pendingSocketAuthorization = false
                return
            }
            self.currentRequest = socketMessage.request
            
            var message = ""
            switch socketMessage.message {
            case "slow":
                message = "slowing down"
            case "fast":
                message = "speeding up"
            default:
                NSLog("message not in correct format: \(socketMessage.message)")
                return
            }
            await self.notifyUser(message: message)
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
        guard let data = buildMessage(message: "reject") else {
            return
        }
        self.sendMessages(data: data, message: "reject")
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
