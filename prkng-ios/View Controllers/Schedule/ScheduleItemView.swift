//
//  ScheduleCollectionViewCell.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 03/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class ScheduleItemView : UIView {
    
    private var containerView : UIView
    private var imageView : UIImageView
    private var timeLimitLabel : UILabel
    private var maxLabel : UILabel
    
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
        
        containerView = UIView()
        timeLimitLabel = UILabel()
        imageView = UIImageView()
        
        didSetupSubviews = false
        didSetupConstraints = true
        
        limited =  false
        maxLabel = UILabel()

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
        
        self.addSubview(containerView)
        
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        containerView.addSubview(imageView)
        
        timeLimitLabel.font = Styles.FontFaces.regular(17)
        timeLimitLabel.textAlignment = NSTextAlignment.Center
        timeLimitLabel.textColor = Styles.Colors.white
        timeLimitLabel.adjustsFontSizeToFitWidth = true
        timeLimitLabel.numberOfLines = 1
        timeLimitLabel.sizeToFit()
        containerView.addSubview(timeLimitLabel)
        
        maxLabel.text = "max".localizedString.uppercaseString
        maxLabel.font = Styles.FontFaces.regular(12)
        maxLabel.textAlignment = NSTextAlignment.Center
        maxLabel.textColor = Styles.Colors.white
        maxLabel.adjustsFontSizeToFitWidth = true
        maxLabel.numberOfLines = 1
        maxLabel.sizeToFit()
        
        if(limited) {
            self.backgroundColor = Styles.Colors.midnight1
            containerView.addSubview(maxLabel)

        } else {
            self.backgroundColor = Styles.Colors.red2
            
        }
        
        didSetupSubviews = true
        didSetupConstraints = false
    }
    
    
    func setupConstraints () {
        
        containerView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self)
            make.center.equalTo(self)
        }
        
        imageView.snp_makeConstraints { (make) -> () in
            make.center.equalTo(self.containerView)
            make.size.lessThanOrEqualTo(CGSize(width: 25, height: 25))
            make.size.lessThanOrEqualTo(self.containerView).with.offset(-2)
        }
        
        timeLimitLabel.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.imageView)
            make.centerY.equalTo(self.imageView).with.offset(1) //plus moves down, minus moves up
            make.size.equalTo(CGSize(width: 15, height: 17))
        }
        
        if limited {
            maxLabel.snp_makeConstraints({ (make) -> () in
                make.centerX.equalTo(self.imageView)
                make.centerY.equalTo(self.imageView).with.offset(25)
            })
        }
        
        didSetupConstraints = true
    }
    
}
