//
//  LotHeaderView.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-09-02.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class LotHeaderView: UIView, UIGestureRecognizerDelegate {
        
    private var topContainer: UIView
    var titleLabel: MarqueeLabel
    private var leftImageView: UIImageView
    private var rightView: UIView
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
        titleLabel = MarqueeLabel()
        leftImageView = UIImageView()
        rightView = UIImageView()
        
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
        
        addSubview(topContainer)
        
        titleLabel.animationDelay = 2
        titleLabel.font = Styles.Fonts.h3r
        titleLabel.textColor = Styles.Colors.cream1
        titleLabel.textAlignment = NSTextAlignment.Left
        topContainer.addSubview(titleLabel)
        
        leftImageView.image = UIImage(named: "btn_back_outline")
        leftImageView.contentMode = UIViewContentMode.Center
        topContainer.addSubview(leftImageView)
        
        rightView.contentMode = UIViewContentMode.Center
        topContainer.addSubview(rightView)
        
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
            make.left.equalTo(self.leftImageView.snp_right).with.offset(4)
            make.right.equalTo(self.rightView.snp_left).with.offset(-10)
            make.bottom.equalTo(self.topContainer).with.offset(-20)
        }
        
        leftImageView.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(20, 20)) //real size is CGSizeMake(11, 9)
            make.left.equalTo(self.topContainer).with.offset(10)
            make.bottom.equalTo(self.topContainer).with.offset(-22)
        }
        
        rightView.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(17, 15))
            make.right.equalTo(self.topContainer).with.offset(-33)
            make.bottom.equalTo(self.topContainer).with.offset(-25)
        }
        
        materialDesignButton.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.topContainer)
        }
        
        didSetupConstraints = true
    }
    
    func handleTap(tapRec: UITapGestureRecognizer) {
//        let tap = tapRec.locationInView(self)
//        let point = rightView.convertPoint(rightView.bounds.origin, toView: self)
//        let distance = tap.distanceToPoint(point)
//        if distance < 40 {
//            self.delegate?.tappedRightButton()
//        } else {
            self.delegate?.tappedBackButton()
//        }
    }
    
}