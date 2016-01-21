//
//  UserOperations.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 8/5/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

struct UserOperations {
    
    static var sharedInstance = UserOperations()
    var deviceTokenString: String?
    
    static func register (email : String, name : String, password : String, gender : String, birthYear : String, completion : (user : User?, apiKey : String?, error: NSError?) -> Void) {
        
        let url = APIUtility.rootURL() + "login/register"
        
        let params = ["email" : email, "name" : name, "password" : password, "gender" : gender, "birthYear" : birthYear]
        
        request(.POST, URLString: url, parameters: params).responseSwiftyJSON() {
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
        
        let url = APIUtility.rootURL() + "login"
        
        let params = ["email" : email,  "password" : password]
        
        request(.POST, URLString: url, parameters: params).responseSwiftyJSON() {
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
        
        let url = APIUtility.rootURL() + "login"
        
        let params = ["type" : "facebook", "access_token" : accessToken]
        
        request(.POST, URLString: url, parameters: params).responseSwiftyJSON() {
            (request, response, json, error) in
            
            let user = User(json: json)
            let apiKey = json["apikey"].stringValue
            
            completion(user: user, apiKey: apiKey)
            
        }
        
        
    }
    
    
    static func loginWithGoogle(accessToken: String, name: String, email: String, profileImageUrl: String, completion : (user : User, apiKey : String) -> Void) {
        
        let url = APIUtility.rootURL() + "login"
        
        let params = ["type" : "google",
            "access_token" : accessToken,
            "name" : name,
            "email": email,
            "picture": profileImageUrl]
        
        request(.POST, URLString: url, parameters: params).responseSwiftyJSON() {
            (request, response, json, error) in
            
            let user = User(json: json)
            let apiKey = json["apikey"].stringValue
            
            completion(user: user, apiKey: apiKey)
            
        }
        
        
    }
    
    
    static func updateUser(user : User, newPassword : String?, imageUrl : String?, completion : (completed : Bool, user : User?, message : String?) -> Void)  {
        
        let url = APIUtility.rootURL() + "user/profile"
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
            
            let apiKey = json["apikey"].stringValue
            if apiKey != "" {
                let user = User(json: json)
                completion(completed: true, user: user, message: nil)
            } else {
                completion(completed: false, user: nil, message: nil)
            }
        }
    }
    
    
    static func getUserDetails(completion : ((user : User?) -> Void)) {
        
        let url = APIUtility.rootURL() + "user/profile"
        
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
        
        let url = APIUtility.rootURL() + "images"
        let params = ["image_type" : "avatar",
            "file_name" : "avatar.jpg"]
        
        // Step one, get request url
        APIUtility.authenticatedManager().request(.POST, url, parameters: params).responseSwiftyJSON { (request, response, json, error) -> Void in
            
            
            if let requestUrl = json["request_url"].string {
                
                let accessUrl = json["access_url"].stringValue
                
                let data = UIImageJPEGRepresentation(image, 0.8)!
                
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
        
        let url = APIUtility.rootURL() + "login/resetpass"
        let params = ["email" : email]
        
        request(.POST, URLString: url, parameters: params).responseSwiftyJSON { (request, response, json, error) -> Void in
            
            completion(completed: response != nil && response!.statusCode != 400)
        }
        
    }
    
    static func helloItsMe(deviceTokenString: String?, completion : ((completed : Bool) -> Void)) {
        
        UserOperations.sharedInstance.deviceTokenString = deviceTokenString
        
        let url = APIUtility.rootURL() + "hello"
        
        let locale = NSLocale.currentLocale().objectForKey(NSLocaleLanguageCode) as? String ?? ""
        let deviceType = "ios"
        
        let params: [String : AnyObject] = [
            "device_type" : deviceType,
            "device_id" : (deviceTokenString ?? ""),
            "lang" : locale,
            "city" : Settings.selectedCity().name,
            "push_on_temp_restriction" : Settings.shouldFilterForSnowRemoval() ? "true" : "false"
        ]
        
        APIUtility.authenticatedManager().request(.POST, url, parameters: params).responseSwiftyJSON() {
            (request, response, json, error) in
            
            completion(completed: response != nil && response!.statusCode < 400)
        }

    }
    func helloItsMe(completion : ((completed : Bool) -> Void)) {
        UserOperations.helloItsMe(deviceTokenString, completion: completion)
    }

}
