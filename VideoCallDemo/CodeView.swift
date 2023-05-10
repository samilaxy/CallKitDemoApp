    //
    //  CodeView.swift
    //  VideoCallDemo
    //
    //  Created by Noye Samuel on 30/04/2023.
    //



import SwiftUI
import CallKit

struct CodeView: View {
    @ObservedObject var callViewModel = CallDelegate()
    @State private var userCode = ""
    @State private var error = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 50) {
                    
                    HStack {
                        Text("Enter user code")
                            .foregroundColor(Color(UIColor.secondaryLabel))
                            .accessibility(hint: Text("Enter your phone number to continue"))
                            .multilineTextAlignment(.center)
                            .font(
                                .system(size: 25)
                                .weight(.heavy))
                    }
                    VStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 0)
                                .stroke(Color(.clear))
                                .frame(height: 50)
                                .background(Color.secondary.opacity(0.2))
                            HStack(spacing: 0) {
                                HStack {
                                    TextField("code", text: $userCode)
                                       // .tracking(userCode.isEmpty ? 0 : 3)
                                        .padding()
                                        .font(.callout)
                                        .accentColor(Color(UIColor.secondaryLabel))
                                        // .cornerRadius(10)
                                        .keyboardType(.asciiCapableNumberPad)
                                        .onTapGesture {
                                                //  UITextField.appearance().becomeFirstResponder()
                                        }
                                        .onChange(of: userCode, perform: { newValue in
                                            if newValue.count >= Constants.OTPCODELENGTH {
                                                    // use to exexcute function after number of digits is reached
                                                callViewModel.request.userCode = userCode
                                                callViewModel.userCode = userCode
                                            }
                                            if userCode == newValue {
                                                callViewModel.codeError  = ""
                                            }
                                        })
                                    
                                    Button(action: {
                                        if !userCode.isEmpty {
                                            callViewModel.showAlert = false
                                            callViewModel.startCall(dialCode: userCode)
                                        }else {
                                            callViewModel.showAlert = true
                                            callViewModel.codeError = TextsInUse.EmptyField
                                        }
                                    }, label: {
                                        ZStack{
                                            RoundedRectangle(cornerRadius: 0).stroke()
                                                .frame(width: 80, height: 48)
                                                .background(Color.green)
                                                // .cornerRadius(10)
                                            if !callViewModel.isRunning {
                                                Text("Call")
                                                    .foregroundColor(.white)
                                            }else{
                                                ProgressView()
                                            }
                                        }
                                    })
                                    .alert(isPresented: $callViewModel.showAlert) {
                                        Alert(
                                            title: Text("Error"),
                                            message: Text(callViewModel.codeError),
                                            primaryButton: .default(Text("OK"), action: {}),
                                            secondaryButton: .cancel(Text("Cancel"))
                                        )
                                    }
//                                    .navigationDestination(isPresented: $callViewModel.isOnCall) {
//                                        ContentView()
//                                    }
                                }
                            }
                            .frame(height: 50)
                            HStack {
                                if userCode.isEmpty {
                                    Text(error)
                                        .padding(.top, 70)
                                        .padding(.leading, 8)
                                        .foregroundColor(.red)
                                        .font(.caption)
                                        .frame(height: 8.0, alignment: .leading)
                                }
                                Spacer()
                            }
                        }
                            // MARK: VSTACK
                    }
                    .navigationBarHidden(true)
                    .padding(.bottom, 100)
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                }
            }
        }
    }
}
    
    struct CodeView_Previews: PreviewProvider {
        static var previews: some View {
            CodeView()
        }
    }
