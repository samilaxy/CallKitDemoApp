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
                ZStack {
                    if let remoteVideoView = callManager.call?.remoteVideoView {
                        RemoteVideoView(remoteVideoView: remoteVideoView)
                            .onAppear {
                                isRemoteVideoReady = true
                            }
                            
                    } else {
                        Image(systemName: "person.crop.circle.fill")
                            .resizable()
                            .foregroundColor(.gray)
                            .frame(width: 150, height: 150)
                            .opacity(isLocalVideoReady && isRemoteVideoReady ? 0 : 1)
                    }
                    ZStack {
                        RoundedRectangle(cornerRadius: 10).stroke()
                            .background(Color.secondary.opacity(0.2))
                            .cornerRadius(10)
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
                                .frame(width: 50, height: 50)
                                .opacity(isLocalVideoReady && isRemoteVideoReady ? 0 : 1)
                        }
                    }.frame(width: UIScreen.main.bounds.width * 0.3, height: UIScreen.main.bounds.width * 0.4)
                        .padding(.leading, UIScreen.main.bounds.width * 0.5)
                        .padding(.bottom, UIScreen.main.bounds.height * 0.6)
                    
                    
                    if !isLocalVideoReady || !isRemoteVideoReady {
                        ProgressView()
                    }
                }
                .opacity(isLocalVideoReady && isRemoteVideoReady ? 1 : 0)
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        Button(action: {
                                // Handle camera switch action
                            callManager.startCallTimer()
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
                            callManager.stopCallTimer()
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

    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
                .previewDevice("iPhone 14 Pro")
           ContentView().previewDevice("iPhone SE (3rd generation)")
        }
    }
