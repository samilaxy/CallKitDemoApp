//
//  VideoCallDemoApp.swift
//  VideoCallDemo
//
//  Created by Noye Samuel on 28/04/2023.
//

import SwiftUI
import SendBirdCalls
import UIKit
import CallKit
import PushKit


class AppDelegate: UIResponder, UIApplicationDelegate, CXProviderDelegate, CXCallObserverDelegate {
    func providerDidReset(_ provider: CXProvider) {
        //
    }
    
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        //
    }
    
    

    let callbackQueue = DispatchQueue(label: "QUEUE_LABEL")
   
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let appID = TextsInUse.AppID
        let token = TextsInUse.Token
        let userId = TextsInUse.UserID
        
            // Initialize Sendbird SDK with your application ID
        SendBirdCall.configure(appId: appID)
        SendBirdCall.executeOn(queue: self.callbackQueue)
    
        let callObserver = CXCallObserver()
        callObserver.setDelegate(self, queue: nil)
        SendBirdCall.application(application, didReceiveRemoteNotification: [:])
            // Initialize Sendbird SDK with your application ID
      //  SendBird.initWithApplicationId("0A7F7DC2-AD5E-4D48-9E07-222A706C6557")
       
//            // Authenticate the user with an access token
//        SendBirdCalls.connect(<#T##Int32#>, <#T##UnsafePointer<sockaddr>!#>, <#T##socklen_t#>)
//        SendBirdCalls.connect(token) { (user, error) in
//            if let error = error {
//                print("Error connecting to Sendbird: \(error.localizedDescription)")
//            } else {
//                print("Connected to Sendbird as user \(user!.userId)")
//            }
//        }
        
        let params = AuthenticateParams(userId: userId, accessToken: token)
        SendBirdCall.authenticate(with: params) { (user, error) in
            guard error == nil else { return }
                // Register for push notifications
        }

        
        return true
    }
}

@main
struct VideoCallDemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            CodeView()
        }
    }
}


