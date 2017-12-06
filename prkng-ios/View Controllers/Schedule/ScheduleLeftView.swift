//
//  ScheduleLeftView.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-06-22.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class ScheduleLeftView: UIView {
    
    fileprivate var horizontalSeperator : UIView
    fileprivate var scheduleTimes : [ScheduleTimeModel] //time intervals to know when to place the values
    var timeLabels : [PRKLabel]
    
    var didSetupSubviews : Bool
    var didSetupConstraints : Bool

    convenience init(model : [ScheduleTimeModel]) {
        
        self.init(frame:CGRect.zero)
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
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func updateConstraints() {
        
        if !didSetupConstraints {
            setupConstraints()
        }
        
        super.updateConstraints()
    }
    
    fileprivate func setupSubviews() {
        
        self.backgroundColor = Styles.Colors.cream2

        horizontalSeperator.backgroundColor = Styles.Colors.beige1
        addSubview(horizontalSeperator)
        
        for scheduleTime in scheduleTimes {
            let label = PRKLabel()
            label.text = scheduleTime.timeInterval.toString(condensed: true)
            label.font = Styles.FontFaces.light(12)
            label.textAlignment = NSTextAlignment.right
            label.textColor = Styles.Colors.petrol2
            label.scheduleTimeModel = scheduleTime
            
            timeLabels.append(label)
            self.addSubview(label)
        }
        
        didSetupSubviews = true
    }
    
    fileprivate func setupConstraints () {
        
        horizontalSeperator.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self)
            make.bottom.equalTo(self)
            make.right.equalTo(self)
            make.width.equalTo(0.5)
        }
        
        didSetupConstraints = true
    }
    
    
}
