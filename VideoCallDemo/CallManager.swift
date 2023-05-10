    //
    //  CallManager.swift
    //  VideoCallDemo
    //
    //  Created by Noye Samuel on 28/04/2023.
    //

import Foundation
import CallKit
import SendBirdCalls
import SwiftUI
import UIKit
import Network
import Combine
import AVFoundation

class CallDelegate: NSObject, DirectCallDelegate, ObservableObject, CXProviderDelegate {
  
    
    
    static let shared = CallDelegate()
    
    let provider: CXProvider
    let callController: CXCallController
    var call: SendBirdCalls.DirectCall?
    private var callTimer: Timer?
    @Published var isOnCall = false
    @Published var showAlert = false
    @Published var codeError = ""
    @Published var request: CodeRequestDTO
    @Published var localVideoView: SendBirdVideoView?
    @Published var remoteVideoView: SendBirdVideoView?
    @Published var userCode = ""
    @Published var isRunning: Bool = false
    @Published var callDuration = 0.0
    var currentCalls: [CXCall] { self.callController.callObserver.calls }
    private var timer: AnyCancellable?
        // format timer to show mm:ss
    var formattedTime: String {
        let seconds = Int(callDuration) % 60
        let minutes = Int(callDuration / 60)
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    override init() {
        request = CodeRequestDTO()
        provider = CXProvider.default
        callController = CXCallController()
        super.init()
        provider.setDelegate(self, queue: nil)
    }
    
    func shouldProcessCall(for callId: UUID) -> Bool {
        return !self.currentCalls.contains(where: { $0.uuid == callId })
    }
    
    func startCall(dialCode: String) {
        print("userCode:",dialCode)
        print("request.codeParam:",request.codeParam())
        print("request.userCode:",request.userCode)
        isRunning = true
        if isConnected() {
                // The user is authenticated, you can start a call now
            let dialParams = DialParams(calleeId: dialCode, isVideoCall: true)
            SendBirdCall.dial(with: dialParams) { call, error in
                if let error = error {
                    print("Error starting call: \(error.localizedDescription)")
                    self.showError(message: error.localizedDescription)
                } else {
                    print("Call started successfully")
                    guard let call = call else {
                        return
                    }
//                    let update = CXCallUpdate()
//                    update.remoteHandle = CXHandle(type: .generic, value: call.callId)
//                    update.hasVideo = true
//
//                    self.provider.reportNewIncomingCall(with: call.callUUID ?? UUID(), update: update) { error in
//                        if let error = error {
//                            print("Failed to report incoming call: \(error.localizedDescription)")
//                        }
//                    }
                    
                    DispatchQueue.main.async {
                            //put the reset function here
                        self.isOnCall = true
                        self.isRunning = false
                    }
                    self.call = call // Store the callId
                    call.delegate = self
                }
            }
        }
        else {
            showError(message: TextsInUse.NoInternet)
        }
    }
    
    func showError(message: String) {
        DispatchQueue.main.async {
            self.isRunning = false
            self.showAlert = true
            self.codeError = message
        }
    }
    
    func endCall() {
        if let call = self.call {
            call.end()
            self.call = nil
        }
    }
    
        // Request transaction
    private func requestTransaction(with action: CXCallAction, completionHandler: ((NSError?) -> Void)?) {
        let transaction = CXTransaction(action: action)
        callController.request(transaction) { error in
            completionHandler?(error as NSError?)
        }
    }

    func didEstablish(_ call: DirectCall) {
        print("Call established")
    }
    
    func didFail(_ call: DirectCall, withError error: Error) {
        print("Call failed with error: \(error.localizedDescription)")
    }
        
        // MARK: - DirectCallDelegate
    func didConnect(_ call: SendBirdCalls.DirectCall) {
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: call.callId)
        update.localizedCallerName = userCode
        _ = UUID(uuidString: call.callId)!
        
        self.call = call // Store the callId
       print("local", call.localVideoView)
        print("remote", call.remoteRecordingStatus)
        call.delegate = self
        
    
                            DispatchQueue.main.async {
                                self.localVideoView = call.localVideoView
                                self.remoteVideoView = call.remoteVideoView
                                call.delegate = self
                                print("view: ",self.localVideoView)
                            }
         
    }
    
