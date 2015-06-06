//
//  ScheduleCollectionViewCell.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 03/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class ScheduleItemView : UIView {
    
    var timeLimitLabel : UILabel
    var maxLabel : UILabel
    var startTimeLabel : UILabel
    var startAmPmLabel : UILabel
    var endTimeLabel : UILabel
    var endAmPmLabel : UILabel
    var rightSeperator : UIView
    
    var limited : Bool
    
    private var didsetupSubviews : Bool
    private var didSetupConstraints : Bool
    
    convenience init(model : ScheduleItemModel) {
        self.init(frame:CGRectZero)
        
        self.startTimeLabel.text = model.startTime
        self.startAmPmLabel.text = model.startTimeAmPm
        self.endTimeLabel.text = model.endTime
        self.endAmPmLabel.text = model.endTimeAmPm
        
        self.limited = (model.timeLimitText != nil)
        
        if(limited) {
            timeLimitLabel.text = model.timeLimitText
        } else {
            timeLimitLabel.hidden = true
            maxLabel.hidden = true
        }
    }
    
    convenience init() {
        self.init(frame:CGRectZero)
    }
    
     override init(frame: CGRect) {
        
        timeLimitLabel = UILabel()
        maxLabel = UILabel()
        
        startTimeLabel = UILabel()
        startAmPmLabel = UILabel()
        endTimeLabel = UILabel()
        endAmPmLabel = UILabel()
        rightSeperator = UIView()
        
        didsetupSubviews = false
        didSetupConstraints = true
        
        limited =  false
        
        super.init(frame: frame)
        
    }

     required init(coder aDecoder: NSCoder) {
         fatalError("NSCoding not supported")
     }
    
    override func layoutSubviews() {
        if (!didsetupSubviews) {
            setupSubviews()
            self.setNeedsUpdateConstraints()
        }
        
        super.layoutSubviews()
    }
    
    override func updateConstraints() {
        if(!didSetupConstraints) {
            setupConstraints()
        }
        
        super.updateConstraints()
    }
    
    
    func setupSubviews () {
        
        
        timeLimitLabel.font = Styles.FontFaces.regular(17)
        timeLimitLabel.textColor = Styles.Colors.cream1
        timeLimitLabel.adjustsFontSizeToFitWidth = true
        timeLimitLabel.numberOfLines = 1
        self.addSubview(timeLimitLabel)
        
        maxLabel.font = Styles.FontFaces.light(17)
        maxLabel.textColor = Styles.Colors.cream1
        maxLabel.adjustsFontSizeToFitWidth = true
        maxLabel.numberOfLines = 1
        maxLabel.text = "max".localizedString.uppercaseString
        self.addSubview(maxLabel)
        
        startTimeLabel.font = Styles.FontFaces.regular(17)
        startTimeLabel.textColor = Styles.Colors.cream1
        startTimeLabel.adjustsFontSizeToFitWidth = true
        startTimeLabel.numberOfLines = 1
        self.addSubview(startTimeLabel)
        
        startAmPmLabel.font = Styles.FontFaces.light(17)
        startAmPmLabel.textColor = Styles.Colors.cream1
        startAmPmLabel.adjustsFontSizeToFitWidth = true
        startAmPmLabel.numberOfLines = 1
        self.addSubview(startAmPmLabel)
        
        endTimeLabel.font = Styles.FontFaces.regular(17)
        endTimeLabel.textColor = Styles.Colors.cream1
        endTimeLabel.adjustsFontSizeToFitWidth = true
        endTimeLabel.numberOfLines = 1
        self.addSubview(endTimeLabel)
        
        endAmPmLabel.font = Styles.FontFaces.light(17)
        endAmPmLabel.textColor = Styles.Colors.cream1
        endAmPmLabel.adjustsFontSizeToFitWidth = true
        endAmPmLabel.numberOfLines = 1
        self.addSubview(endAmPmLabel)
        
        self.addSubview(rightSeperator)
        
        if(limited) {
            self.backgroundColor = Styles.Colors.midnight1
            rightSeperator.backgroundColor = Styles.Colors.midnight2

        } else {
            self.backgroundColor = Styles.Colors.red2
            rightSeperator.backgroundColor = Styles.Colors.red1

        }
        
        didsetupSubviews = true
        didSetupConstraints = false
    }
    
    
    func setupConstraints () {
        
        timeLimitLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.snp_top)
            make.bottom.equalTo(self.snp_centerY).with.offset(2)
            make.centerX.equalTo(self).with.offset(-20)
        }
        
        maxLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.timeLimitLabel.snp_right).with.offset(10)
            make.top.equalTo(self.timeLimitLabel)
            make.bottom.equalTo(self.timeLimitLabel)
        }
        
        
        startTimeLabel.snp_makeConstraints { (make) -> () in
            make.top.greaterThanOrEqualTo(self.snp_top)
            make.bottom.equalTo(self.snp_centerY).with.offset(2)
            make.centerX.equalTo(self).with.offset(-20)
        }
        
        startAmPmLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.startTimeLabel.snp_right).with.offset(10)
            make.top.equalTo(self.startTimeLabel)
            make.bottom.equalTo(self.startTimeLabel)
        }
        
        endTimeLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.snp_centerY)
            make.centerX.equalTo(self).with.offset(-20)
            make.bottom.lessThanOrEqualTo(self.snp_bottom)
        }
        
        endAmPmLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.endTimeLabel.snp_right).with.offset(10)
            make.top.equalTo(self.endTimeLabel)
            make.bottom.equalTo(self.endTimeLabel)
        }
        
        rightSeperator.snp_makeConstraints { (make) -> () in
            make.right.equalTo(self)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
            make.width.equalTo(0.5)
        }
        
        didSetupConstraints = true
    }
    
    
    func setHours (model : ScheduleItemModel) {
        startTimeLabel.text = model.startTime
        startAmPmLabel.text = model.startTimeAmPm
        endTimeLabel.text = model.endTime
        endAmPmLabel.text = model.endTimeAmPm
    }
    
    func startPulsate() {
        hideLabels()
        
        var pulseAnimation:CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        pulseAnimation.duration = 0.55
        pulseAnimation.fromValue = 0.7
        pulseAnimation.toValue = 1
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        pulseAnimation.autoreverses = true
        pulseAnimation.repeatCount = FLT_MAX
        self.layer.addAnimation(pulseAnimation, forKey: nil)
    }
    
    func stopPulsate() {
        self.layer.removeAllAnimations()
        showLabels()
    }
    
    private func hideLabels() {
        timeLimitLabel.hidden = true
//         maxLabel.hidden = true
         startTimeLabel.hidden = true
         startAmPmLabel.hidden = true
         endTimeLabel.hidden = true
         endAmPmLabel.hidden = true
    }
    
    private func showLabels() {
        timeLimitLabel.hidden = false
//        maxLabel.hidden = false
        startTimeLabel.hidden = false
        startAmPmLabel.hidden = false
        endTimeLabel.hidden = false
        endAmPmLabel.hidden = false
    }
    
}
