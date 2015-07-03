//
//  SupportedArea.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-07-03.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class SupportedArea: NSObject {
    
    var latestVersion: Int
    var versions: [Int: [String: String]]
    
    init(json: JSON) {
        
        latestVersion = json["latest_version"].intValue
        versions = [Int: [String: String]]()

        for version in json["versions"] {
            
            var addresses = [String : String]()
            for addressSet in version.1.dictionaryValue {
                addresses.updateValue(addressSet.1.stringValue, forKey: addressSet.0)
            }
            
            let key = version.0.toInt()!
            versions.updateValue(addresses, forKey: key)
        }

    }

}
