//
//  User.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 10/05/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class User : NSObject {

    var name : String
    var gender : String
    var identifier : String
    var email : String
    var imageUrl : String?
    
    init(json : JSON) {
        name = json["name"].stringValue
        gender = json["gender"].stringValue
        identifier = json["id"].stringValue
        email = json["email"].stringValue
        imageUrl = json["image_url"].string
    }
    
    init(coder : NSCoder ) {
        name = coder.decodeObjectForKey("name") as! String
        gender = coder.decodeObjectForKey("gender") as! String
        identifier = coder.decodeObjectForKey("identifier") as! String
        email = coder.decodeObjectForKey("email") as! String
        imageUrl = coder.decodeObjectForKey("imageUrl") as? String
    }
    
    func encodeWithCoder (encoder : NSCoder) {
        encoder.encodeObject(name, forKey: "name")
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
