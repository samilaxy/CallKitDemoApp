//
//  PhoneRequestDTO.swift
//  AxxendVideoDemoApp
//
//  Created by Noye Samuel on 26/04/2023.
//

import Foundation



struct PhoneRequestDTO {
    var countryCode: String = ""
    var phoneNumber: String  = ""
    var validate: Validations
    
    init () {
        countryCode = ""
        phoneNumber = ""
        validate = Validations()
    }
    func phoneNumberParam() -> String {
            //  return  countryCode+phoneNumber
        return  "+"+countryCode+phoneNumber
    }
}

    // all fields validations
class Validations {
    static let shared = Validations()

    func validatePhoneNumber(phoneNumber: String) -> Bool {
            //  regex for sent code validations
        let phoneTest = NSPredicate(format: TextsInUse.ValidMatch,
                                    "[0-9]{9,12}$")
        return phoneTest.evaluate(with: phoneNumber)
    }
    
    func validateUserPhoneNumber(_ phoneNumber: String?) -> (Bool, String) {
        guard let userNumber = phoneNumber else {
            return (false, TextsInUse.InvalidPhoneNumber)
        }
        if userNumber.isEmpty || !validatePhoneNumber(phoneNumber: userNumber) {
            return (false, TextsInUse.InvalidPhoneNumber)
        }
        return (true, TextsInUse.Empty)
    }
}


struct TextsInUse {
    static let Empty = ""
        // textfields
    static let ValidMatch =  "SELF MATCHES %@"
    static let InvalidPhoneNumber = "*Invalid phone number"
}
class Constants {
    static let OTPCODELENGTH = 6
    static let COUNTDOWNTIMERLENGTH = 5
}
