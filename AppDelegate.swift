//
//  AppDelegate.swift
//  VideoCallDemo
//
//  Created by Noye Samuel on 08/05/2023.
//

import Foundation

import SwiftUI
import SendBirdCalls
import UIKit
import CallKit
import PushKit
import AVFAudio


class AppDelegate: UIResponder, UIApplicationDelegate, CXProviderDelegate, CXCallObserverDelegate, UNUserNotificationCenterDelegate, SendBirdCallDelegate, DirectCallDelegate {
    
    var pushRegistry: PKPushRegistry?
    var window: UIWindow?
    var provider: CXProvider?
    var callController: CXCallController?
    let callbackQueue = DispatchQueue(label: "QUEUE_LABEL")
    let appID = TextsInUse.AppID
    let token = TextsInUse.Token
    let userId = TextsInUse.UserID
    var currentCall: DirectCall?
    var callUUIDMap: [UUID: DirectCall] = [:]
    var callKitCompletionHandler: ((Bool) -> Void)?
    
    func providerDidReset(_ provider: CXProvider) {
            //
    }
    
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
            //
    }
    
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
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
      //  SendBirdCall.configureAudioSession()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
            // Handle answering incoming call here
//        guard let call = currentCall else {
//            action.fail()
//            return
//        }
        callKitCompletionHandler?(true)
        action.fulfill()
    }
    
       //  Handle APNs device token registration failure
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications. Error: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
  
            // Initialize Sendbird SDK with your application ID
        SendBirdCall.configure(appId: appID)
        SendBirdCall.executeOn(queue: self.callbackQueue)
            //

        
        
        let callObserver = CXCallObserver()
        callObserver.setDelegate(self, queue: nil)
        SendBirdCall.application(application, didReceiveRemoteNotification: [:])
        
        let params = AuthenticateParams(userId: userId, accessToken: token)
        SendBirdCall.authenticate(with: params) { (user, error) in
            guard error == nil else { return }
                // Register for push notifications
            self.voipRegistration()
        }
            // Register for remote notifications
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                        // Register for push notifications
                    application.registerForRemoteNotifications()
                }
            }
        }
        
        SendBirdCall.addDelegate(self, identifier: "YOUR_UNIQUE_IDENTIFIER")
        
       
        callController = CXCallController()
        let providerDelegate = CallDelegate()
        provider = CXProvider.default
        provider?.setDelegate(providerDelegate, queue: nil)
        
        SBCLogger.setLoggerLevel(.error)

        return true
    }
    
        // Handle APNs device token registration
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
            // Register device token with SendbirdCalls
        
        if  UserDefaults.standard.voipPushToken == nil {
            SendBirdCall.registerVoIPPush(token: deviceToken) { error in
                if let error = error {
                    print("Error registering VoIP push token: \(error.localizedDescription)")
                } else {
                    UserDefaults.standard.voipPushToken = deviceToken
                    print("VoIP push token registered successfully")
                }
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {

            // Get the payload from the notification
        let payload = response.notification.request.content.userInfo

            // Check if the notification is for a call
        if let callPayload = payload["sendbird"] as? [String: Any], let isCall = callPayload["call"] as? [String: Any] {

                // Handle incoming call notification
            if let uuidString = isCall["call_id"] as? String,
               let uuid = UUID(uuidString: uuidString),
               let call = SendBirdCall.getCall(forUUID: uuid) {
                    // Show incoming call screen
                DispatchQueue.main.async {
                        // Handle incoming call notification
                    call.startVideo()
                    CallDelegate.shared.localVideoView = call.localVideoView
                    CallDelegate.shared.remoteVideoView = call.remoteVideoView
                }
                                call.delegate = self
                                self.currentCall = call
            }

        }

        completionHandler()
    }

    
//    func didStartRinging(_ call: DirectCall) {
//        let callUUID = UUID()
//        callUUIDMap[callUUID] = call
//
//        let update = CXCallUpdate()
//        update.remoteHandle = CXHandle(type: .generic, value: call.caller?.userId ?? "Unknown2")
//        update.hasVideo = call.isVideoCall
//        update.localizedCallerName = call.caller?.nickname ?? "Unknown1"
//        self.provider?.reportNewIncomingCall(with: callUUID, update: update) { error in
//            if let error = error {
//                print("Failed to report incoming call: \(error.localizedDescription)")
//                return
//            }
//
//            call.delegate = self
//            self.currentCall = call
//        }
//    }
}

    // MARK: VoIP Push
extension AppDelegate: PKPushRegistryDelegate {
    func didConnect(_ call: SendBirdCalls.DirectCall) {
        
    }
    
    func didEnd(_ call: SendBirdCalls.DirectCall) {
        var callId: UUID = UUID()
        if let callUUID = call.callUUID {
            callId = callUUID
        }
        CallDelegate.shared.endCall(for: callId, endedAt: Date(), reason: call.endResult)
    }
    
    func voipRegistration() {
        let voipRegistry = PKPushRegistry(queue: DispatchQueue.main)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = Set([.voIP])
        self.pushRegistry = voipRegistry
    }
    
        // MARK: - SendBirdCalls - Registering push token.
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
                   UserDefaults.standard.voipPushToken = pushCredentials.token
            //        print("Push token is \(pushCredentials.token.toHexString())")
            //
       // UserDefaults.standard.voipPushToken = pushCredentials.token
        print("Push token is \(pushCredentials.token.toHexString())")
        SendBirdCall.registerVoIPPush(token: pushCredentials.token, unique: true) { error in
            guard error == nil else { return }
        }
    }
    
        // MARK: - SendBirdCalls - Receive incoming push event
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        SendBirdCall.pushRegistry(registry, didReceiveIncomingPushWith: payload, for: type, completionHandler: nil)
    }
    
        // MARK: - SendBirdCalls - Handling incoming call
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        var caller = ""
        var callUUID = UUID()
        if let sendBirdData = payload.dictionaryPayload["sendbird"] as? [String: Any],
           let calleeUserId = sendBirdData["caller_id"] as? String {
            caller = calleeUserId
            callUUID = UUID(uuidString: caller) ?? UUID()
        }

            let update = CXCallUpdate()
            update.remoteHandle = CXHandle(type: .generic, value: caller)
            update.hasVideo = true
        provider?.reportNewIncomingCall(with: callUUID, update: update) { error in
            if error == nil {
                    // Successfully reported incoming call to CallKit
                print("caller:", caller)
                        // Handle call accepted/rejected by user
                    self.callKitCompletionHandler = { accepted in
                        if accepted {
                                // User accepted the call
                            print("User accepted the call")
                        } else {
                                // User rejected the call
                            print("User rejected the call")
                        }
                    }
            }
                }
      //  self.currentCall = call
        }
    

}
