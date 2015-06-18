//
//  APIUtility.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 13/02/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class APIUtility: NSObject {

    struct APIConstants {
#if DEBUG
        static let rootURLString = "http://54.144.3.236/"
#else
        static let rootURLString = "https://api.prk.ng/"
#endif
    }
    
    class func rootURL() -> String {
        return APIConstants.rootURLString;
    }
    
    class func authenticatedManager () -> Manager {
        
        var headers = Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
        headers["X-API-KEY"] = AuthUtility.authToken()
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = headers
        
        
        return Manager(configuration: configuration)        
    }
    
    


}
