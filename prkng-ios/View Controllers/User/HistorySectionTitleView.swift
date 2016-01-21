//
//  HistorySectionTitleView.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 16/06/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class HistorySectionTitleView: UIView {
    
    var label: UILabel
    
    var didSetupSubviews : Bool = false
    var didSetupConstraints : Bool = true
    
    init(frame: CGRect, labelText: String) {
        //we need to do this because in the UITableView, sometimes constraints seem to magically disappear.
        let labelFrame = CGRect(x: 27, y: 0, width: frame.width - 27 - 25, height: frame.height)
        label = UILabel(frame: labelFrame)
        label.text = labelText
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
            make.left.equalTo(self).offset(27)
            make.right.equalTo(self).offset(-25)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
        }
        
    }
    
    
}
