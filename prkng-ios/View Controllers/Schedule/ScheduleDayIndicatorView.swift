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
    
    var indicator : UIView
    
    var indicatorXConstraint : CGFloat?
    
    var minX : CGFloat?
    var maxX : CGFloat?
    
    var didSetupSubviews: Bool
    var didSetupConstraints: Bool
    
    var indicatorWidth : CGFloat
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        didSetupSubviews = false
        didSetupConstraints = true
        labels = []
        indicator = UIView()
        indicatorWidth = 0.0
        super.init(frame: frame)
        
        for _ in 0...6 {
            labels.append(dayLabel())
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    
    override func updateConstraints() {
        
        if(!self.didSetupConstraints) {
            setupConstraints()
        }
        
        super.updateConstraints()
    }
    
    override func layoutSubviews() {
        
        indicatorWidth = frame.width * 0.4
        
        if (!didSetupSubviews) {
            setupSubviews()
            self.setNeedsUpdateConstraints()
        }
        
        
        if (minX == nil || maxX == nil) {
            minX = 6.0 //TODO
            maxX = self.bounds.size.width - indicatorWidth - 6.0 - 6.0
        }
        
        super.layoutSubviews()
    }
    
    func setupSubviews () {
        
        self.backgroundColor = Styles.Colors.petrol2
        
        for label in labels {
            addSubview(label)
        }
        
        indicator.layer.borderWidth = 1.0
        indicator.layer.cornerRadius = 13.0
        indicator.layer.borderColor = UIColor.whiteColor().CGColor
        indicator.clipsToBounds = true
        addSubview(indicator)
        
        didSetupSubviews = true
        didSetupConstraints = false
    }
    
    func setupConstraints() {
        
        labels[0].snp_makeConstraints { (make) -> () in
            make.left.equalTo(self)
            make.centerY.equalTo(self)
            make.width.equalTo(self).multipliedBy(0.14)
        }
        
        for i in 1...6 {
            
            labels[i].snp_makeConstraints(closure: { (make) -> () in
                make.left.equalTo(self.labels[i-1].snp_right)
                make.centerY.equalTo(self)
                make.width.equalTo(self).multipliedBy(0.14)
            })
            
        }
        
        indicator.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self).offset(6)
            make.height.equalTo(26)
            make.width.equalTo(self.indicatorWidth)
            make.centerY.equalTo(self).offset(-1)
        }
        self.indicatorXConstraint = 6
        
    }
    
    func setDays (days : Array<String>) {
        
        var i : Int = 0
        for day in days {
            labels[i++].text = day
        }
    }
    
    func dayLabel() -> UILabel {
        let label : UILabel = UILabel()
        label.font = Styles.FontFaces.light(17)
        label.textColor = Styles.Colors.cream1
        label.textAlignment = NSTextAlignment.Center
        return label
    }
    
    
    func setPositionRatio (ratio : CGFloat) {
        
        let offset : CGFloat = ((maxX! - minX!) * ratio) + minX!
//        self.indicatorXConstraint?.offset(offset)
        
        indicator.snp_remakeConstraints { (make) -> () in
            make.left.equalTo(self).offset(offset)
            make.height.equalTo(26)
            make.width.equalTo(self.indicatorWidth)
            make.centerY.equalTo(self).offset(-1)
        }
        
        self.indicatorXConstraint = offset
    }
    
    
}