    func isConnected() -> Bool {
        let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "InternetConnectionMonitor")
        var isConnected = false
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                isConnected = true
            } else {
                self.showError(message: TextsInUse.NoInternet)
                isConnected = false
            }
        }
            // Wait for the closure to be called and the isConnected variable to be set
        while !isConnected {
            usleep(10000)
        }
        return isConnected
    }
    
    func didStartRinging(_ call: SendBirdCalls.DirectCall) {
        print("Started ringing for call with call ID: \(call.callId)")
        let acceptParams = AcceptParams()
        call.accept(with: acceptParams)
        call.delegate = self
    }

    func didEnd(_ call: SendBirdCalls.DirectCall) {
        print("Call ended")
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: call.callId)
        update.localizedCallerName = request.userCode
        let callUUID = UUID(uuidString: call.callId)!
        provider.reportCall(with: callUUID, endedAt: Date(), reason: .remoteEnded)
    }
    
    func didFailWithError(_ error: Error, for call: SendBirdCalls.DirectCall) {
            // Handle the error
        self.showError(message: error.localizedDescription)
    }
    
    private func startCallTimer() {
        callTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.callDuration += 1
        }
    }
    
    private func stopCallTimer() {
        timer?.cancel()
        callDuration = 0.0
        isRunning = false
    }
    
    func controlTimer() {
        timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
            .sink { _ in
                self.callDuration += 0.1
            }
    }
    
    func switchCameraPosition() {
            //    SendBirdCall.switchCameraPosition()
    }
}

extension CallDelegate: SendBirdCallDelegate, CXCallObserverDelegate {
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
            //
    }
    
    func reportIncomingCall(with callID: UUID, update: CXCallUpdate, completionHandler: ((Error?) -> Void)? = nil) {
        self.provider.reportNewIncomingCall(with: callID, update: update) { (error) in
            completionHandler?(error)
        }
    }
    
    func endCall(for callId: UUID, endedAt: Date, reason: DirectCallEndResult) {
        guard let endReason = reason.asCXCallEndedReason else { return }

        self.provider.reportCall(with: callId, endedAt: endedAt, reason: endReason)
    }
    
    func connectedCall(_ call: DirectCall) {
        self.provider.reportOutgoingCall(with: call.callUUID!, connectedAt: Date(timeIntervalSince1970: Double(call.startedAt)/1000))
    }
    func providerDidReset(_ provider: CXProvider) { }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
            // MARK: SendBirdCalls - SendBirdCall.getCall()
        guard let call = SendBirdCall.getCall(forUUID: action.callUUID) else {
            action.fail()
            return
        }
        
        if call.myRole == .caller {
            provider.reportOutgoingCall(with: call.callUUID!, startedConnectingAt: Date(timeIntervalSince1970: Double(call.startedAt)/1000))
        }
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        guard let call = SendBirdCall.getCall(forUUID: action.callUUID) else {
            action.fail()
            return
        }
        
            //        SendBirdCall.authenticateIfNeed { [weak call] (error) in
            //            guard let call = call, error == nil else {
            //                action.fail()
            //                return
            //            }
        
            // MARK: SendBirdCalls - DirectCall.accept()
        let callOptions = CallOptions(isAudioEnabled: true, isVideoEnabled: call.isVideoCall, useFrontCamera: true)
        let acceptParams = AcceptParams(callOptions: callOptions)
        call.accept(with: acceptParams)
            // UIApplication.shared.showCallController(with: call)
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
            // Retrieve the SpeakerboxCall instance corresponding to the action's call UUID
        guard let call = SendBirdCall.getCall(forUUID: action.callUUID) else {
            action.fail()
            return
        }
        
        var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
        
            // For decline in background
        DispatchQueue.global().async {
            backgroundTaskID = UIApplication.shared.beginBackgroundTask {
                UIApplication.shared.endBackgroundTask(backgroundTaskID)
                backgroundTaskID = .invalid
            }
            
            if call.endResult == DirectCallEndResult.none || call.endResult == .unknown {
                SendBirdCall.authenticateIfNeed { [weak call] (error) in
                    guard let call = call, error == nil else {
                        action.fail()
                        return
                    }
                    
                    call.end {
                        action.fulfill()
                        
                            // End background task
                        UIApplication.shared.endBackgroundTask(backgroundTaskID)
                        backgroundTaskID = .invalid
                    }
                }
            } else {
                action.fulfill()
            }
        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        guard let call = SendBirdCall.getCall(forUUID: action.callUUID) else {
            action.fail()
            return
        }
        
            // MARK: SendBirdCalls - DirectCall.muteMicrophone / .unmuteMicrophone()
        action.isMuted ? call.muteMicrophone() : call.unmuteMicrophone()
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) { }
    
        // In order to properly manage the usage of AVAudioSession within CallKit, please implement this function as shown below.
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        SendBirdCall.audioSessionDidActivate(audioSession)
    }
    
        // In order to properly manage the usage of AVAudioSession within CallKit, please implement this function as shown below.
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        SendBirdCall.audioSessionDidDeactivate(audioSession)
    }
    
}

