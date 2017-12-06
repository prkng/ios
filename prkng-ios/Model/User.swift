//
//  User.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 10/05/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class User : NSObject {

    var fullName: String
    var firstName: String?
    var lastName: String?
    var gender: String
    var identifier: String
    var email: String
    var imageUrl: String?
    
    init(json : JSON) {
        fullName = json["name"].stringValue
        firstName = json["first_name"].string
        lastName = json["last_name"].string
        gender = json["gender"].stringValue
        identifier = json["id"].stringValue
        email = json["email"].stringValue
        imageUrl = json["image_url"].string
    }
    
    init(coder : NSCoder ) {
        fullName = coder.decodeObject(forKey: "name") as! String
        firstName = coder.decodeObject(forKey: "first_name") as? String
        lastName = coder.decodeObject(forKey: "last_name") as? String
        gender = coder.decodeObject(forKey: "gender") as! String
        identifier = coder.decodeObject(forKey: "identifier") as! String
        email = coder.decodeObject(forKey: "email") as! String
        imageUrl = coder.decodeObject(forKey: "imageUrl") as? String
    }
    
    func encodeWithCoder (_ encoder : NSCoder) {
        encoder.encode(fullName, forKey: "name")
        encoder.encode(firstName, forKey: "first_name")
        encoder.encode(lastName, forKey: "last_name")
        encoder.encode(gender, forKey: "gender")
        encoder.encode(identifier, forKey: "identifier")
        encoder.encode(email, forKey: "email")
        if (imageUrl != nil) {
            encoder.encode(imageUrl, forKey: "imageUrl")
        }
    }
    
    
    static func validateInput(_ nameText: String, emailText: String, passwordText: String, passwordConfirmText: String) -> Bool {
        
        if (nameText.characters.count < 2) {
            GeneralHelper.warnUser("invalid_name".localizedString)
            return false
        }
        
        if !emailText.isValidEmail {
            GeneralHelper.warnUser("invalid_email".localizedString)
            return false
        }
        
        if (passwordText.characters.count < 6 || passwordConfirmText.characters.count < 6) {
            GeneralHelper.warnUser("password_short".localizedString)
            return false
        }
        
        if (passwordText != passwordConfirmText) {
            GeneralHelper.warnUser("password_mismatch".localizedString)
            return false
        }
        
        return true
        
    }
    

    
   
}
