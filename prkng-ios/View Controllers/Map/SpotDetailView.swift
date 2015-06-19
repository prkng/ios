//
//  SpotDetailView.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 26/03/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class SpotDetailView: UIView {

    var topContainer: UIView
    var titleLabel: UILabel
    var topContainerRightView: UIView
    var checkinImageView: UIImageView
    var checkinImageLabel: UILabel

    var bottomContainer: UIView
    var availableTextLabel: UILabel
    var availableTimeLabel: UILabel
    var scheduleImageView: UIImageView

    var didSetupSubviews: Bool
    var didSetupConstraints: Bool
    
    var delegate : SpotDetailViewDelegate?
    
    convenience init() {
        self.init(frame: CGRectZero)
    }

    override init(frame: CGRect) {

        topContainer = UIView()
        titleLabel = UILabel()
        topContainerRightView = UIView()
        checkinImageView = UIImageView()
        checkinImageLabel = UILabel()
        
        bottomContainer = UIView()
        availableTextLabel = UILabel()
        availableTimeLabel = UILabel()
        scheduleImageView = UIImageView()

        didSetupSubviews = false
        didSetupConstraints = false
        
        super.init(frame: frame)
        
        setupSubviews()
        self.setNeedsUpdateConstraints()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
//    override func layoutSubviews() {
//        if(!self.didSetupSubviews)
//    }
    
    override func updateConstraints() {
        if(!self.didSetupConstraints) {
            setupConstraints()
        }
        
        super.updateConstraints()
    }

    func setupSubviews() {
        
        let topTapRec = UITapGestureRecognizer(target: self, action: Selector("topContainerTapped:"))
        topContainer.addGestureRecognizer(topTapRec)
        topContainer.backgroundColor = Styles.Colors.red2
        addSubview(topContainer)

        titleLabel.font = Styles.Fonts.h2
        titleLabel.textColor = Styles.Colors.cream1
        titleLabel.textAlignment = NSTextAlignment.Left
        topContainer.addSubview(titleLabel)
        
        topContainer.addSubview(topContainerRightView)

        checkinImageView.image = UIImage(named:"btn_checkin_active")
        checkinImageView.contentMode = UIViewContentMode.ScaleAspectFit
        topContainerRightView.addSubview(checkinImageView)
        
        checkinImageLabel.font = Styles.FontFaces.regular(10)
        checkinImageLabel.textColor = Styles.Colors.cream1
        checkinImageLabel.textAlignment = NSTextAlignment.Center
        checkinImageLabel.text = NSLocalizedString("check-in", comment: "")
        topContainerRightView.addSubview(checkinImageLabel)
        
        let bottomTapRec = UITapGestureRecognizer(target: self, action: Selector("bottomContainerTapped:"))
        bottomContainer.addGestureRecognizer(bottomTapRec)
        bottomContainer.backgroundColor = Styles.Colors.stone
        addSubview(bottomContainer)

        availableTextLabel.font = Styles.FontFaces.light(11)
        availableTextLabel.textColor = Styles.Colors.petrol2
        availableTextLabel.textAlignment = NSTextAlignment.Left
        availableTextLabel.numberOfLines = 1
        availableTextLabel.text = NSLocalizedString("until", comment: "").uppercaseString
        bottomContainer.addSubview(availableTextLabel)

        availableTimeLabel.font = Styles.Fonts.h1r
        availableTimeLabel.adjustsFontSizeToFitWidth = true
        availableTimeLabel.textColor = Styles.Colors.petrol2
        availableTimeLabel.textAlignment = NSTextAlignment.Left
        availableTimeLabel.text = "00:00"
        bottomContainer.addSubview(availableTimeLabel)
        
        scheduleImageView.image = UIImage(named:"btn_schedule")
        scheduleImageView.contentMode = UIViewContentMode.Center
        bottomContainer.addSubview(scheduleImageView)

        didSetupSubviews = true
    }

    func setupConstraints() {

        topContainer.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(Styles.Sizes.spotDetailViewTopPortionHeight)
        }

        titleLabel.snp_makeConstraints { (make) -> () in
            make.centerY.equalTo(self.topContainer)
            make.left.equalTo(self.topContainer).with.offset(24)
            make.right.lessThanOrEqualTo(self.topContainerRightView.snp_left)
        }
        
        topContainerRightView.snp_makeConstraints { (make) -> () in
            make.centerY.equalTo(self.topContainer)
            make.right.equalTo(self.topContainer).with.offset(-22)
            make.height.equalTo(Styles.Sizes.spotDetailViewTopPortionHeight)
            make.width.equalTo(56)
        }
        
        checkinImageView.snp_makeConstraints { (make) -> () in
            make.height.equalTo(40)
            make.centerX.equalTo(self.topContainerRightView)
            make.top.equalTo(self.topContainerRightView).with.offset(5)
        }

        checkinImageLabel.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.topContainerRightView)
            make.bottom.equalTo(self.topContainerRightView).with.offset(-10)
        }
        
        bottomContainer.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.topContainer.snp_bottom)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.bottom.equalTo(self)
        }

        availableTextLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.bottomContainer).with.offset(24)
            make.top.equalTo(self.bottomContainer).with.offset(9)
        }
        
        availableTimeLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.bottomContainer).with.offset(24)
            make.bottom.equalTo(self.bottomContainer).with.offset(-9)
            make.right.lessThanOrEqualTo(self.scheduleImageView.snp_left)
        }
        
        scheduleImageView.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSize(width: 22, height: Styles.Sizes.spotDetailViewBottomPortionHeight))// + 22))
            make.centerY.equalTo(self.bottomContainer)
            make.right.equalTo(self.bottomContainer).with.offset(-39)
        }

        didSetupConstraints = true
    }
    
    
    func topContainerTapped (sender : AnyObject?) {
        
        if(delegate != nil) {
            delegate!.topContainerTapped()
        }
    }

    func bottomContainerTapped (sender : AnyObject?) {

        if(delegate != nil) {
            delegate!.bottomContainerTapped()
        }
    }
    
}



protocol SpotDetailViewDelegate {
    
    func topContainerTapped()
    func bottomContainerTapped()
    
}