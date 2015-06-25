//
//  DayButton.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 29/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class DayButton: UIControl {
    
    var titleLabel : UILabel
    var title : String?
    
    
    var didSetupSubviews: Bool
    var didSetupConstraints: Bool
    
    
    override init(frame: CGRect) {
        
        titleLabel = UILabel()
        
        didSetupSubviews = false
        didSetupConstraints = true
        
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
        
        titleLabel.text = title
        titleLabel.font = Styles.Fonts.h1
        titleLabel.textAlignment = NSTextAlignment.Center
        selected = false
        addSubview(titleLabel)
        
        didSetupSubviews = true
    }
    
    func setupConstraints() {
        
        self.titleLabel.snp_makeConstraints { (make) -> () in
            make.center.equalTo(self)
        }
        
        didSetupConstraints = true
    }
    
    
    
    override var selected: Bool {
        
        didSet {
            
            if(selected) {
                titleLabel.textColor = Styles.Colors.cream1
                backgroundColor = Styles.Colors.red2
            } else {
                titleLabel.textColor = Styles.Colors.anthracite1
                backgroundColor = Styles.Colors.cream1
            }
            
        }
    }
    
    
    
    
}