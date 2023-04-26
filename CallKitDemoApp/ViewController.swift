//
//  ViewController.swift
//  CallKitDemoApp
//
//  Created by Noye Samuel on 26/04/2023.
//

import UIKit
import CallKit

class ViewController: UIViewController, CXProviderDelegate {
    func providerDidReset(_ provider: CXProvider) {
        //
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
//        let update = CXCallUpdate()
//        update.remoteHandle = CXHandle(type: .generic, value: "Noye Samuel")
//        let config = CallKit.CXProviderConfiguration()
//        config.includesCallsInRecents = true
//        config.supportsVideo = true
//        let provider = CXProvider(configuration: config)
//        provider.setDelegate(self, queue: nil)
//        provider.reportNewIncomingCall(with: UUID() , update: update, completion: { error in } )
        
        let config = CallKit.CXProviderConfiguration()
        let provider = CXProvider(configuration: config)
        provider.setDelegate(self, queue: nil)
        
        let callController  = CXCallController()
        
        let uuid = UUID()
        // specify the recipient
        let recipient = CXHandle(type: .generic, value: "Outgoing Call")
        let startCallAction = CXStartCallAction(call: uuid, handle: recipient)
     //   startCallAction.isVideo
        let transaction  = CXTransaction(action: startCallAction)
        
        callController.request(transaction, completion: { error in
            if let error = error {
                print("Error requeting transaction: \(error)")
            }else {
                print("Successful")
            }
        })
    }

    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        action.fulfill()
        return
    }
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        action.fail()
        return
    }
    
    
}

