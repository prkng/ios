//
//  HistorySectionTitleView.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 16/06/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class HistorySectionTitleView: UIView {
    
    let label = UILabel()    
    
    var didSetupSubviews : Bool = false
    var didSetupConstraints : Bool = true
    
    override func layoutSubviews() {
        if (!didSetupSubviews) {
            setupSubviews()
        }
        super.layoutSubviews()
    }
    
    override func updateConstraints() {
        if (!didSetupConstraints) {
            setupConstraints()
            setNeedsUpdateConstraints()
        }
        super.updateConstraints()
    }
    
    
    func setupSubviews() {
        
        backgroundColor = Styles.Colors.red2
        
        label.font = Styles.FontFaces.light(12)
        label.textColor = Styles.Colors.cream1
        addSubview(label)
        
        
        didSetupSubviews = true
        didSetupConstraints = false
    }
    
    func setupConstraints () {
        
        label.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self).with.offset(27)
            make.right.equalTo(self).with.offset(-25)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
        }
        
    }
    
    
}
