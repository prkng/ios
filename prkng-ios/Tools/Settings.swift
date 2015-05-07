//
//  Settings.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 01/05/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

struct Settings {
    
    static func selectedCity() -> String  {
        
        var city = NSUserDefaults.standardUserDefaults().objectForKey("selectedCity") as? String
        
        if (city == nil) {
            city = "Montreal"
            NSUserDefaults.standardUserDefaults().setObject(city, forKey: "selectedCity")
        }
        
        return city!
    }
    
    static func setSelectedCity (city : String) {
        NSUserDefaults.standardUserDefaults().setObject(city, forKey: "selectedCity")
    }
   
}
