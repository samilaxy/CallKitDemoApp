//
//  CodeRequestDTO.swift
//  VideoCallDemo
//
//  Created by Noye Samuel on 30/04/2023.
//

import Foundation


struct CodeRequestDTO {
    var userCode: String  = ""
    var validate: Validations
    
    init () {
        userCode = ""
        validate = Validations()
    }
    func codeParam() -> String {
            //  return  countryCode+phoneNumber
        return  userCode
    }
}

    // all fields validations
class Validations {
    static let shared = Validations()
    
    func validatePhoneNumber(userCode: String) -> Bool {
            //  regex for sent code validations
        let phoneTest = NSPredicate(format: TextsInUse.ValidMatch,
                                    "[0-9]{9,12}$")
        return phoneTest.evaluate(with: userCode)
    }
    
    func validateUserPhoneNumber(_ userCode: String?) -> (Bool, String) {
        guard let userNumber = userCode else {
            return (false, TextsInUse.InvalidPhoneNumber)
        }
        if userNumber.isEmpty || !validatePhoneNumber(userCode: userNumber) {
            return (false, TextsInUse.InvalidPhoneNumber)
        }
        return (true, TextsInUse.Empty)
    }
}

struct TextsInUse {
    static let Empty = ""
        // textfields
    static let EmptyField =  "User Invalid"
    static let ValidMatch =  "SELF MATCHES %@"
    static let InvalidPhoneNumber = "*Invalid phone number"
    static let NoInternet = "No Internet access, try again."
    static let AppID = Bundle.main.object(forInfoDictionaryKey: "App_ID") as! String
    static let Token = Bundle.main.object(forInfoDictionaryKey: "A_Token") as! String
    static let UserID = Bundle.main.object(forInfoDictionaryKey: "User_ID") as! String
}
class Constants {
    static let OTPCODELENGTH = 6
    static let COUNTDOWNTIMERLENGTH = 5
}
