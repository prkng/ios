//
//  APIUtility.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 13/02/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class APIUtility: NSObject {

    static var isUsingTestServer: Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey("use_test_server")
    }
    
    private struct APIConstants {
        static let rootURLString = isUsingTestServer ? "https://test.prk.ng/v1/" : "https://api.prk.ng/v1/"
        static let rootTestURLString = "https://test.prk.ng/v1/"
    }
    
    //set test server in debug console with NSUserDefaults.standardUserDefaults().setObject(true, forKey:"use_test_server")
    
    class func rootURL() -> String {
        let urlString = isUsingTestServer ? APIConstants.rootTestURLString : APIConstants.rootURLString
        return urlString
    }
    
    class func authenticatedManager () -> Manager {
        
        var headers = Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
        headers["X-API-KEY"] = AuthUtility.authToken()
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = headers
        
        
        return Manager(configuration: configuration)        
    }
    
    


}
