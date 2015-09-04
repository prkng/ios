//
//  PRKTimeSpanView.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-09-02.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class PRKTimeSpanView: UIView {

    private var containerView = UIView()
    var leftLabel = UILabel()
    var rightLabel = UILabel()
    
    private var dayString: String = "" //0 means today, 1 = tomorrow, etc
    private var startTime: NSTimeInterval = 0
    private var endTime: NSTimeInterval = 0
    private var leftSideFont: UIFont = Styles.FontFaces.regular(15)
    private var rightSideFont: UIFont = Styles.FontFaces.regular(14)
    private var textColor: UIColor = Styles.Colors.midnight1
    
    var didSetupSubviews: Bool
    var didSetupConstraints: Bool

    var timePeriodText: String {
        get {
            if startTime == 0 && endTime == 0 {
                return "closed".localizedString.uppercaseString
            } else if startTime == 0 && endTime == 24*3600 {
                return "24H"
            } else {
                let startText = startTime.toString(condensed: false)
                let endText = endTime.toString(condensed: false)
                return startText + " - " + endText
            }
        }
    }
    
    convenience init(dayString: String, startTime: NSTimeInterval, endTime: NSTimeInterval) {
        self.init(dayString: dayString, startTime: startTime, endTime: endTime, leftSideFont: nil, rightSideFont: nil, textColor: nil)
    }

    //this initializer returns the format we use in the lot view controller to list times:
    //  today               3:30 PM - 11:45 PM
    //  aujourd'hui            15:30h - 23:45h
    init(dayString: String, startTime: NSTimeInterval, endTime: NSTimeInterval, leftSideFont: UIFont?, rightSideFont: UIFont?, textColor: UIColor?) {
        
        self.dayString = dayString
        self.startTime = startTime
        self.endTime = endTime
        if leftSideFont != nil {
            self.leftSideFont = leftSideFont!
        }
        if rightSideFont != nil {
            self.rightSideFont = rightSideFont!
        }
        if textColor != nil {
            self.textColor = textColor!
        }
        
        didSetupSubviews = false
        didSetupConstraints = false

        super.init(frame: CGRectZero)
        
        setupSubviews()
        self.setNeedsUpdateConstraints()

    }
    
    override init(frame: CGRect) {
        
        didSetupSubviews = false
        didSetupConstraints = false
        
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
    
    func setupSubviews() {
        
        self.addSubview(containerView)
        
        containerView.addSubview(leftLabel)
        leftLabel.font = leftSideFont
        leftLabel.text = dayString
        leftLabel.textAlignment = .Left
        leftLabel.textColor = textColor
        
        containerView.addSubview(rightLabel)
        rightLabel.font = rightSideFont
        rightLabel.text = timePeriodText
        rightLabel.textAlignment = .Right
        rightLabel.textColor = textColor
        
        didSetupSubviews = true
    }
    
    func setupConstraints() {
        
        self.snp_makeConstraints { (make) -> () in
            make.height.equalTo(self.containerView)
        }
        
        containerView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(self.leftLabel)
        }
        
        leftLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.rightLabel.snp_left)
            make.centerY.equalTo(self.containerView)
        }
        
        rightLabel.snp_makeConstraints { (make) -> () in
            make.right.equalTo(self.containerView)
            make.centerY.equalTo(self.containerView)
        }
        
        didSetupConstraints = true
    }
    
}
