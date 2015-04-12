//
//  SearchResult.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 10/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class SearchResult {
    
    var title : String
    var location : CLLocation
    
    init(title: String, location : CLLocation) {
        self.title = title
        self.location = location
    }
   
}
