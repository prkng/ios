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
    
    static func loggedIn() -> Bool {
        return authToken() != nil
    }
    
    static func authToken() -> String? {
        return nil
    }
    
    static func saveAuthToken(token : String) {
        
    }
    
}
