//
//  Lot.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-08-24.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

protocol DetailObject {
   
    var identifier: String { get }
    
    var headerText: String { get }
    var headerIconName: String { get }
    var doesHeaderIconWiggle: Bool { get }
    var headerIconSubtitle: String { get }
    
    var bottomLeftTitleText: String? { get }
    var bottomLeftPrimaryText: NSAttributedString? { get }
    var bottomLeftWidth: Int { get }

    var bottomRightTitleText: String { get }
    var bottomRightPrimaryText: NSAttributedString { get }
    var bottomRightIconName: String? { get }
    
    var showsBottomLeftContainer: Bool { get //{ return bottomLeftTitleText == nil && bottomLeftPrimaryText == nil } 
        }
    
}
