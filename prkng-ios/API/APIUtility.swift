//
//  APIUtility.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 13/02/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit
import Alamofire

class APIUtility: NSObject {

    static var isUsingTestServer: Bool {
        return UserDefaults.standard.bool(forKey: "use_test_server")
    }
    
    fileprivate struct APIConstants {
        static let rootURLString = isUsingTestServer ? "https://test.prk.ng/v1/" : "https://api.prk.ng/v1/"
        static let rootTestURLString = "https://test.prk.ng/v1/"
    }
    
    //set test server in debug console with NSUserDefaults.standardUserDefaults().setObject(true, forKey:"use_test_server")
    
    class func rootURL() -> String {
        let urlString = isUsingTestServer ? APIConstants.rootTestURLString : APIConstants.rootURLString
        return urlString
    }
    
    class func authenticatedManager() -> SessionManager {
        
        var headers = SessionManager.defaultHTTPHeaders
        headers["X-API-KEY"] = AuthUtility.authToken()
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = headers
        
        return Alamofire.SessionManager(configuration: configuration)
    }
    
    


}
