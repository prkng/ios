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
    
    var limited : Bool
    
    private var didSetupSubviews : Bool
    private var didSetupConstraints : Bool
    
    convenience init(model : ScheduleItemModel) {
        self.init(frame:CGRectZero)
        
        self.limited = (model.timeLimitText != nil)
        
        if(limited) {
            imageView = ViewFactory.timeMaxIcon(Int(model.limit/60), addMaxLabel: true, color: Styles.Colors.cream2)

        } else {
            imageView = ViewFactory.forbiddenIcon(Styles.Colors.berry2)
        }
    }
    
    convenience init() {
        self.init(frame:CGRectZero)
    }
    
     override init(frame: CGRect) {
        
        containerView = UIView()
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
        
        self.addSubview(containerView)
        
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        containerView.addSubview(imageView)
        
        if(limited) {
            self.backgroundColor = Styles.Colors.midnight1

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
        
        didSetupConstraints = true
    }
    
}
