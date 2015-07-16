//
//  UserOperations.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 8/5/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

struct UserOperations {
    
    
    static func register (email : String, name : String, password : String, gender : String, birthYear : String, completion : (user : User?, apiKey : String?, error: NSError?) -> Void) {
        
        let url = APIUtility.APIConstants.rootURLString + "register"
        
        let params = ["email" : email, "name" : name, "password" : password, "gender" : gender, "birthYear" : birthYear]
        
        request(.POST, url, parameters: params).responseSwiftyJSON() {
            (request, response, json, error) in
            
            let apiKey = json["apikey"].stringValue

            if (apiKey != "") {
                let user = User(json: json)
                completion(user: user, apiKey: apiKey, error: nil)
                
            } else if (response?.statusCode == 404) {
                completion(user: nil, apiKey: nil, error: nil)
                
            } else {
                completion(user: nil, apiKey: nil, error: error)
            }
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
    
    
    static func updateUser(user : User, newPassword : String?, imageUrl : String?, completion : (completed : Bool, user : User?, message : String?) -> Void)  {
        
        let url = APIUtility.APIConstants.rootURLString + "user/profile"
        var params : [String : AnyObject] = ["name" : user.name,
            "email" : user.email,
            "gender" : user.gender
        ]
        
        
        if let password = newPassword {
            params["password"] = password
        }
        
        if let url = imageUrl {
            params["image_url"] = url
        }
        
        
        APIUtility.authenticatedManager().request(.PUT, url, parameters: params).responseSwiftyJSON() {
            (request, response, json, error) in
            
            let user = User(json: json)
            completion(completed: true, user: user, message: nil)
            
        }
    }
    
    
    static func getUserDetails(completion : ((user : User?) -> Void)) {
        
        let url = APIUtility.APIConstants.rootURLString + "user/profile"
        
        APIUtility.authenticatedManager().request(.GET, url, parameters: nil).responseSwiftyJSON { (request, response, json, error) -> Void in
            
            if (response?.statusCode != 200) {
                
                let user = User(json: json)
                completion(user: user)
                
            } else {
                completion(user:nil)
            }
            
            
        }
    }
    
    
    static func uploadAvatar (image : UIImage, completion: ((completed : Bool, imageUrl : String?) -> Void)) {
        
        let url = APIUtility.APIConstants.rootURLString + "image"
        let params = ["image_type" : "avatar",
            "file_name" : "avatar.jpg"]
        
        // Step one, get request url
        APIUtility.authenticatedManager().request(.POST, url, parameters: params).responseSwiftyJSON { (request, response, json, error) -> Void in
            
            
            if let requestUrl = json["request_url"].string {
                
                let accessUrl = json["access_url"].stringValue
                
                let data = UIImageJPEGRepresentation(image, 0.8)
                
                var headers = Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
                headers["Content-Type"] = "image/jpeg"
                let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
                configuration.HTTPAdditionalHeaders = headers
                let manager = Manager(configuration: configuration)
                
                // Step two, PUT the image to the request url
                manager.upload(.PUT, requestUrl, data : data).responseSwiftyJSON({ (request, response, json, error) -> Void in
                    
                    if (response?.statusCode != 200) {
                        completion(completed: false, imageUrl : nil)
                        return
                    }
                    
                    completion(completed: true, imageUrl: accessUrl)
                    
                    
                })
                
            } else {
                completion(completed: false, imageUrl : nil)
                return
            }
            
        }
        
        
    }
    
    static func resetPassword (email : String, completion : ((completed : Bool) -> Void)) {
        
        let url = APIUtility.APIConstants.rootURLString + "login/email/reset"
        let params = ["email" : email]
        
        request(.POST, url, parameters: params).responseSwiftyJSON { (request, response, json, error) -> Void in
            
            completion(completed: true)
        }
        
    }
    
}
