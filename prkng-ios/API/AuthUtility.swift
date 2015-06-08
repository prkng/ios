//
//  AuthUtility.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 8/5/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

struct AuthUtility {
    
    static let AUTH_TOKEN_KEY = "prkng_auth_token_key"
    static let USER_KEY = "prkng_user_key"
    
    static func loggedIn() -> Bool {
        return authToken() != nil
    }
    
    static func authToken() -> String? {
        return NSUserDefaults.standardUserDefaults().objectForKey(AUTH_TOKEN_KEY) as? String
    }
    
    static func saveAuthToken(token : String?) {
        if (token != nil) {
            NSUserDefaults.standardUserDefaults().setObject(token, forKey: AUTH_TOKEN_KEY)
        } else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(AUTH_TOKEN_KEY)

        }
    }
    
    
    static func getUser () -> User? {
        if let encodedUser : NSData = NSUserDefaults.standardUserDefaults().objectForKey(USER_KEY) as? NSData  {
            return NSKeyedUnarchiver.unarchiveObjectWithData(encodedUser) as? User
        }
        
        return nil
    }
    
    static func saveUser (user : User?) {
        
        if (user != nil) {
            let encodedUser = NSKeyedArchiver.archivedDataWithRootObject(user!)
            NSUserDefaults.standardUserDefaults().setObject(encodedUser, forKey: USER_KEY)
        } else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(USER_KEY)
        }
        
    }
    
    
    
}
