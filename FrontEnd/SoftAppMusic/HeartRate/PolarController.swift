/// Copyright © 2021 Polar Electro Oy. All rights reserved.

import Foundation
import SwiftUI
import CoreBluetooth
import PolarBleSdk
import RxSwift

@MainActor
class PolarController: ObservableObject {
    
    private var api = PolarBleApiDefaultImpl.polarImplementation(DispatchQueue.main,
                                                                 features: [PolarBleSdkFeature.feature_hr,
                                                                            PolarBleSdkFeature.feature_polar_sdk_mode,
                                                                            PolarBleSdkFeature.feature_battery_info,
                                                                            PolarBleSdkFeature.feature_device_info,])

    private static var deviceId = "9AD13824"
    
    @Published var workoutSession: WorkoutSession = WorkoutSession()
    @Published var notificationPending: Bool = false
    private var socketAttempts: Int = 0
    @Published var socketSuccess: Bool = true
    
    @Published var currentHr: Int? = nil
    private var timer: Timer? = nil
    var hrSteaming: Bool = true
    private var hrSteamDisposable: Disposable?

    var hrString: String {
        if let currentHr {
            return "\(currentHr)"
        }
        return "--"
    }
    
    @Published var isBluetoothOn: Bool
//    @Published var isBroadcasListenOn: Bool = false // TODO: Determine if necessary
    
    @Published var deviceConnectionState: DeviceConnectionState = DeviceConnectionState.disconnected(deviceId)
    
    @Published var deviceSearch: DeviceSearch = DeviceSearch()
    
    @Published var sdkModeFeature: SdkModeFeature = SdkModeFeature()
    
    @Published var deviceInfoFeature: DeviceInfoFeature = DeviceInfoFeature()
    
    @Published var batteryStatusFeature: BatteryStatusFeature = BatteryStatusFeature()
    
    private var autoConnectDisposable: Disposable?
    
    private var searchDevicesTask: Task<Void, Never>? = nil
    
    @Published var generalMessage: Message? = nil
    private let disposeBag = DisposeBag()
    
    init() {
        self.isBluetoothOn = api.isBlePowered
        
        api.polarFilter(true)
        api.observer = self
        api.deviceFeaturesObserver = self
        api.powerStateObserver = self
        api.deviceInfoObserver = self
//        api.logger = self
    }
    
    /// Initiates the Websocket connection.  If websocket connection is successful, initiates a timer that sends hr data to the websocket every second.
    /// - Parameters:
    ///   - currentUserEmail:
    ///   - currentToken:
    ///   - workoutType:
    ///   - musicType:
    /// - Returns: nil if successful, otherwise the encountered error
    func startWorkout(currentUserEmail: String,
                      currentToken: String,
                      workoutType: String,
                      musicType: String) async -> Error? {
        
        await workoutSession.initiateWorkOutSession(
            email: currentUserEmail,
            token: currentToken,
            workoutType: workoutType,
            musicType: musicType) { self.notificationPending = $0 }
        guard case .connected = workoutSession.status else {
            if case .error(let error) = workoutSession.status {
                return error
            } else {
                return SocketError.unableToConnect
            }
        }
        
        socketSuccess = true
        socketAttempts = 0
        self.timer = Timer(timeInterval: 1, repeats: true) { timer in
            self.sendHrData()
        }
        
        return nil
    }
    
    func testInit() {
        workoutSession.testInit(){ self.notificationPending = $0 }
    }
    
    /// <#Description#>
    func endWorkout() {
        self.timer?.invalidate()
        self.timer = nil
        workoutSession.disconnect()
    }
    
    func sendHrData() {
        guard let hr = self.currentHr else {
            NSLog("HR IS NIL")
//            self.socketSuccess = false
            return
        }
        guard self.workoutSession.sendMessages(message: "\(hr)") else {
            socketAttempts += 1
            self.socketSuccess = socketAttempts >= 10
            return
        }
        socketAttempts = 0
        self.socketSuccess = true
    }
    
    func updateSelectedDevice( deviceId : String) {
        if case .disconnected = deviceConnectionState {
            Task { @MainActor in
                self.deviceConnectionState = DeviceConnectionState.disconnected(deviceId)
            }
        }
    }
    
