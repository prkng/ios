//
//  DurationSelectionView.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 30/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class DurationSelectionView: UIView {

    var selectionControl : SelectionControl
    
    var didSetupSubviews: Bool
    var didSetupConstraints: Bool
    
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        didSetupSubviews = false
        didSetupConstraints = true
        selectionControl = SelectionControl(titles : [NSLocalizedString("arrival", comment : ""), NSLocalizedString("departure", comment : "") ])
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    
    override func layoutSubviews() {
        
        if(!didSetupSubviews) {
            setupSubviews()
            didSetupConstraints = false
            self.setNeedsUpdateConstraints()
        }
        
        super.layoutSubviews()
    }
    
    override func updateConstraints() {
        
        if(!self.didSetupConstraints) {
            setupConstraints()
        }
        super.updateConstraints()
    }
    
    func setupSubviews() {
        
        // TODO
        didSetupSubviews = true
    }
    
    func setupConstraints() {
        
        // TODO
        didSetupConstraints = true
    }

}




