//
//  ScheduleHeaderView.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 03/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class ModalHeaderView: UIView, UIGestureRecognizerDelegate {
    
    private var topContainer: UIView
    var titleLabel: UILabel
    private var leftImageView: UIImageView
    private var rightImageView: UIImageView
    private var materialDesignButton: UIButton
    
    var delegate: ModalHeaderViewDelegate?
    
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
        leftImageView = UIImageView()
        rightImageView = UIImageView()
        
        materialDesignButton = ViewFactory.checkInButton()
        
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
        
//        topContainer.backgroundColor = Styles.Colors.red2
        addSubview(topContainer)
        
        titleLabel.font = Styles.Fonts.h2
        titleLabel.textColor = Styles.Colors.cream1
        titleLabel.textAlignment = NSTextAlignment.Center
        topContainer.addSubview(titleLabel)
        
        leftImageView.image = UIImage(named: "btn_back_outline")
        leftImageView.contentMode = UIViewContentMode.ScaleAspectFit
        topContainer.addSubview(leftImageView)

        rightImageView.image = UIImage(named: "btn_list")
        rightImageView.contentMode = UIViewContentMode.ScaleAspectFit
        topContainer.addSubview(rightImageView)

        topContainer.addSubview(materialDesignButton)
        topContainer.sendSubviewToBack(materialDesignButton)

        let tapRec = UITapGestureRecognizer(target: self, action: "handleTap:")
        tapRec.delegate = self
        materialDesignButton.addGestureRecognizer(tapRec)

        
        didSetupSubviews = true
    }
    
    func setupConstraints() {
        
        topContainer.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(Styles.Sizes.modalViewHeaderHeight)
        }
        
        titleLabel.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.topContainer)
            make.left.lessThanOrEqualTo(self.leftImageView.snp_right).with.offset(10)
            make.right.lessThanOrEqualTo(self.rightImageView.snp_left).with.offset(-10)
            make.bottom.equalTo(self.topContainer).with.offset(-13)
        }
        
        leftImageView.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(24, 22))
            make.centerX.equalTo(self.topContainer).multipliedBy(0.33)
            make.bottom.equalTo(self.topContainer).with.offset(-18)
        }

        rightImageView.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(24, 22))
            make.centerX.equalTo(self.topContainer).multipliedBy(1.66)
            make.bottom.equalTo(self.topContainer).with.offset(-18)
        }
        
        materialDesignButton.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.topContainer)
        }
        
        
        didSetupConstraints = true
    }
    
    func handleTap(tapRec: UITapGestureRecognizer) {
        let tap = tapRec.locationInView(self)
        let point = rightImageView.convertPoint(rightImageView.bounds.origin, toView: self)
        let distance = tap.distanceToPoint(point)
        if distance < 30 {
            self.delegate?.tappedRightButton()
        } else {
            self.delegate?.tappedBackButton()
        }
    }
    
}

protocol ModalHeaderViewDelegate {
    func tappedBackButton()
    func tappedRightButton()
}
