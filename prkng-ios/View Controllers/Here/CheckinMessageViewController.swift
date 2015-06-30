//
//  CheckinMessageViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 11/05/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class CheckinMessageViewController: GAITrackedViewController {
    
    var containerView: UIView
    var imageView : UIImageView
    var titleContainer : UIView
    var titleLabel : UILabel
    var subtitleLabel : UILabel
    var textContainer : UIView
    var textLabel : UILabel
    
    let X_TRANSFORM = CGFloat(100)
    let Y_TRANSFORM = UIScreen.mainScreen().bounds.size.height
    
    init() {
        
        containerView = UIView()
        imageView = UIImageView()
        titleContainer = UIView()
        titleLabel = UILabel()
        subtitleLabel = UILabel()
        textContainer = UIView()
        textLabel = UILabel()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    
    override func loadView() {
        view = UIView()
        setupSubviews()
        setupConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenName = "Here - Checkin Message"
        
        let translateTransform = CATransform3DMakeTranslation(X_TRANSFORM, Y_TRANSFORM, 0)
        let rotateTransform = CATransform3DMakeRotation(CGFloat(-M_PI_4), 0, 0, 1)
        let scaleTransform = CATransform3DMakeScale(0.5, 0.5, 1)
        
        containerView.layer.transform = CATransform3DConcat(CATransform3DConcat(rotateTransform, translateTransform), scaleTransform)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        animate()
    }    
    
    func setupSubviews() {
        
        view.backgroundColor = Styles.Colors.transparentBackground
        
        view.addSubview(containerView)
        
        imageView.image =  UIImage(named:"first_checkin_header")
        imageView.contentMode = UIViewContentMode.ScaleAspectFit
        containerView.addSubview(imageView)
        
        titleContainer.backgroundColor = Styles.Colors.cream2
        containerView.addSubview(titleContainer)
        
        titleLabel.font = Styles.Fonts.h1
        titleLabel.textColor = Styles.Colors.petrol2
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.text = "first_checkin_title".localizedString
        containerView.addSubview(titleLabel)
        
        subtitleLabel.font = Styles.FontFaces.regular(17)
        subtitleLabel.textColor = Styles.Colors.red2
        subtitleLabel.textAlignment = NSTextAlignment.Center
        subtitleLabel.text = "first_checkin_subtitle".localizedString
        containerView.addSubview(subtitleLabel)
        
        textContainer.backgroundColor = Styles.Colors.cream2
        textContainer.layer.borderColor = Styles.Colors.beige1.CGColor
        textContainer.layer.borderWidth = 0.5
        containerView.addSubview(textContainer)
        
        textLabel.font = Styles.FontFaces.light(17)
        textLabel.textColor = Styles.Colors.petrol2
        textLabel.numberOfLines = 0
        textLabel.textAlignment = NSTextAlignment.Left
        textLabel.text = "first_checkin_text".localizedString
        containerView.addSubview(textLabel)
        
    }
    
    func setupConstraints () {
        
        containerView.snp_makeConstraints { (make) -> () in
            make.centerY.equalTo(self.view)
            make.left.equalTo(self.view).with.offset(24)
            make.right.equalTo(self.view).with.offset(-24)
        }
        
        titleContainer.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.imageView.snp_bottom)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.bottom.equalTo(self.textContainer.snp_top)
        }
        
        imageView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.containerView)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
        }
        
        titleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.imageView.snp_bottom).with.offset(17)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
        }
        
        
        subtitleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.titleLabel.snp_bottom).with.offset(7)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
        }
        
        textContainer.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.textLabel).with.offset(-14)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.bottom.equalTo(self.textLabel).with.offset(14)
        }
        
        textLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.subtitleLabel.snp_bottom).with.offset(25)
            make.left.equalTo(self.containerView).with.offset(24)
            make.right.equalTo(self.containerView).with.offset(-24)
            make.bottom.equalTo(self.containerView).with.offset(-14)
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
