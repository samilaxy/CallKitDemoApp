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
                VStack {
                    if let remoteVideoView = callManager.remoteVideoView {
                        RemoteVideoView(remoteVideoView: remoteVideoView)
                        
                    } else {
                        ProgressView()
                        Text("Remote video view loading..")
                    }
                }   .edgesIgnoringSafeArea(.all)
                    .background(Color.clear)
                
                
                VStack {
                    if let localVideoView = callManager.localVideoView {
                        LocalVideoView(localVideoView: localVideoView)
                        
                    } else {
                        ProgressView()
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
                           callManager.endCall()
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
                    .navigationBarTitle(callManager.formattedTime, displayMode: .inline)
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
