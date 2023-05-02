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
    
    var body: some View {
        NavigationStack {
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
                            RoundedRectangle(cornerRadius: 0).stroke()
                                .frame(height: 50)
                                .background(Color.secondary.opacity(0.2))
                            HStack(spacing: 0) {
                                HStack {
                                    TextField("code", text: $userCode)
                                        .tracking(userCode.isEmpty ? 0 : 3)
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
                                                callViewModel.userCode = userCode
                                            }
                                            if userCode == newValue {
                                                callViewModel.codeError = ""
                                            }
                                        })
                                        //   if phoneNumber.count >= 9 && !countryCode.isEmpty {
                                    Button(action: {
                                        callViewModel.startCall(withUser: userCode)
                                    }, label: {
                                        ZStack{
                                            RoundedRectangle(cornerRadius: 0).stroke()
                                                .frame(width: 80, height: 50)
                                                .background(Color.green)
                                                // .cornerRadius(10)
                                            Text("Call")
                                                .foregroundColor(.white)
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
                                    .navigationDestination(isPresented: $callViewModel.isOnCall) {
                                        ContentView()
                                    }
                                }
                            }
                            .frame(height: 50)
//                            HStack {
//                                Text(callViewModel.codeError)
//                                    .padding(.leading, 8)
//                                    .foregroundColor(.red)
//                                    .fixedSize(horizontal: false, vertical: true)
//                                    .frame(height: 8.0, alignment: .leading)
//                                    .font(.caption)
//                                Spacer()
//                            }
                        }
                            // MARK: VSTACK
                        .multilineTextAlignment(.leading)
                    }
                    .navigationBarHidden(true)
                    .padding(.bottom, 100)
                    .padding(.leading, 16)
                    .padding(.trailing, 16)
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
