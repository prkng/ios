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
        return nil
    }
    
    static func saveAuthToken(token : String) {
        
    }
    
    
    static func getUser () -> User? {
        if let encodedUser : NSData = NSUserDefaults.standardUserDefaults().objectForKey(USER_KEY) as? NSData  {
            return NSKeyedUnarchiver.unarchiveObjectWithData(encodedUser) as? User
        }
        
        return nil
    }
    
    static func saveUser (user : User) {
        

        let encodedUser = NSKeyedArchiver.archivedDataWithRootObject(user)
        
        NSUserDefaults.standardUserDefaults().setObject(encodedUser, forKey: USER_KEY)
        
    }
    
    
    
}
