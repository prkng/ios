//
//  ScheduleDayIndicatorView.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 07/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class ScheduleDayIndicatorView: UIView {

    var labels : Array<UILabel>
    
    var didSetupSubviews: Bool
    var didSetupConstraints: Bool
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        didSetupSubviews = false
        didSetupConstraints = false
        labels = []
        super.init(frame: frame)
        
        setupSubviews()
        self.setNeedsUpdateConstraints()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    
    override func updateConstraints() {
        if(!self.didSetupConstraints) {
            setupConstraints()
        }
        
        super.updateConstraints()
    }
    
    
    func setupSubviews () {
        
        self.backgroundColor = Styles.Colors.petrol2
        
        for i in 0...6 {
            var label : UILabel = dayLabel()
            addSubview(label)
            labels.append(label)
        }
        
        
    }
    
    func setupConstraints (){
        
        labels[0].snp_makeConstraints { (make) -> () in
            make.left.equalTo(self)
            make.centerY.equalTo(self)
            make.width.equalTo(self).multipliedBy(0.14)
        }
        
        for i in 1...6 {
            
            labels[i].snp_makeConstraints({ (make) -> () in
                make.left.equalTo(self.labels[i-1].snp_right)
                make.centerY.equalTo(self)
                make.width.equalTo(self).multipliedBy(0.14)
            })
            
        }
        
    }
    
    func setDays (days : Array<String>) {
        
        var i : Int = 0
        for day in days {
            labels[i++].text = day
        }
        
    }
    
    
    func dayLabel () -> UILabel {
        var label : UILabel = UILabel()
        label.font = Styles.FontFaces.light(17)
        label.textColor = Styles.Colors.cream1
        label.textAlignment = NSTextAlignment.Center
        return label
    }
    
    
}
