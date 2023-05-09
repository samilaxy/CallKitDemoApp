//
//  Extension.swift
//  VideoCallDemo
//
//  Created by Noye Samuel on 08/05/2023.
//

import Foundation
import UIKit
import SendBirdCalls
import CallKit

extension SendBirdCall {
    /**
     This method uses when,
     - the user makes outgoing calls from native call history("Recents")
     - the provider performs the specified end(decline) or answer call action.
     */
    static func authenticateIfNeed(completionHandler: @escaping (Error?) -> Void) {
        guard SendBirdCall.currentUser == nil else {
            completionHandler(nil)
            return
        }

    //    let appID = TextsInUse.AppID
        let token = TextsInUse.Token
        let userId = TextsInUse.UserID
        
        let params = AuthenticateParams(userId: userId, accessToken: token)
        SendBirdCall.authenticate(with: params) { (_, error) in
            completionHandler(error)
        }
    }
//
//    static func dial(with dialParams: DialParams) {
//        SendBirdCall.dial(with: dialParams) { call, error in
//            guard let call = call, error == nil else {
//             //   UIApplication.shared.showError(with: error?.localizedDescription)
//                return
//            }
//          //  UIApplication.shared.showCallController(with: call)
//        }
//    }
}


extension DirectCallEndResult {
    var asCXCallEndedReason: CXCallEndedReason? {
        switch self {
            case .connectionLost, .timedOut, .acceptFailed, .dialFailed, .unknown:
                return .failed
            case .completed, .canceled:
                return .remoteEnded
            case .declined:
                return .declinedElsewhere
            case .noAnswer:
                return .unanswered
            case .otherDeviceAccepted:
                return .answeredElsewhere
            case .none: return nil
            @unknown default: return nil
        }
    }
}


extension Data {
    func toHexString() -> String {
        return reduce("") { $0 + String(format: "%02x", $1) }
    }
}


extension CXProviderConfiguration {
        // The app's provider configuration, representing its CallKit capabilities
    static var `default`: CXProviderConfiguration {
        let providerConfiguration = CXProviderConfiguration()
        if let image = UIImage(named: "icLogoSymbolInverse") {
            providerConfiguration.iconTemplateImageData = image.pngData()
        }
            // Even if `.supportsVideo` has `false` value, SendBirdCalls supports video call.
            // However, it needs to be `true` if you want to make video call from native call log, so called "Recents"
            // and update correct type of call log in Recents
        providerConfiguration.supportsVideo = true
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.maximumCallGroups = 1
        providerConfiguration.supportedHandleTypes = [.generic]
        
            // Set up ringing sound
            // If you want to set up other sounds such as dialing, reconnecting and reconnected, see `AppDelegate+SoundEffects.swift` file.
        providerConfiguration.ringtoneSound = "Ringing.mp3"
        
        return providerConfiguration
    }
}

extension CXProvider {
    static var `default`: CXProvider {
        CXProvider(configuration: .`default`)
    }
}
