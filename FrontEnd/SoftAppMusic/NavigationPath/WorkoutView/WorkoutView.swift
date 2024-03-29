//
//  WorkoutView.swift
//  SoftAppMusic
//
//  Created by Jordan Gallivan on 3/11/24.
//

import Foundation
import SwiftUI
import CoreBluetooth

struct WorkoutView: View {
    enum Status {
        case empty
        case checkingBluetooth
        case bluetoothConnected
        case checkingPolarConnection
        case polarConnected
        case checkingNotifications
        case notificationsNotEnabled
        case readyToWorkout
        case initiatingWorkout
        case workout
        case error(String)
    }
    
    @EnvironmentObject var appData: AppData
    @ObservedObject var polarController = PolarController()
    @State var bluetoothIsAuthorized = false
    @State var status: Status = .empty
    @State var hrDataSendStatus: Bool = true
    @State var socketAttempts: Int = 0
    private var errorString = ""
    private var workoutType: String
    private var musicType: String
    
    @State private var notificationPending: Bool = false
    
    init(workoutType: String, musicType: String) {
        self.workoutType = workoutType
        self.musicType = musicType
    }
    
    var body: some View {
        Group {
            switch status {
            case .empty:
                WorkoutLoadingView(text: "Initializing Workout")
            case .checkingBluetooth:
                WorkoutLoadingView(text: "Verifying Bluetooth Connection")
            case .bluetoothConnected, .checkingPolarConnection:
                WorkoutLoadingView(text: "Bluetooth active.  Checking HR Monitor Status")
            case .polarConnected:
                WorkoutLoadingView(text: "Heart Rate Monitor detected")
            case .checkingNotifications:
                WorkoutLoadingView(text: "Checking Notification Settings")
            case .notificationsNotEnabled:
                NotificationsRequiredView() {
                    checkNotificationSettings()
                }
            case .readyToWorkout:
                VStack {
                    Spacer()
                    Text("Heart Rate")
                        .font(.subheadline)
                    Text(polarController.hrString)
                        .font(.largeTitle)
                    
                    Spacer()
                    
                    Button("Start Workout") {
                        Task {
                            await initiateWorkout()
                        }
                    }
                        .buttonStyle(DefaultButtonStyling(buttonColor: StyleConstants.DarkBlue,
                                                          borderColor: StyleConstants.DarkBlue,
                                                          textColor: .white))
                }
            case .initiatingWorkout:
                Group {
                    switch polarController.workoutSession.status {
                    case .error(_):
                        ErrorView(pageName: "Error Creating Workout Session",
                                  refreshFunction: initiateWorkout)
                    default:
                        WorkoutLoadingView(text: "Initializing Workout...")
                    }
                }
            case .workout:
                if polarController.notificationPending {
                    Spacer()
                    
                    Text(polarController.workoutSession.pendingNotificationMessage ?? "")
                    
                    Spacer()
                    
                    Button("Continue Current Playlist") {
                        polarController.workoutSession.rejectChanges()
                    }
                    .buttonStyle(DefaultButtonStyling(buttonColor: .red,
                                                      borderColor: .red,
                                                      textColor: .white))
                    
                    Button("Accept New Playlist") {
                        polarController.workoutSession.acceptChanges()
                    }
                    .buttonStyle(DefaultButtonStyling(buttonColor: .green,
                                                      borderColor: .green,
                                                      textColor: .white))
                    Spacer()
                } else {
                    VStack {
                        Spacer()
                        Text("Heart Rate")
                            .font(.subheadline)
                        Text(polarController.hrString)
                            .font(.largeTitle)
                        
                        Spacer()
                        Button("Stop") {
                            Task {
                                await endWorkout()
                            }
                        }
                        .buttonStyle(DefaultButtonStyling(buttonColor: .red,
                                                          borderColor: .red,
                                                          textColor: .white))
                    }
                }
            case .error(let error):
                ErrorView(pageName: error, refreshFunction: initiateWorkout)
            
            }
        }
        .onAppear {
            Task { await self.perforPreWorkoutChecks() }
        }
        .onDisappear {
            Task { await endWorkout() }
        }
            
    }
    
    private func perforPreWorkoutChecks() async {
        self.status = .empty
        
        // check bluetooth status
        checkBluetoothStatus()
        guard case .bluetoothConnected = status else {
            NSLog("Unable to connect to Bluetooth")
            return
        }
        NSLog("Bluetooth check successful")
        
        // check polar connection
        await checkpolarStatus()
        guard case .polarConnected = status else {
            NSLog("Unable to connect to Polar Monitor")
            return
        }
        NSLog("Polar Monitor check successful")
        
        self.status = .checkingNotifications
        // check notification settings
        guard checkNotificationSettings() else {
            NSLog("Notifications Not enabled")
            self.status = .notificationsNotEnabled
            return
        }
        NSLog("Notification check successful")
        
        self.status = .readyToWorkout
    }
    
    private func checkBluetoothStatus() {
        self.status = .checkingBluetooth
        switch CBManager.authorization {
        case .notDetermined, .denied, .restricted:
            self.status = .error("Bluetooth is not authorized for use on this device")
        case .allowedAlways:
            self.status = .bluetoothConnected
        @unknown default:
            self.status = .error("Bluetooth is not authorized for use on this device")
        }
    }
    
    private func checkpolarStatus() async {
        self.status = .checkingPolarConnection
        // establish connection
        polarController.autoConnect()
        do {
            try await Task.sleep(nanoseconds: 3000000000)
        } catch {
            print("errror with timer")
        }
        while case .connecting(_) = polarController.deviceConnectionState { }
        
        guard case .connected(_) = polarController.deviceConnectionState else {
            self.status = .error("Unable to connect to HR Monitor")
            return
        }
        polarController.hrStreamStart()
        self.status = .polarConnected
    }
    
    @discardableResult
    private func checkNotificationSettings() -> Bool {
        var authorized = false
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                authorized = true
                self.status = .readyToWorkout
                return
            }
            authorized = requetAuthorizationForNotifications()
        }
        
        return authorized
    }
    
    private func initiateWorkout() async {
        self.status = .initiatingWorkout
        NSLog("Initiating Workout")
        
        let initStatus = await polarController.startWorkout(
            currentUserEmail: appData.currentUserEmail,
            currentToken: appData.currentToken,
            workoutType: workoutType,
            musicType: musicType)
        
        if let error = initStatus {
            self.status = .error(error.localizedDescription)
            return
        }
        
        self.status = .workout
    }
    
    private func endWorkout() async {
        self.status = .empty
        polarController.endWorkout()
    }
    
}
