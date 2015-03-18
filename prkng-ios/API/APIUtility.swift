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
        static let rootURLString = "http://ks29236.kimsufi.com:5000/"
#else
        static let rootURLString = "http://ks29236.kimsufi.com:5000/"
#endif
    }


    class func rootURL() -> String {
        return APIConstants.rootURLString;
    }

}
