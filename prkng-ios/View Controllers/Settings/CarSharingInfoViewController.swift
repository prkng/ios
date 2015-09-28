//
//  HereFirstUseViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 28/05/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class CarSharingInfoViewController: GAITrackedViewController {

    var containerView: UIView
    
    
    var iconView : UIImageView
    
    var titleContainer : UIView
    var titleLabel : UILabel
    var subtitleLabel : UILabel
    
    var textContainer : UIView
    var textLabel : UILabel
    
    let X_TRANSFORM = CGFloat(100)
    let Y_TRANSFORM = UIScreen.mainScreen().bounds.size.height
    
    let cornerRadius: CGFloat = 8
    
    let titleIconName = "icon_car2go"
    let titleText = "car_sharing_info_title".localizedString
    let subTitleText = "car_sharing_info_subtitle".localizedString
    let messageText = "car_sharing_info_message".localizedString
    
    init() {

        containerView = UIView()
        
        iconView = UIImageView()
        
        titleContainer = UIView()
        titleLabel = UILabel()
        subtitleLabel = UILabel()
        
        textContainer = UIView()
        textLabel = UILabel()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    
    override func loadView() {
        view = UIView()
        setupSubviews()
        setupConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenName = "Car Sharing Info View"
        
        if #available(iOS 8.0, *) {
            let translateTransform = CATransform3DMakeTranslation(X_TRANSFORM, Y_TRANSFORM, 0)
            let rotateTransform = CATransform3DMakeRotation(CGFloat(-M_PI_4), 0, 0, 1)
            let scaleTransform = CATransform3DMakeScale(0.5, 0.5, 1)
            containerView.layer.transform = CATransform3DConcat(CATransform3DConcat(rotateTransform, translateTransform), scaleTransform)
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if #available(iOS 8.0, *) {
            animate()
        }
    }
    
    func setupSubviews() {
        
        view.backgroundColor = Styles.Colors.transparentBackground
        
        containerView.layer.cornerRadius = cornerRadius
        containerView.backgroundColor = Styles.Colors.cream2
        view.addSubview(containerView)
        
        titleContainer.backgroundColor = Styles.Colors.cream2
        titleContainer.layer.cornerRadius = cornerRadius
        containerView.addSubview(titleContainer)
        
        iconView.image = UIImage(named: titleIconName)
        containerView.addSubview(iconView)
        
        titleLabel.font = Styles.Fonts.h2Variable
        titleLabel.textColor = Styles.Colors.petrol2
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.text = titleText
        titleLabel.numberOfLines = 0
        containerView.addSubview(titleLabel)
        
        subtitleLabel.font = Styles.FontFaces.regular(15)
        subtitleLabel.textColor = Styles.Colors.red2
        subtitleLabel.textAlignment = NSTextAlignment.Center
        subtitleLabel.text = subTitleText
        subtitleLabel.numberOfLines = 0
        containerView.addSubview(subtitleLabel)
        
        textContainer.backgroundColor = Styles.Colors.cream2
        textContainer.layer.borderColor = Styles.Colors.beige1.CGColor
        textContainer.layer.borderWidth = 0.5
        textContainer.layer.cornerRadius = cornerRadius
        containerView.addSubview(textContainer)
                
        textLabel.font = Styles.FontFaces.light(15)
        textLabel.textColor = Styles.Colors.petrol2
        textLabel.numberOfLines = 0
        textLabel.textAlignment = NSTextAlignment.Center
        textLabel.text = messageText
        containerView.addSubview(textLabel)
        
    }
    
    func setupConstraints () {
        
        containerView.snp_makeConstraints { (make) -> () in
            make.center.equalTo(self.view)
            make.left.equalTo(self.view).offset(24)
            make.right.equalTo(self.view).offset(-24)
        }
        
        iconView.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.containerView)
            make.centerY.equalTo(self.containerView.snp_top)
            make.size.equalTo(CGSizeMake(36, 36))
        }
        
        titleContainer.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.containerView)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.bottom.equalTo(self.subtitleLabel).offset(14)
        }

        titleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.titleContainer).offset(25)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
        }
        
        subtitleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.titleLabel.snp_bottom).offset(7)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
        }
        
        textContainer.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.titleContainer.snp_bottom)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.bottom.equalTo(self.containerView)
        }
        
        textLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.textContainer).offset(14)
            make.left.equalTo(self.textContainer).offset(24)
            make.right.equalTo(self.textContainer).offset(-24)
            make.bottom.equalTo(self.textContainer).offset(-22)
        }

        
    }
    
    func animate() {
        
        let translateAnimation = POPSpringAnimation(propertyNamed: kPOPLayerTranslationXY)
        translateAnimation.fromValue = NSValue(CGPoint: CGPoint(x: X_TRANSFORM, y: Y_TRANSFORM))
        translateAnimation.toValue = NSValue(CGPoint: CGPoint(x: 0, y: 0))
        translateAnimation.springBounciness = 10
        translateAnimation.springSpeed = 12
        
        let rotateAnimation = POPSpringAnimation(propertyNamed: kPOPLayerRotation)
        rotateAnimation.fromValue = NSNumber(double: -M_PI_4)
        rotateAnimation.toValue = NSNumber(float: 0)
        rotateAnimation.springBounciness = 10
        rotateAnimation.springSpeed = 3
        
        let scaleAnimation = POPBasicAnimation(propertyNamed: kPOPLayerScaleXY)
        scaleAnimation.fromValue = NSValue(CGSize: CGSize(width: 0.5, height: 0.5))
        scaleAnimation.toValue =  NSValue(CGSize: CGSize(width: 1, height: 1))
        scaleAnimation.duration = 0.5
        
        containerView.layer.pop_addAnimation(translateAnimation, forKey: "translateAnimation")
        containerView.layer.pop_addAnimation(rotateAnimation, forKey: "rotateAnimation")
        containerView.layer.pop_addAnimation(scaleAnimation, forKey: "scaleAnimation")
        
    }
    
}
