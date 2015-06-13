//
//  UserOperations.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 8/5/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

struct UserOperations {
    
    
    static func register (email : String, name : String, password : String, gender : String, birthYear : String, completion : (user : User, apiKey : String) -> Void) {
        
        let url = APIUtility.APIConstants.rootURLString + "register"
        
        let params = ["email" : email, "name" : name, "password" : password, "gender" : gender, "birthYear" : birthYear]
        
        request(.POST, url, parameters: params).responseSwiftyJSON() {
            (request, response, json, error) in
            
            let user = User(json: json)
            let apiKey = json["apikey"].stringValue
            
            completion(user: user, apiKey: apiKey)
            
        }
        
    }
    
    
    static func login (email : String, password: String, completion : (user : User?, apiKey : String?) -> Void) {
        
        let url = APIUtility.APIConstants.rootURLString + "login/email"
        
        let params = ["email" : email,  "password" : password]
        
        request(.POST, url, parameters: params).responseSwiftyJSON() {
            (request, response, json, error) in
            
            if (response?.statusCode == 200) {
                let user = User(json: json)
                let apiKey = json["apikey"].stringValue
                completion(user: user, apiKey: apiKey)
            } else {
                completion(user: nil, apiKey : nil)
            }
            
        }
        
    }

    
    
    static func loginWithFacebook (accessToken: String, completion : (user : User, apiKey : String) -> Void) {
    
        let url = APIUtility.APIConstants.rootURLString + "login/facebook"

        let params = ["access_token" : accessToken]        
       
        request(.POST, url, parameters: params).responseSwiftyJSON() {
            (request, response, json, error) in
            
            let user = User(json: json)
            let apiKey = json["apikey"].stringValue
            
            completion(user: user, apiKey: apiKey)
            
        }

        
    }
    
    
    static func loginWithGoogle(accessToken: String, completion : (user : User, apiKey : String) -> Void) {
        
        let url = APIUtility.APIConstants.rootURLString + "login/google"
        
        let params = ["access_token" : accessToken]
        
        request(.POST, url, parameters: params).responseSwiftyJSON() {
            (request, response, json, error) in
            
            let user = User(json: json)
            let apiKey = json["apikey"].stringValue
            
            completion(user: user, apiKey: apiKey)
            
        }
        
        
    }
    
    
    static func updateUser(user : User, completion : (completed : Bool, message : String?) -> Void)  {
        
    }
   
}
