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
    private var headerTitleLabel: MarqueeLabel
    private var titleLabel: MarqueeLabel
    private var titleLabelCentered: MarqueeLabel
    private var leftImageView: UIImageView
    private var rightImageView: UIImageView
    private var rightView: UIView
    var rightViewTitleLabel: UILabel
    var rightViewPrimaryLabel: UILabel
    private var materialDesignButton: UIButton
    private var isRightImageViewRotated: Bool = false
    
    var delegate: ModalHeaderViewDelegate?
    
    var topText: String {
        didSet {
            let splitAddressString = topText.splitAddressString
            headerTitleLabel.text = splitAddressString.0
            titleLabel.text = splitAddressString.1
            titleLabelCentered.text = ""
            
            if (headerTitleLabel.text ?? "") == "" {
                titleLabel.text = ""
                titleLabelCentered.text = splitAddressString.1
            }

        }
    }
    
    var didSetupSubviews: Bool
    var didSetupConstraints: Bool
    
    var showsRightButton: Bool {
        didSet {
            rightImageView.hidden = !showsRightButton
        }
    }
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        
        didSetupSubviews = false
        didSetupConstraints = false
        
        topContainer = UIView ()
        headerTitleLabel = MarqueeLabel()
        titleLabel = MarqueeLabel()
        titleLabelCentered = MarqueeLabel()
        leftImageView = UIImageView()
        rightImageView = UIImageView()
        rightView = UIView()
        rightViewTitleLabel = UILabel()
        rightViewPrimaryLabel = UILabel()
        
        materialDesignButton = ViewFactory.checkInButton()
        
        topText = ""
        showsRightButton = true
        
        super.init(frame: frame)
        
        setupSubviews()
        self.setNeedsUpdateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
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
        
        headerTitleLabel.animationDelay = 2
        headerTitleLabel.font = Styles.FontFaces.light(11)
        headerTitleLabel.textColor = Styles.Colors.cream2
        headerTitleLabel.textAlignment = NSTextAlignment.Left
        topContainer.addSubview(headerTitleLabel)
        
        titleLabel.font = Styles.Fonts.h2Variable
        titleLabel.textColor = Styles.Colors.cream2
        titleLabel.textAlignment = NSTextAlignment.Left
        topContainer.addSubview(titleLabel)

        titleLabelCentered.font = Styles.Fonts.h2Variable
        titleLabelCentered.textColor = Styles.Colors.cream2
        titleLabelCentered.textAlignment = NSTextAlignment.Left
        topContainer.addSubview(titleLabelCentered)

        leftImageView.image = UIImage(named: "btn_back_outline")
        leftImageView.contentMode = UIViewContentMode.Center
        topContainer.addSubview(leftImageView)

        rightImageView.image = UIImage(named: "btn_menu")
        rightImageView.contentMode = UIViewContentMode.Center
        topContainer.addSubview(rightImageView)

        topContainer.addSubview(rightView)
        
        rightViewTitleLabel.font = Styles.FontFaces.light(11)
        rightViewTitleLabel.textColor = Styles.Colors.cream1
        rightViewTitleLabel.textAlignment = NSTextAlignment.Center
        rightView.addSubview(rightViewTitleLabel)
        
        rightViewPrimaryLabel.textColor = Styles.Colors.cream1
        rightViewPrimaryLabel.textAlignment = NSTextAlignment.Center
        rightView.addSubview(rightViewPrimaryLabel)
        
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
            make.height.equalTo(self)
        }
        
        headerTitleLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.leftImageView.snp_right).offset(5)
            make.right.lessThanOrEqualTo(self.rightImageView.snp_left).offset(-10)
            make.right.lessThanOrEqualTo(self.rightView.snp_left).offset(-10)
            make.bottom.equalTo(self.titleLabel.snp_top).offset(1)
        }

        titleLabel.snp_remakeConstraints { (make) -> () in
            make.left.equalTo(self.leftImageView.snp_right).offset(4)
            make.right.lessThanOrEqualTo(self.rightImageView.snp_left).offset(-10)
            make.right.lessThanOrEqualTo(self.rightView.snp_left).offset(-10)
            make.bottom.equalTo(self.topContainer).offset(-15)
        }

        titleLabelCentered.snp_remakeConstraints { (make) -> () in
            make.left.equalTo(self.leftImageView.snp_right).offset(4)
            make.right.lessThanOrEqualTo(self.rightImageView.snp_left).offset(-10)
            make.right.lessThanOrEqualTo(self.rightView.snp_left).offset(-10)
            make.centerY.equalTo(self.topContainer)
        }

        leftImageView.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(20, 20)) //real size is CGSizeMake(11, 9)
            make.left.equalTo(self.topContainer).offset(10)
            make.centerY.equalTo(self.topContainer)
        }

        rightImageView.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(17, 15))
            make.right.equalTo(self.topContainer).offset(-33)
            make.bottom.equalTo(self.topContainer).offset(-25)
        }
        
        rightView.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSize(width:34, height:40))
            make.right.equalTo(self.topContainer).offset(-42)
            make.centerY.equalTo(self.topContainer)
        }
        
        rightViewTitleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.rightView)
            make.centerX.equalTo(self.rightView)
        }

        rightViewPrimaryLabel.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.rightView)
            make.centerX.equalTo(self.rightView)
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
        if distance < 40 {
            self.delegate?.tappedRightButton()
        } else {
            self.delegate?.tappedBackButton()
        }
    }
    
    func makeRightButtonList(animated: Bool) {

        let duration = animated ? 0.2 : 0
        UIView.animateWithDuration(duration, animations: {
            self.rightImageView.transform = CGAffineTransformMakeRotation((0.0 * CGFloat(M_PI)) / 180.0)
        })
        
        isRightImageViewRotated = false
    }

    func makeRightButtonColumns(animated: Bool) {
        
        let duration = animated ? 0.2 : 0
        UIView.animateWithDuration(duration, animations: {
            self.rightImageView.transform = CGAffineTransformMakeRotation((-90.0 * CGFloat(M_PI)) / 180.0)
        })

        isRightImageViewRotated = true
    }

}

protocol ModalHeaderViewDelegate {
    func tappedBackButton()
    func tappedRightButton()
}
