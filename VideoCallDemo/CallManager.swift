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

//import SendBirdUIKit

class CallDelegate: NSObject, DirectCallDelegate, ObservableObject {
    let provider = CXProvider(configuration: CXProviderConfiguration())
    let callController = CXCallController()
    var call: SendBirdCalls.DirectCall?
    private var callTimer: Timer?
    @Published var isOnCall = false
    @Published var showAlert = false
    @Published var callDuration = 0
    @Published var codeError = ""
    @Published var request: CodeRequestDTO
    @Published var localVideoView: UIView!
    @Published var remoteVideoView: UIView!
    @Published var userCode = ""
    
    override init() {
        request = CodeRequestDTO()
        super.init()
    }
    
    func startCall(withUser user: String) {
        
        if isConnected() {
            let params = AuthenticateParams(userId: "12345", accessToken: "0de9e4ffed8688f54c51e4e29590ced4e47bb304")
            print(user)
            SendBirdCall.authenticate(with: params) { (user1, error) in
                guard error == nil else {
                    DispatchQueue.main.async {
                        self.showAlert = true
                        self.codeError = error?.localizedDescription ?? "Unknown"
                        print(error?.localizedDescription ?? "default value")
                    }
                    return
                }
                
                    // The user is authenticated, you can start a call now
                print("usercode: ",self.userCode)
                let dialParams = DialParams(calleeId: user, isVideoCall: true)
                SendBirdCall.dial(with: dialParams) { call, error in
                    if let error = error {
                        print("Error starting call: \(error.localizedDescription)")
                        DispatchQueue.main.async {
                            self.showAlert = true
                            self.codeError = error.localizedDescription
                        }
                    } else {
                        print("Call started successfully")
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                //put the reset function here
                            self.isOnCall = true
                        }
                        self.call = call // Store the callId
                        call?.delegate = self
                    }
                }
            }
        }
        else {
            showError(message: TextsInUse.NoInternet)
        }
    }

    func showError(message: String) {
        DispatchQueue.main.async {
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
    
        // MARK: - DirectCallDelegate
    
    func didConnect(_ call: SendBirdCalls.DirectCall) {
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: call.callId)
        update.localizedCallerName = userCode
        let callUUID = UUID(uuidString: call.callId)!
        provider.reportNewIncomingCall(with: callUUID, update: update) { error in
            if let error = error {
                    // Handle the error
                self.showError(message: error.localizedDescription)
            } else {
                    // Call successfully reported
                    // Get the local and remote video views
                DispatchQueue.main.async {
                    self.localVideoView = call.localVideoView
                    self.remoteVideoView = call.remoteVideoView
                    call.delegate = self
                    print("view: ",self.localVideoView)
                }
            }
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
        call.accept(with: <#AcceptParams#>)
        call.delegate = self
    }
    func didEnd(_ call: SendBirdCalls.DirectCall) {
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .generic, value: call.callId)
        update.localizedCallerName = userCode
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
        callTimer?.invalidate()
        callTimer = nil
    }
    
//    func switchCameraPosition() {
//        SendBirdCall.switchCameraPosition()
//    }

    
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        guard let uuid = UUID(uuidString: call.uuid.uuidString) else { return }
        
        if call.hasEnded {
                // The call has ended
            isOnCall = false
            stopCallTimer()
            callDuration = 0
            
        } else if call.isOutgoing {
                // The call is outgoing
                // Update UI to show that the user is currently on a call and display the duration of the call
                // You can use a timer to update the duration of the call
            if call.hasConnected == false {
                    // The outgoing call is being dialled
                DispatchQueue.main.async {
                    self.isOnCall = true
                    self.startCallTimer()
                    SendBirdCall.dial(with: DialParams(calleeId: self.request.codeParam())) { directCall, error in
                        if let directCall = directCall {
                            let handle = CXHandle(type: .generic, value: directCall.callId)
                            let startCallAction = CXStartCallAction(call: uuid, handle: handle)
                            let transaction = CXTransaction(action: startCallAction)
                            self.callController.request(transaction) { error in
                                if let error = error {
                                        // Handle the error
                                    self.showError(message: error.localizedDescription)
                                }
                            }
                            DispatchQueue.main.async {
                                self.call = directCall
                                self.call?.delegate = self
                            }
                        } else {
                                // Handle the error
                            self.showError(message: error?.localizedDescription ?? "Unknown error")
                        }
                    }
                }
            }
        } else if call.hasConnected {
                // The call has connected
        } else {
                // The call state is unknown
        }
    }
}

struct HangupParams {
    let call: CXCall
}
