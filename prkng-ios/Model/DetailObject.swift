//
//  Lot.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-08-24.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

protocol DetailObject {
   
    var compact: Bool { get }
    var identifier: String { get }
    
    var headerText: String { get }
    var headerIconName: String { get }
    var doesHeaderIconWiggle: Bool { get }
    var headerIconSubtitle: String { get }
    
    var bottomLeftIconName: String? { get }
    var bottomLeftTitleText: String? { get }
    var bottomLeftPrimaryText: NSAttributedString? { get }
    var bottomLeftWidth: Int { get }

    var bottomRightTitleText: String { get }
    var bottomRightPrimaryText: NSAttributedString { get }
    var bottomRightIconName: String? { get }
    
    var showsBottomLeftContainer: Bool { get //{ return bottomLeftTitleText == nil && bottomLeftPrimaryText == nil } 
        }
    
}

class DetailObjectLoading: DetailObject {
    
    private var parent: DetailObject
    
    init(parent: DetailObject) {
        self.parent = parent
    }
    
    var compact: Bool { get { return parent.compact } }
    var identifier: String { get { return parent.identifier } }
    
    var headerText: String { get { return parent.headerText } }
    var headerIconName: String { return parent.headerIconName }
    var doesHeaderIconWiggle: Bool { get { return parent.doesHeaderIconWiggle } }
    var headerIconSubtitle: String { get { return parent.headerIconSubtitle } }
    
    var bottomLeftIconName: String? { get { return nil } }
    var bottomLeftTitleText: String? { get { return nil } }
    var bottomLeftPrimaryText: NSAttributedString? { get { return nil } }
    var bottomLeftWidth: Int { get { return parent.bottomLeftWidth } }
    
    var bottomRightTitleText: String { get { return "" } }
    var bottomRightPrimaryText: NSAttributedString { get { return NSAttributedString(string: "loading".localizedString, attributes: [NSFontAttributeName: Styles.Fonts.h3, NSBaselineOffsetAttributeName: 5]) } }
    var bottomRightIconName: String? { get { return nil } }
    
    var showsBottomLeftContainer: Bool { get { return parent.showsBottomLeftContainer } }

}