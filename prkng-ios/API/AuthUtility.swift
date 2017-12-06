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
    static let LOGIN_TYPE = "prkng_login_type" // Logged in with Facebook / Google
    
    static func loggedIn() -> Bool {
        return authToken() != nil
    }
    
    static func authToken() -> String? {
        return UserDefaults.standard.object(forKey: AUTH_TOKEN_KEY) as? String
    }
    
    static func saveAuthToken(_ token : String?) {
        if (token != nil) {
            UserDefaults.standard.set(token, forKey: AUTH_TOKEN_KEY)
            if #available(iOS 8.0, *) {
                UIApplication.shared.registerForRemoteNotifications()
            } else {
                UIApplication.shared.registerForRemoteNotifications(matching: [.badge, .sound, .badge, .alert])
            }
        } else {
            UserDefaults.standard.removeObject(forKey: AUTH_TOKEN_KEY)
        }
    }
    
    
    static func getUser() -> User? {
        if let encodedUser : Data = UserDefaults.standard.object(forKey: USER_KEY) as? Data  {
            return NSKeyedUnarchiver.unarchiveObject(with: encodedUser) as? User
        }
        
        return nil
    }
    
    static func saveUser(_ user : User?) {
        
        if (user != nil) {
            let encodedUser = NSKeyedArchiver.archivedData(withRootObject: user!)
            UserDefaults.standard.set(encodedUser, forKey: USER_KEY)
        } else {
            UserDefaults.standard.removeObject(forKey: USER_KEY)
        }
        
    }
    
    static func saveLoginType(_ loginType: LoginType) {
        UserDefaults.standard.set(loginType.rawValue, forKey: LOGIN_TYPE)
    }
    
    
    static func loginType() -> LoginType? {
        if let type =  UserDefaults.standard.string(forKey: LOGIN_TYPE) {
            return LoginType(rawValue: type)
        }
        
        return nil
    }
    
}

enum LoginType: String {
    case Facebook = "Facebook"
    case Google = "Google"
    case Email = "Email"
}