    func connectToDevice() {
        if case .disconnected(let deviceId) = deviceConnectionState {
            do {
                try api.connectToDevice(deviceId)
            } catch let err {
                NSLog("Failed to connect to \(deviceId). Reason \(err)")
            }
        }
    }
    
    func disconnectFromDevice() {
        if case .connected(let deviceId) = deviceConnectionState {
            do {
                try api.disconnectFromDevice(deviceId)
            } catch let err {
                NSLog("Failed to disconnect from \(deviceId). Reason \(err)")
            }
        }
    }
    
    func autoConnect() {
        autoConnectDisposable?.dispose()
        autoConnectDisposable = api.startAutoConnectToDevice(-55, service: nil, polarDeviceType: nil)
            .subscribe{ e in
                switch e {
                case .completed:
                    NSLog("auto connect search complete")
                case .error(let err):
                    NSLog("auto connect failed: \(err)")
                }
            }
    }
    
    func startDevicesSearch() {
        searchDevicesTask = Task {
            await searchDevicesAsync()
        }
    }
    
    func stopDevicesSearch() {
        searchDevicesTask?.cancel()
        searchDevicesTask = nil
        Task { @MainActor in
            self.deviceSearch.isSearching = DeviceSearchState.success
        }
    }
    
    private func searchDevicesAsync() async {
        Task { @MainActor in
            self.deviceSearch.foundDevices.removeAll()
            self.deviceSearch.isSearching = DeviceSearchState.inProgress
        }
        
        do {
            for try await value in api.searchForDevice().values {
                Task { @MainActor in
                    self.deviceSearch.foundDevices.append(value)
                }
            }
            Task { @MainActor in
                self.deviceSearch.isSearching = DeviceSearchState.success
            }
        } catch let err {
            let deviceSearchFailed = "device search failed: \(err)"
            NSLog(deviceSearchFailed)
            Task { @MainActor in
                self.deviceSearch.isSearching = DeviceSearchState.failed(error: deviceSearchFailed)
            }
        }
    }
    
    func sdkModeToggle() {
        if case .connected(let deviceId) = deviceConnectionState {
            if self.sdkModeFeature.isEnabled {
                api.disableSDKMode(deviceId)
                    .observe(on: MainScheduler.instance)
                    .subscribe{ e in
                        switch e {
                        case .completed:
                            NSLog("SDK mode disabled")
                            Task { @MainActor in
                                self.sdkModeFeature.isEnabled = false
                            }
                        case .error(let err):
                            self.somethingFailed(text: "SDK mode disable failed: \(err)")
                        }
                    }.disposed(by: disposeBag)
            } else {
                api.enableSDKMode(deviceId)
                    .observe(on: MainScheduler.instance)
                    .subscribe{ e in
                        switch e {
                        case .completed:
                            NSLog("SDK mode enabled")
                            Task { @MainActor in
                                self.sdkModeFeature.isEnabled = true
                            }
                        case .error(let err):
                            self.somethingFailed(text: "SDK mode enable failed: \(err)")
                        }
                    }.disposed(by: disposeBag)
            }
        } else {
            NSLog("Device is not connected \(deviceConnectionState)")
            Task { @MainActor in
                self.sdkModeFeature.isEnabled = false
            }
        }
    }
    
    func getSdkModeStatus() async {
        if case .connected(let deviceId) = deviceConnectionState, self.sdkModeFeature.isSupported == true  {
            do {
                NSLog("get SDK mode status")
                let isSdkModeEnabled: Bool = try await api.isSDKModeEnabled(deviceId).value
                NSLog("SDK mode currently enabled: \(isSdkModeEnabled)")
                Task { @MainActor in
                    self.sdkModeFeature.isEnabled = isSdkModeEnabled
                }
            } catch let err {
                Task { @MainActor in
                    self.somethingFailed(text: "SDK mode status request failed: \(err)")
                }
            }
        }
    }
    
    private func somethingFailed(text: String) {
        self.generalMessage = Message(text: "Error: \(text)")
        NSLog("Error \(text)")
    }
    
