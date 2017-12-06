//
//  ScheduleHeaderView.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 03/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class ModalHeaderView: UIView, UIGestureRecognizerDelegate {
    
    fileprivate var topContainer = UIView()
    fileprivate var headerTitleLabel = MarqueeLabel()
    fileprivate var titleLabel = MarqueeLabel()
    fileprivate var titleLabelCentered = MarqueeLabel()
    fileprivate var leftImageView = UIImageView()
    fileprivate var rightImageView = UIImageView()
    fileprivate var rightView = UIView()
    var rightViewTitleLabel = UILabel()
    var rightViewPrimaryLabel = UILabel()
    fileprivate var rightViewContainer = UIView()
    var rightImageViewWithLabel = UIImageView()
    var rightImageViewLabel = UILabel()
    fileprivate var materialDesignButton = ViewFactory.checkInButton()
    fileprivate var isRightImageViewRotated: Bool = false
    
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
            rightImageView.isHidden = !showsRightButton
        }
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        
        didSetupSubviews = false
        didSetupConstraints = false
        
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
        headerTitleLabel.textAlignment = NSTextAlignment.left
        topContainer.addSubview(headerTitleLabel)
        
        titleLabel.font = Styles.Fonts.h2Variable
        titleLabel.textColor = Styles.Colors.cream2
        titleLabel.textAlignment = NSTextAlignment.left
        topContainer.addSubview(titleLabel)

        titleLabelCentered.font = Styles.Fonts.h2Variable
        titleLabelCentered.textColor = Styles.Colors.cream2
        titleLabelCentered.textAlignment = NSTextAlignment.left
        topContainer.addSubview(titleLabelCentered)

        leftImageView.image = UIImage(named: "btn_back_outline")
        leftImageView.contentMode = UIViewContentMode.center
        topContainer.addSubview(leftImageView)

        rightImageView.image = UIImage(named: "btn_menu")
        rightImageView.contentMode = UIViewContentMode.center
        topContainer.addSubview(rightImageView)

        topContainer.addSubview(rightView)
        
        rightViewTitleLabel.font = Styles.FontFaces.light(11)
        rightViewTitleLabel.textColor = Styles.Colors.cream1
        rightViewTitleLabel.textAlignment = NSTextAlignment.center
        rightView.addSubview(rightViewTitleLabel)
        
        rightViewPrimaryLabel.textColor = Styles.Colors.cream1
        rightViewPrimaryLabel.textAlignment = NSTextAlignment.center
        rightView.addSubview(rightViewPrimaryLabel)
        
        topContainer.addSubview(rightViewContainer)

        rightImageViewWithLabel.contentMode = UIViewContentMode.scaleAspectFit
        rightViewContainer.addSubview(rightImageViewWithLabel)
//        rightImageViewWithLabel.layer.anchorPoint = CGPointMake(0.5,1.0);
//        rightImageViewWithLabel.layer.wigglewigglewiggle()
        
        rightImageViewLabel.font = Styles.FontFaces.bold(10)
        rightImageViewLabel.textColor = Styles.Colors.cream1
        rightImageViewLabel.textAlignment = NSTextAlignment.center
        rightViewContainer.addSubview(rightImageViewLabel)

        topContainer.addSubview(materialDesignButton)
        topContainer.sendSubview(toBack: materialDesignButton)

        let tapRec = UITapGestureRecognizer(target: self, action: #selector(ModalHeaderView.handleTap(_:)))
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
            make.size.equalTo(CGSize(width: 20, height: 20)) //real size is CGSizeMake(11, 9)
            make.left.equalTo(self.topContainer).offset(10)
            make.centerY.equalTo(self.topContainer)
        }

        rightImageView.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSize(width: 17, height: 15))
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
        
        rightViewContainer.snp_makeConstraints { (make) -> () in
            make.centerY.equalTo(self.topContainer)
            make.right.equalTo(self.topContainer.snp_centerX).multipliedBy(1.66).offset(28)
            make.height.equalTo(Styles.Sizes.spotDetailViewTopPortionHeight)
            make.width.equalTo(56)
        }

        rightImageViewWithLabel.snp_makeConstraints { (make) -> () in
            make.height.equalTo(24)
            make.centerX.equalTo(self.rightViewContainer)
            make.bottom.equalTo(rightImageViewLabel.snp_top).offset(-5)
        }
        
        rightImageViewLabel.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.rightViewContainer)
            make.bottom.equalTo(self.rightViewContainer).offset(-14)
        }

        materialDesignButton.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.topContainer)
        }
        
        didSetupConstraints = true
    }
    
    func handleTap(_ tapRec: UITapGestureRecognizer) {
        let tap = tapRec.location(in: self)
        let point = rightImageView.convert(rightImageView.bounds.origin, to: self)
        let distance = tap.distanceToPoint(point)
        if distance < 40 {
            self.delegate?.tappedRightButton()
        } else {
            self.delegate?.tappedBackButton()
        }
    }
    
    func makeRightButtonList(_ animated: Bool) {

        let duration = animated ? 0.2 : 0
        UIView.animate(withDuration: duration, animations: {
            self.rightImageView.transform = CGAffineTransform(rotationAngle: (0.0 * CGFloat(M_PI)) / 180.0)
        })
        
        isRightImageViewRotated = false
    }

    func makeRightButtonColumns(_ animated: Bool) {
        
        let duration = animated ? 0.2 : 0
        UIView.animate(withDuration: duration, animations: {
            self.rightImageView.transform = CGAffineTransform(rotationAngle: (-90.0 * CGFloat(M_PI)) / 180.0)
        })

        isRightImageViewRotated = true
    }

}

protocol ModalHeaderViewDelegate {
    func tappedBackButton()
    func tappedRightButton()
}
