//
//  ContentView.swift
//  AxxendVideoDemoApp
//
//  Created by Noye Samuel on 26/04/2023.
//

import SwiftUI
import CountryPicker

struct ContentView: View {
    @ObservedObject var callViewModel = CallViewModel()
    @State private var country: Country?
    @State private var showCountryPicker = false
    @State var countryCode = ""
    @State private var phoneNumber = ""
    @State private var isVideo = false
    
    var body: some View {
        ZStack {
            VStack(spacing: 50) {
                HStack {
                    Text("Enter your phone\n number to continue")
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
                                if let country = country {
                                    let countryCode = "+\(country.phoneCode)"
                                    Text(countryCode)
                                } else {
                                    Text("+233")
                                }
                                Text("|")
                                    .frame(width: 10, height: 50, alignment: .center)
                                    .padding(.bottom, 3)
                                    .font(
                                        .system(size: 20)
                                        .weight(.regular))
                            }
                            .padding(.leading, 16)
                            .onAppear {
                                countryCode = country?.phoneCode ?? "233"
                                }
                                .onTapGesture {
                                        showCountryPicker = true
                                }
                                .sheet(isPresented: $showCountryPicker) {
                                    CountryPicker(country: $country)
                                }
                           
                             //    TextFieldComponent(fieldBind: $phoneNumber, validationMessage: $phoneViewModel.phoneError)
                            TextField("Phone Number", text: $phoneNumber)
                                .tracking(phoneNumber.isEmpty ? 0 : 3)
                                .padding()
                                .font(.callout)
                                .accentColor(Color(UIColor.secondaryLabel))
                               // .cornerRadius(10)
                                .keyboardType(.asciiCapableNumberPad)
                                .onTapGesture {
                                  //  UITextField.appearance().becomeFirstResponder()
                                }
                                .onChange(of: phoneNumber, perform: { newValue in
                                    if newValue.count >= Constants.OTPCODELENGTH {
                                            // use to exexcute function after number of digits is reached
                                        callViewModel.request.phoneNumber = phoneNumber
                                    }
                                    if phoneNumber == newValue {
                                        callViewModel.phoneError = ""
                                    }
                                })
                         //   if phoneNumber.count >= 9 && !countryCode.isEmpty {
                                Button(action: {
                                    if let country = country {
                                        countryCode = "\(country.phoneCode)"
                                    }
                                    callViewModel.request.countryCode = countryCode
                                    callViewModel.countryCode = countryCode
                                    callViewModel.startCall(handle: "", isVideo: true)
                                }, label: {
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 0).stroke()
                                            .frame(width: 80, height: 50)
                                            .background(Color.green)
                                           // .cornerRadius(10)
                                        Text("Call")
                                            .foregroundColor(.white)
                                    }
//                                    Image(systemName: "arrow.right.circle")
//                                        .font(.title3)
//                                        .foregroundColor(Color(UIColor.secondaryLabel))
                                })
                              //  .padding(.trailing, 16)
//                                .navigationDestination(isPresented: $phoneViewModel.routeUser) {
//                                    ActivateAccountView(phoneViewModel: phoneViewModel)
//                                }
                            }
                      //  }
                    }
                    .frame(height: 50)
//                    .onAppear {
//                        for (key, value) in phoneViewModel.countryCodeDictionary {
//                            countryCode = value
//                            countryFlag = flag(country: key)
//                        }
//                    }
                    HStack {
                        Text(callViewModel.phoneError)
                            .padding(.leading, 8)
                            .foregroundColor(.red)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(height: 8.0, alignment: .leading)
                            .font(.caption)
                        Spacer()
                    }
                }
                    // MARK: VSTACK
                .multilineTextAlignment(.leading)
            }
            .navigationBarHidden(true)
            .padding(.bottom, 100)
            .padding(.leading, 16)
            .padding(.trailing, 16)
//            CountryCodesView(countryCode: $countryCode, countryFlag: $countryFlag, yDirection: $yDirection)
//                .offset(y: yDirection)
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
