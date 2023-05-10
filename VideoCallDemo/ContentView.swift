    ////
    ////  ContentView.swift
    ////  VideoCallDemo
    ////
    ////  Created by Noye Samuel on 28/04/2023.
    ////

import SwiftUI
import SendBirdCalls
import Foundation



struct ContentView: View {
    
    @ObservedObject var callManager =  CallDelegate()
    @Environment(\.presentationMode) var presentationMode
    var call: DirectCall?
    weak var localView: SendBirdVideoView?
    @SwiftUI.State private var isLocalVideoReady = false
    @SwiftUI.State private var isRemoteVideoReady = false
    @SwiftUI.State private var isCodeView = false
    @SwiftUI.State private var isCallView = false
    var body: some View {
        NavigationView{
            ZStack {
//                VStack {
//                    if let remoteVideoView = callManager.remoteVideoView {
//                        RemoteVideoView(remoteVideoView: remoteVideoView)
//
//                    } else {
//                        ProgressView()
//                        Text("Remote video view loading..")
//                    }
//                }   .edgesIgnoringSafeArea(.all)
//                    .background(Color.clear)
//                VStack {
//                    if let localVideoView = callManager.localVideoView {
//                        LocalVideoView(localVideoView: localVideoView)
//
//                    } else {
//                        ProgressView()
//                        Text("Local video view is not available")
//                    }
//                }.frame(width: 150, height: 150)
//                    .background(Color.secondary)
//                    .cornerRadius(75)
//                    .offset(x: UIScreen.main.bounds.width - 120, y: UIScreen.main.bounds.height - 250)
                ZStack {
                    if let localVideoView = callManager.call?.localVideoView {
                        LocalVideoView(localVideoView: localVideoView)
                            .onAppear {
                                isLocalVideoReady = true
                            }
                            .opacity(isLocalVideoReady && isRemoteVideoReady ? 1 : 0)
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                            .frame(width: 80, height: 80)
                            .opacity(isLocalVideoReady && isRemoteVideoReady ? 0 : 1)
                    }
                    
                    if let remoteVideoView = callManager.call?.remoteVideoView {
                        RemoteVideoView(remoteVideoView: remoteVideoView)
                            .onAppear {
                                isRemoteVideoReady = true
                            }
                            .opacity(isLocalVideoReady && isRemoteVideoReady ? 1 : 0)
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                            .frame(width: 200, height: 200)
                            .opacity(isLocalVideoReady && isRemoteVideoReady ? 0 : 1)
                    }
                    
                    if !isLocalVideoReady || !isRemoteVideoReady {
                        ProgressView()
                    }
                }
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
                            isCodeView = true
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
                    .sheet(isPresented: $isCodeView, content: {
                          CodeView()
                    })
//                    .navigationDestination(isPresented: $isCallView) {
//                        CodeView()
//                    }
                    .navigationBarTitle(callManager.formattedTime, displayMode: .inline)
                    .navigationBarItems(trailing:
                                            Button(action: {
                        isCodeView = true
                    },
                                                   label: {
                        Image(systemName: "phone.down.fill")
                        .foregroundColor( .accentColor)}))
                    .padding()
                }
                .onAppear {
                        // Create SendBirdVideoView
                //    callManager.startCall()
                    let localSBVideoView = SendBirdVideoView(frame: self.localView?.frame ?? CGRect.zero)
                    
                        // Embed the SendBirdVideoView to UIView
                    self.localView?.embed(in: localSBVideoView)
                    
                        // Start rendering local video view
//                    guard let frontCamera = (callManager.call?.availableVideoDevices{ $0.position == .front }) else { return }
//                    callManager.call?.selectVideoDevice(frontCamera) { (error) in
//                            // handle error
//                    }
                }
            }
        }.navigationBarBackButtonHidden(true)
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

//    struct ContentView_Previews: PreviewProvider {
//        static var previews: some View {
//            ContentView(callManager: <#CallDelegate#>)
//        }
//    }
