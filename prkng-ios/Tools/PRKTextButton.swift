//
//  PRKTextButton.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-06-24.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class PRKTextButton: UIView {

    private var imageSize: CGSize
    private var labelText: String
    private var labelFont: UIFont
    private var image: UIImage?
    
    private var button: UIButton
    private var imageView: UIImageView
    private var label: UILabel
    
    private var didsetupSubviews : Bool
    private var didSetupConstraints : Bool


    init(image: UIImage?, imageSize: CGSize, labelText: String, labelFont: UIFont) {
        
        self.image = image
        self.imageSize = imageSize
        self.labelText = labelText
        self.labelFont = labelFont

        button = UIButton()
        imageView = UIImageView()
        label = UILabel()
        
        didsetupSubviews = false
        didSetupConstraints = true
        
        super.init(frame: CGRectZero)

    }
    
    init() {
        
        button = UIButton()
        imageView = UIImageView()
        label = UILabel()
        
        imageSize = CGSizeZero
        labelText = ""
        labelFont = Styles.FontFaces.regular(17)

        didsetupSubviews = false
        didSetupConstraints = true

        super.init(frame: CGRectZero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        if (!didsetupSubviews) {
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
        
        self.clipsToBounds = true
        self.backgroundColor = Styles.Colors.red2
        self.layer.cornerRadius = imageSize.height / 2
        
        self.addSubview(imageView)
        imageView.image = image
        imageView.contentMode = UIViewContentMode.Center
        
        label.text = labelText
        label.font = labelFont
        label.textColor = Styles.Colors.cream1
        self.addSubview(label)
        
        self.addSubview(button)
        
        didsetupSubviews = true
        didSetupConstraints = false
    }
    
    func setupConstraints () {
        
        button.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self)
        }
        
        imageView.snp_makeConstraints { (make) -> () in
            make.size.equalTo(self.imageSize)
            make.right.equalTo(self)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
        }

        self.setLabelText(labelText)
        
    }
    
    func setImage(image: UIImage?) {
        if self.image != image {
            self.image = image
            animateChangeImageTo()
        }
    }
    
    private func animateChangeImageTo() {
        
        let fadeAnimation = CATransition()
        fadeAnimation.duration = 0.2
        fadeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        fadeAnimation.type = kCATransitionFade
        self.imageView.layer.addAnimation(fadeAnimation, forKey: "fade")
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, CGFloat(M_PI))
            self.imageView.image = self.image
        })
    }
    
    func addTarget(target: AnyObject?, action: Selector, forControlEvents controlEvents: UIControlEvents) {
        self.button.addTarget(target, action: action, forControlEvents: controlEvents)
    }
    
    func setLabelText(text: String) {
        if text == "" {
            label.snp_remakeConstraints { (make) -> () in
                make.left.equalTo(self)
                make.right.equalTo(self.imageView.snp_left)
                make.centerY.equalTo(self)
            }
        } else {
            label.snp_remakeConstraints { (make) -> () in
                make.left.equalTo(self).with.offset(12)
                make.right.equalTo(self.imageView.snp_left).with.offset(2)
                make.centerY.equalTo(self)
            }
        }
        
        self.setNeedsLayout()

        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.layoutIfNeeded()
        })
        
        self.labelText = text
        self.label.text = text
    }
    
    func setLabelFont(labelFont: UIFont) {
        self.labelFont = labelFont
        self.label.font = labelFont
    }

}
