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
        fullName = coder.decodeObjectForKey("name") as! String
        firstName = coder.decodeObjectForKey("first_name") as? String
        lastName = coder.decodeObjectForKey("last_name") as? String
        gender = coder.decodeObjectForKey("gender") as! String
        identifier = coder.decodeObjectForKey("identifier") as! String
        email = coder.decodeObjectForKey("email") as! String
        imageUrl = coder.decodeObjectForKey("imageUrl") as? String
    }
    
    func encodeWithCoder (encoder : NSCoder) {
        encoder.encodeObject(fullName, forKey: "name")
        encoder.encodeObject(firstName, forKey: "first_name")
        encoder.encodeObject(lastName, forKey: "last_name")
        encoder.encodeObject(gender, forKey: "gender")
        encoder.encodeObject(identifier, forKey: "identifier")
        encoder.encodeObject(email, forKey: "email")
        if (imageUrl != nil) {
            encoder.encodeObject(imageUrl, forKey: "imageUrl")
        }
    }
    
    
    static func validateInput(nameText: String, emailText: String, passwordText: String, passwordConfirmText: String) -> Bool {
        
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
