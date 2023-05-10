//
//  CallView.swift
//  VideoCallDemo
//
//  Created by Noye Samuel on 04/05/2023.
//

import Foundation
import SwiftUI
import SendBirdCalls


struct CallView: View {
    
    @StateObject var viewModel = ViewModel()
    let calleeId: String
    let isVideoCall: Bool
    @SwiftUI.State private var localView = UIView()
    @SwiftUI.State private var remoteView = UIView()
    
    var body: some View {
        VStack {
            VStack {
                UIViewRepresented(view: localView)
                UIViewRepresented(view: remoteView)
            }
            HStack {
                Button(action: {
                    viewModel.endCall()
                }, label: {
                    Image(systemName: "phone.down.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.red)
                })
                .padding(.leading, 16)
                .padding(.bottom, 16)
                Spacer()
                Button(action: {
                  //  viewModel.switchCamera
                    let params = DialParams(calleeId: "7890", isVideoCall: true)
                    SendBirdCall.dial(with: params) { call, error in
                        if let call = call, error == nil {
                           
                            DispatchQueue.main.asyncAfter(deadline: .now() + 40) {
                                let localView = SendBirdVideoView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                                let remoteView = SendBirdVideoView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
                                
                                self.localView = call.localVideoView ?? UIView()
                                self.remoteView = call.remoteVideoView ?? UIView()
                                print("sdsdsdLocal", call.localVideoView as Any)
                                print("sdsdsdremote", call.remoteVideoView)
                            }
                        }
                    }
                }, label: {
                    Image(systemName: "camera.rotate.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white)
                })
                .padding(.bottom, 16)
                .padding(.trailing, 16)
            }
        }
        .onAppear {
                //  viewModel.callUser(userId: calleeId, isVideoCall: isVideoCall)
            let params = DialParams(calleeId: "7890", isVideoCall: true)
            SendBirdCall.dial(with: params) { call, error in
                if let call = call, error == nil {
                    print("sdsdsd")
                    DispatchQueue.main.async {
                        self.localView = call.localVideoView ?? UIView()
                        self.remoteView = call.remoteVideoView ?? UIView()
                    }
                }
            }
        }
    }
}

//struct CallView_Previews: PreviewProvider {
//    static var previews: some View {
//        CallView(calleeId: "test_user_id", isVideoCall: true)
//    }
//}


struct UIViewRepresented: UIViewRepresentable {
    var view: UIView
    
    func makeUIView(context: Context) -> UIView {
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
            // Do nothing
    }
}
