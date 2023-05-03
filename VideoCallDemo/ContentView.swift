////
////  ContentView.swift
////  VideoCallDemo
////
////  Created by Noye Samuel on 28/04/2023.
////

import SwiftUI
import SendBirdCalls



struct ContentView: View {
    
    @ObservedObject var callManager = CallDelegate()
    @Environment(\.presentationMode) var presentationMode
     var call: DirectCall?
    
    var body: some View {
        NavigationView{
            ZStack {
                    //            if let remoteVideoView = call.setLocalVideoView(localVideoView) {
                    //                UIViewRepresentableWrapper(remoteVideoView)
                    //                    .edgesIgnoringSafeArea(.all)
                    //                    .background(Color.gray)
                    //            }
                    //
                    //            if let localVideoView = call.setRemoteVideoView(remoteVideoView) {
                    //                UIViewRepresentableWrapper(localVideoView)
                    //                    .frame(width: 150, height: 150)
                    //                    .background(Color.secondary)
                    //                    .cornerRadius(75)
                    //                    .offset(x: UIScreen.main.bounds.width - 120, y: UIScreen.main.bounds.height - 250)
                    //            }
                ZStack {
                    if let remoteVideoView = callManager.remoteVideoView {
                        RemoteVideoView(remoteVideoView: remoteVideoView)
                        
                    } else {
                        Text("Remote video view is not available")
                    }
                }   .edgesIgnoringSafeArea(.all)
                    .background(Color.gray)
                
                
                ZStack {
                    if let remoteVideoView = callManager.localVideoView {
                        LocalVideoView(localVideoView: remoteVideoView)
                        
                    } else {
                        Text("Local video view is not available")
                    }
                }.frame(width: 150, height: 150)
                    .background(Color.secondary)
                    .cornerRadius(75)
                    .offset(x: UIScreen.main.bounds.width - 120, y: UIScreen.main.bounds.height - 250)
                
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                                // Handle camera switch action
                        }) {
                            Image(systemName: "camera.rotate")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(25)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                                // Handle end call action
                        }) {
                            Image(systemName: "phone.down.fill")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(25)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                                // Handle mute/unmute action
                        }) {
                            Image(systemName: "mic.slash")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.green)
                                .cornerRadius(25)
                        }
                        
                        Spacer()
                    }
                    .navigationBarTitle(String(callManager.callDuration), displayMode: .inline)
                    .padding()
                }
            }
        }
    }
}

struct RemoteVideoView: UIViewRepresentable {
  

    let remoteVideoView: SendBirdVideoView
    
    func makeUIView(context: Context) -> SendBirdVideoView {
        return remoteVideoView
    }
    
    func updateUIView(_ uiView: SendBirdCalls.SendBirdVideoView, context: Context) {
            //
    }
    typealias UIViewType = SendBirdVideoView
}

struct LocalVideoView: UIViewRepresentable {
    
    let localVideoView: SendBirdVideoView
    
    func makeUIView(context: Context) -> SendBirdVideoView {
        return localVideoView
    }
    
    func updateUIView(_ uiView: SendBirdCalls.SendBirdVideoView, context: Context) {
        //
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
