//
//  CallViewModel.swift
//  VideoCallDemo
//
//  Created by Noye Samuel on 04/05/2023.
//

import Foundation
import SendBirdCalls
import CallKit
import SwiftUI

class ViewModel: NSObject, ObservableObject, CXProviderDelegate, DirectCallDelegate {

    private var provider: CXProvider?
    private var call: DirectCall?
    private var callUUID: UUID?
    @Published var isMicrophoneMuted = false
    
    override init() {
        super.init()
        self.provider = CXProvider(configuration: CXProviderConfiguration())
        self.provider?.setDelegate(self, queue: nil)
    }
    
    func callUser(userId: String, isVideoCall: Bool) {
        let callOptions = CallOptions(isAudioEnabled: !isVideoCall, isVideoEnabled: isVideoCall)
        let dialParams = DialParams(calleeId: userId, isVideoCall: isVideoCall, callOptions: callOptions)
        SendBirdCall.dial(with: dialParams) { [weak self] call, error in
            if let error = error {
                    // Handle error
                return
            }
            self?.call = call
            self?.call?.delegate = self
            if let callIdString = call?.callId {
                self?.callUUID = UUID(uuidString: callIdString)
            }
        }
    }

    func endCall() {
        self.call?.end() { [weak self] in
            self?.call = nil
            self?.provider?.reportCall(with: self?.callUUID ?? UUID(), endedAt: nil, reason: .remoteEnded)
        }
    }
    
    func toggleMicrophoneMute() {
        if self.isMicrophoneMuted {
            self.call?.unmuteMicrophone()
        } else {
            self.call?.muteMicrophone()
        }
        self.isMicrophoneMuted.toggle()
    }

    
    func didConnect(_ call: DirectCall) {
            // Call connected
    }
    
    func didEnd(_ call: DirectCall) {
            // Call ended
        self.call = nil
        self.provider?.reportCall(with: self.callUUID ?? UUID(), endedAt: nil, reason: .remoteEnded)
    }
    
    func didRemoteAudioSettingsChange(_ call: DirectCall) {
            // Remote audio settings changed
    }
    
    func didRemoteVideoSettingsChange(_ call: DirectCall) {
            // Remote video settings changed
    }
    
    func didUpdate(_ call: DirectCall, isVideoEnabled: Bool) {
            // Local video enabled/disabled
    }
    
        // MARK: - CXProviderDelegate methods
    
    func providerDidReset(_ provider: CXProvider) {
        self.call = nil
    }
    
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        self.callUUID = action.callUUID
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type: .phoneNumber, value: "Incoming Call")
        provider.reportNewIncomingCall(with: action.callUUID, update: update) { error in
            if let error = error {
                    // Handle error
            }
        }
        action.fulfill()
    }
    
    func answerCall() {
        let acceptParams = AcceptParams(callOptions: CallOptions(isAudioEnabled: true, isVideoEnabled: true))
        self.call?.accept(with: acceptParams)
    }
    

    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
            answerCall()
            action.fulfill()
        }
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
            action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
            action.fulfill()
}
