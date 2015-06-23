//
//  ScheduleLeftView.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-06-22.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class ScheduleLeftView: UIView {
    
    private var horizontalSeperator : UIView
    private var scheduleTimes : [ScheduleTimeModel] //time intervals to know when to place the values
    var timeLabels : [PRKLabel]
    
    var didSetupSubviews : Bool
    var didSetupConstraints : Bool

    convenience init(model : [ScheduleTimeModel]) {
        
        self.init(frame:CGRectZero)
        scheduleTimes = model

        setupSubviews()
        self.setNeedsUpdateConstraints()

    }
    
    override init(frame: CGRect) {
        
        didSetupSubviews = false
        didSetupConstraints = false
        
        horizontalSeperator = UIView()
        scheduleTimes = []
        timeLabels = []
        
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func updateConstraints() {
        
        if !didSetupConstraints {
            setupConstraints()
        }
        
        super.updateConstraints()
    }
    
    private func setupSubviews() {
        
        self.backgroundColor = Styles.Colors.cream2

        horizontalSeperator.backgroundColor = Styles.Colors.beige1
        addSubview(horizontalSeperator)
        
        for scheduleTime in scheduleTimes {
            var label = PRKLabel()
            label.text = scheduleTime.toString()
            label.font = Styles.FontFaces.light(12)
            label.textAlignment = NSTextAlignment.Right
            label.textColor = Styles.Colors.petrol2
            label.scheduleTimeModel = scheduleTime
            
            timeLabels.append(label)
            self.addSubview(label)
        }
        
        didSetupSubviews = true
    }
    
    private func setupConstraints () {
        
        horizontalSeperator.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self)
            make.bottom.equalTo(self)
            make.right.equalTo(self)
            make.width.equalTo(0.5)
        }
        
        didSetupConstraints = true
    }
    
    
}
