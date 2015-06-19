//
//  ScheduleHeaderView.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 03/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class ScheduleHeaderView: UIView {
    
    var topContainer : UIView
    var titleLabel : UILabel
    var scheduleImageView : UIImageView
    
    var bottomContainer : UIView
    var authorizedView : InfoView
    var limitedView : InfoView
    var forbiddenView : InfoView
    
    var didSetupSubviews: Bool
    var didSetupConstraints: Bool
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    
    override init(frame: CGRect) {
        
        didSetupSubviews = false
        didSetupConstraints = false
        
        topContainer = UIView ()
        titleLabel = UILabel()
        scheduleImageView = UIImageView()
        
        bottomContainer = UIView ()
        authorizedView = InfoView()
        limitedView = InfoView()
        forbiddenView = InfoView()
        
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
        
        topContainer.backgroundColor = Styles.Colors.red2
        addSubview(topContainer)
        
        titleLabel.font = Styles.Fonts.h2
        titleLabel.textColor = Styles.Colors.cream1
        titleLabel.textAlignment = NSTextAlignment.Center
        topContainer.addSubview(titleLabel)
        
        scheduleImageView.image = UIImage(named: "btn_map_return")
        scheduleImageView.contentMode = UIViewContentMode.ScaleAspectFit
        topContainer.addSubview(scheduleImageView)
        
        bottomContainer.backgroundColor = Styles.Colors.stone
        addSubview(bottomContainer)
        
        authorizedView.dotView.backgroundColor = Styles.Colors.cream1
        authorizedView.detailLabel.text = NSLocalizedString("schedule_authorized",comment:"")
        limitedView.detailLabel.sizeToFit()
        bottomContainer.addSubview(authorizedView)
        
        limitedView.dotView.backgroundColor = Styles.Colors.petrol2
        limitedView.detailLabel.text = NSLocalizedString("schedule_limited",comment:"")
        limitedView.detailLabel.sizeToFit()
        bottomContainer.addSubview(limitedView)
        
        forbiddenView.dotView.backgroundColor = Styles.Colors.red2
        forbiddenView.detailLabel.text = NSLocalizedString("schedule_forbidden",comment:"")
        limitedView.detailLabel.sizeToFit()
        bottomContainer.addSubview(forbiddenView)
        
        didSetupSubviews = true
    }
    
    func setupConstraints() {
        
        topContainer.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(90)
        }
        
        titleLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.topContainer).with.offset(60)
            make.right.equalTo(self.topContainer).with.offset(-60)
            make.bottom.equalTo(self.topContainer).with.offset(-13)
        }
        
        scheduleImageView.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(24, 22))
            make.right.equalTo(self.topContainer).with.offset(-32)
            make.bottom.equalTo(self.topContainer).with.offset(-18)
        }
        
        
        bottomContainer.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.topContainer.snp_bottom)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(52)
        }
        
        authorizedView.snp_makeConstraints { (make) -> () in
            make.width.equalTo(self.bottomContainer).dividedBy(3.0)
            make.top.equalTo(self.bottomContainer)
            make.bottom.equalTo(self.bottomContainer)
            make.left.equalTo(self.bottomContainer)
        }
        
        limitedView.snp_makeConstraints { (make) -> () in
            make.width.equalTo(self.bottomContainer).dividedBy(3.0)
            make.top.equalTo(self.bottomContainer)
            make.bottom.equalTo(self.bottomContainer)
            make.centerX.equalTo(self.bottomContainer)
        }
        
        forbiddenView.snp_makeConstraints { (make) -> () in
            make.width.equalTo(self.bottomContainer).dividedBy(3.0)
            make.top.equalTo(self.bottomContainer)
            make.bottom.equalTo(self.bottomContainer)
            make.right.equalTo(self.bottomContainer)
        }
        
        
        didSetupConstraints = true
    }
    
}


class InfoView: UIView {
    
    var dotView : UIView
    var detailLabel : UILabel
    
    var didSetupSubviews: Bool
    var didSetupConstraints: Bool
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        
        didSetupSubviews = false
        didSetupConstraints = false
        
        dotView = UIView()
        detailLabel = UILabel()
        
        super.init(frame: frame)
        
        setupSubviews()
        self.setNeedsUpdateConstraints()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    
    override func layoutSubviews() {
        detailLabel.sizeToFit()
        super.layoutSubviews()
    }
    
    override func updateConstraints() {
        if(!self.didSetupConstraints) {
            setupConstraints()
        }
        super.updateConstraints()
    }
    
    func setupSubviews() {
        
        dotView.layer.cornerRadius = 5
        dotView.clipsToBounds = true
        addSubview(dotView)
        
        detailLabel.font = Styles.FontFaces.light(12)
        detailLabel.textColor = Styles.Colors.midnight2
        addSubview(detailLabel)
        
        
        didSetupSubviews = true
    }
    
    func setupConstraints() {
        
        dotView.snp_makeConstraints { (make) -> () in
            make.right.equalTo(self.detailLabel.snp_left).with.offset(-10)
            make.centerY.equalTo(self)
            make.size.equalTo(CGSizeMake(10, 10))
        }
        
        detailLabel.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self).with.offset(15)
            make.centerY.equalTo(self).with.offset(2)
            make.height.equalTo(15)
        }
        
        didSetupConstraints = true
    }
    
    
}
