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
            encoder.encodeObject(email, forKey: "imageUrl")
        }
    }
    
    
   
}
