//
//  CallViewModel.swift
//  AxxendVideoDemoApp
//
//  Created by Noye Samuel on 26/04/2023.
//

import Foundation
import CallKit
import SwiftUI

class CallViewModel: NSObject, ObservableObject, CXProviderDelegate {
  
    
    static let shared = CallViewModel()
    private let callController = CXCallController()
    
    @Published var countryCode = ""
    @Published var phoneError = ""
    @Published var request: PhoneRequestDTO
    override init() {
        request = PhoneRequestDTO()
    }
    
    func providerDidReset(_ provider: CXProvider) {
        
    }
    
    func startCall(handle: String, isVideo: Bool) {
        if requestVerification() {
            print("number: ",request.phoneNumberParam())
                // 1. Add a provider configuration
            let config = CallKit.CXProviderConfiguration()
            let provider = CXProvider(configuration: config)
            provider.setDelegate(self, queue: nil)
            
                // 2. Create a start call action and configure it with UUID and the user's handle. The handle parameter is a string that represents the recipient
            let callController = CXCallController()
                // Allows to uniquely identify the call
            let uuid = UUID()
                // CXHandle specifies the recipient
            let recipient = CXHandle(type: .generic, value: request.phoneNumberParam())
            let startCallAction = CXStartCallAction(call: uuid, handle: recipient)
            startCallAction.isVideo = true
            let transaction = CXTransaction(action: startCallAction)
            
                // To make an outgoing call, the app requests a `CXStartCallAction` from the `CXCallController` as a transaction. The transaction object helps to hold a call when there are multiple calls attempting to occur at the same time.
            callController.request(transaction, completion: { error in
                if let error = error {
                    print("Error requesting transaction: \(error)")
                } else {
                    print("Requested transaction successfully")
                }
            })
            
                // How to connect an outgoing call after a certain time interval
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    // Show the call is connected after 10 seconds
                provider.reportOutgoingCall(with: callController.callObserver.calls[0].uuid, connectedAt: nil)
            }
        }
    }
    func requestVerification() -> Bool {
        let validation = Validations.shared.validateUserPhoneNumber(request.phoneNumber)
        if validation.0 {
            return true
        } else {
            phoneError = validation.1
            return false
        }
    }
    
}

//struct CallView: UIViewControllerRepresentable {
//    typealias UIViewControllerType = <#type#>
//
//    func makeUIViewController(context: UIViewControllerRepresentableContext<CallView>) -> ViewController {
//        return ViewController()
//    }
//
//    func updateUIViewController(_ uiViewController: ViewController, context: UIViewControllerRepresentableContext<CallView>) {
//
//    }
//}
//
//struct OutgoingCallView: View {
//    var body: some View {
//        CallView()
//    }
//}
//
//struct OutgoingCallView_Previews: PreviewProvider {
//    static var previews: some View {
//        OutgoingCallView()
//    }
//}
