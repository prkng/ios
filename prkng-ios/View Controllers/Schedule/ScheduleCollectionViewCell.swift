//
//  ScheduleCollectionViewCell.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 03/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class ScheduleCollectionViewCell: UICollectionViewCell {
    
    var startTimeLabel : UILabel
    var startAmPmLabel : UILabel
    var endTimeLabel : UILabel
    var endAmPmLabel : UILabel
    
    var didsetupSubviews : Bool
    var didSetupConstraints : Bool
    
     override init(frame: CGRect) {
        
        startTimeLabel = UILabel()
        startAmPmLabel = UILabel()
        endTimeLabel = UILabel()
        endAmPmLabel = UILabel()
        
        didsetupSubviews = false
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
    
    
    func setupSubviews () {
        
        startTimeLabel.font = Styles.FontFaces.regular(17)
        startTimeLabel.textColor = Styles.Colors.cream1
        self.contentView.addSubview(startTimeLabel)
        
        startAmPmLabel.font = Styles.FontFaces.light(17)
        startAmPmLabel.textColor = Styles.Colors.cream1
        self.contentView.addSubview(startAmPmLabel)
        
        endTimeLabel.font = Styles.FontFaces.regular(17)
        endTimeLabel.textColor = Styles.Colors.cream1
        self.contentView.addSubview(endTimeLabel)
        
        endAmPmLabel.font = Styles.FontFaces.light(17)
        endAmPmLabel.textColor = Styles.Colors.cream1
        self.contentView.addSubview(endAmPmLabel)
        
        didsetupSubviews = true
    }
    
    
    func setupConstraints () {        
        
        startTimeLabel.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.contentView.snp_centerY)
            make.centerX.equalTo(self.contentView).with.offset(-20)
        }
        
        startAmPmLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.startTimeLabel.snp_right).with.offset(10)
            make.top.equalTo(self.startTimeLabel)
            make.bottom.equalTo(self.startTimeLabel)
        }
        
        endTimeLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.contentView.snp_centerY)
            make.centerX.equalTo(self.contentView).with.offset(-20)
        }
        
        endAmPmLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.endTimeLabel.snp_right).with.offset(10)
            make.top.equalTo(self.endTimeLabel)
            make.bottom.equalTo(self.endTimeLabel)
        }
        
        didSetupConstraints = true
        
    }
}
