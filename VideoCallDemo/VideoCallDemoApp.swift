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


@main
struct VideoCallDemoApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
           // ContentView()
            LocalView()
        }
    }
}



