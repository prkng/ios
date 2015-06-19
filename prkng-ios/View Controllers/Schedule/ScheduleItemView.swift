//
//  ScheduleCollectionViewCell.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 03/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class ScheduleItemView : UIView {
    
    var imageView : UIImageView
    var timeLimitLabel : UILabel

    var limited : Bool
    
    private var didSetupSubviews : Bool
    private var didSetupConstraints : Bool
    
    convenience init(model : ScheduleItemModel) {
        self.init(frame:CGRectZero)
        
        self.limited = (model.timeLimitText != nil)
        
        if(limited) {
            imageView.image = UIImage(named: "icon_timemax")
            timeLimitLabel.text = model.timeLimitText
        } else {
            timeLimitLabel.hidden = true
            imageView.image = UIImage(named: "icon_forbidden")
        }
    }
    
    convenience init() {
        self.init(frame:CGRectZero)
    }
    
     override init(frame: CGRect) {
        
        timeLimitLabel = UILabel()
        imageView = UIImageView()
        
        didSetupSubviews = false
        didSetupConstraints = true
        
        limited =  false
        
        super.init(frame: frame)
        
    }

     required init(coder aDecoder: NSCoder) {
         fatalError("NSCoding not supported")
     }
    
    override func layoutSubviews() {
        if (!didSetupSubviews) {
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
        
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        self.addSubview(imageView)
        
        timeLimitLabel.font = Styles.FontFaces.regular(17)
        timeLimitLabel.textAlignment = NSTextAlignment.Center
        timeLimitLabel.textColor = Styles.Colors.white
        timeLimitLabel.adjustsFontSizeToFitWidth = true
        timeLimitLabel.numberOfLines = 1
        timeLimitLabel.sizeToFit()
        self.addSubview(timeLimitLabel)
        
        if(limited) {
            self.backgroundColor = Styles.Colors.midnight1

        } else {
            self.backgroundColor = Styles.Colors.red2
            
        }
        
        didSetupSubviews = true
        didSetupConstraints = false
    }
    
    
    func setupConstraints () {
        
        imageView.snp_makeConstraints { (make) -> () in
            make.center.equalTo(self)
            make.size.lessThanOrEqualTo(CGSize(width: 25, height: 25))
            make.size.lessThanOrEqualTo(self).with.offset(-2)
        }
        
        timeLimitLabel.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.imageView)
            make.centerY.equalTo(self.imageView).with.offset(-1)
            make.size.equalTo(CGSize(width: 17, height: 25))
        }
        
        didSetupConstraints = true
    }
    
}