    func hrStreamStart() {
        if case .connected(let deviceId) = deviceConnectionState {
            self.hrSteaming = true
            self.hrSteamDisposable = api.startHrStreaming(deviceId)
                .subscribe { e in
                    switch e {
                    case .next(let data):
                        self.currentHr = Int(data[0].hr)
                    case .error(let error):
                        NSLog("Hr Stream failed: \(error)")
                        self.currentHr = nil
                    case .completed:
                        NSLog("Hr stream completed")
                        self.currentHr = nil
                    }
                }
        } else {
            self.hrSteaming = false
            NSLog("Device not connected. \(deviceConnectionState)")
        }
    }
    
    func hrStreamStop() {
        self.hrSteaming = false
        self.hrSteamDisposable?.dispose()
    }
}

extension PolarController : PolarBleApiPowerStateObserver {
    func blePowerOn() {
        NSLog("BLE ON")
        Task { @MainActor in
            isBluetoothOn = true
        }
    }
    
    func blePowerOff() {
        NSLog("BLE OFF")
        Task { @MainActor in
            isBluetoothOn = false
        }
    }
}

extension PolarController : PolarBleApiObserver {
    func deviceConnecting(_ polarDeviceInfo: PolarDeviceInfo) {
        NSLog("DEVICE CONNECTING: \(polarDeviceInfo)")
        Task { @MainActor in
            self.deviceConnectionState = DeviceConnectionState.connecting(polarDeviceInfo.deviceId)
        }
    }
    
    func deviceConnected(_ polarDeviceInfo: PolarDeviceInfo) {
        NSLog("DEVICE CONNECTED: \(polarDeviceInfo)")
        Task { @MainActor in
            self.deviceConnectionState = DeviceConnectionState.connected(polarDeviceInfo.deviceId)
            self.hrStreamStart()
        }
    }
    
    func deviceDisconnected(_ polarDeviceInfo: PolarDeviceInfo, pairingError: Bool) {
        NSLog("DISCONNECTED: \(polarDeviceInfo)")
        Task { @MainActor in
            self.hrStreamStop()
            self.deviceConnectionState = DeviceConnectionState.disconnected(polarDeviceInfo.deviceId)
            self.sdkModeFeature = SdkModeFeature()
            self.deviceInfoFeature = DeviceInfoFeature()
            self.batteryStatusFeature = BatteryStatusFeature()
        }
    }
}

extension PolarController : PolarBleApiDeviceInfoObserver {
    func batteryLevelReceived(_ identifier: String, batteryLevel: UInt) {
        NSLog("battery level updated: \(batteryLevel)")
        Task { @MainActor in
            self.batteryStatusFeature.batteryLevel = batteryLevel
        }
    }
    
    func disInformationReceived(_ identifier: String, uuid: CBUUID, value: String) {
        NSLog("dis info: \(uuid.uuidString) value: \(value)")
        if(uuid == BleDisClient.SOFTWARE_REVISION_STRING) {
            Task { @MainActor in
                self.deviceInfoFeature.firmwareVersion = value
            }
        }
    }
}

extension PolarController : PolarBleApiDeviceFeaturesObserver {

    func bleSdkFeatureReady(_ identifier: String, feature: PolarBleSdk.PolarBleSdkFeature) {
        NSLog("Feature is ready: \(feature)")
        switch(feature) {
            
        case .feature_hr:
            //nop
            break
        case .feature_battery_info:
            Task { @MainActor in
                self.batteryStatusFeature.isSupported = true
            }
        case .feature_device_info:
            Task { @MainActor in
                self.deviceInfoFeature.isSupported = true
            }
        case  .feature_polar_sdk_mode:
            Task { @MainActor in
                self.sdkModeFeature.isSupported = true
            }
            Task {
                await getSdkModeStatus()
            }
        default:
            break
        }
    }
    
    // depreciated
    func hrFeatureReady(_ identifier: String) {
        NSLog("HR Ready")
    }
    // depreciated
    func ftpFeatureReady(_ identifier: String) {
        NSLog("FTP Ready")
    }
    // depreciated
    func streamingFeaturesReady(_ identifier: String, streamingFeatures: Set<PolarBleSdk.PolarDeviceDataType>) {
        NSLog("Streaming Features Ready")
    }
}
    
