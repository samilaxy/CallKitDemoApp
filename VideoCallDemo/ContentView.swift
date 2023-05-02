////
////  ContentView.swift
////  VideoCallDemo
////
////  Created by Noye Samuel on 28/04/2023.
////

import SwiftUI
import SendBirdSDK
import SendBirdCalls



struct ContentView: View {
    
    @ObservedObject var callManager = CallDelegate()
    @Environment(\.presentationMode) var presentationMode
    @State var call: DirectCall?
    
    var body: some View {
//        VStack {
//            if let localView = callManager.localVideoView {
//                VideoCallView(localVideoView: localView, remoteVideoView: callManager.remoteVideoView ?? localView)
//            } else {
//                ZStack{
//                   ProgressView()
//                    Image(systemName: "video.slash")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .foregroundColor(.gray)
//                }.padding(.top, 30)
//                .frame(width: 200, height: 200)
//            }
//
//            if let remoteView = callManager.remoteVideoView {
//                VideoView(videoView: remoteView)
//            } else {
//             //   Spacer()
//                ZStack{
//                    ProgressView()
//                    Image(systemName: "person.crop.circle.fill")
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .foregroundColor(.gray)
//                } .frame(width: 200, height: 200)
//            }
//
//          Spacer()
//
//            HStack {
//                Button(action: {
//                    callManager.endCall()
//                }, label: {
//                    Image(systemName: "phone.down.fill")
//                        .resizable()
//                        .frame(width: 25, height: 25)
//                        .foregroundColor(.red)
//                })
//                .alert(isPresented: $callManager.showAlert) {
//                    Alert(
//                        title: Text("Error"),
//                        message: Text(callManager.codeError),
//                        primaryButton: .default(Text("OK"), action: {
//                            self.presentationMode.wrappedValue.dismiss()
//                        }),
//                        secondaryButton: .cancel(Text("Cancel"))
//                    )
//                }
//
//                Spacer()
//
//                Button(action: {
//                //    callManager.switchCameraPosition()
//                }, label: {
//                    Image(systemName: "camera.rotate.fill")
//                        .resizable()
//                        .frame(width: 25, height: 25)
//                        .foregroundColor(.white)
//                })
//            }
//            .padding(.horizontal, 20)
//            .padding(.vertical, 10)
//            .background(Color.black.opacity(0.7))
//        }
        ZStack{
            if let remoteView = callManager.localVideoView {
                    //                VideoView(videoView: remoteView)
                    //            }
                VideoCallView(localVideoView: callManager.localVideoView ?? remoteView, remoteVideoView: callManager.remoteVideoView ?? remoteView, call: $call )
                    .navigationBarTitle(Text(callManager.request.userCode), displayMode: .inline)
                    .onAppear {
                            //    callManager.startCall(withUser: callManager.request.userCode)
                    }
                    .onDisappear {
                        callManager.endCall()
                    }
            }
        }
    }
}

struct VideoView: UIViewRepresentable {
    let videoView: UIView
    
    func makeUIView(context: Context) -> UIView {
        return videoView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
}

struct VideoCallView: UIViewRepresentable {
    let localVideoView: UIView
    let remoteVideoView: UIView
    @Binding var call: SendBirdCalls.DirectCall?
    
    func makeUIView(context: Context) -> SBDVideoView {
        let view = UIView(frame: .zero)
        view.addSubview(localVideoView)
        view.addSubview(remoteVideoView)
        
            // Constrain local video view to top-left corner
        localVideoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            localVideoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            localVideoView.topAnchor.constraint(equalTo: view.topAnchor),
            localVideoView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3),
            localVideoView.heightAnchor.constraint(equalTo: localVideoView.widthAnchor)
        ])
        
            // Constrain remote video view to fill the rest of the view
        remoteVideoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            remoteVideoView.leadingAnchor.constraint(equalTo: localVideoView.trailingAnchor),
            remoteVideoView.topAnchor.constraint(equalTo: view.topAnchor),
            remoteVideoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            remoteVideoView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: SBDVideoView, context: Context) {
        if let call = call {
            if call.localVideoView == nil {
                call.localVideoView = uiView
            } else if call.remoteVideoView == nil {
                call.remoteVideoView = uiView
            }
        }
    }

    
    typealias UIViewType = UIView
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
