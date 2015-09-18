//
//  HereFirstUseViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 31/05/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class NotesModalViewController: GAITrackedViewController, UITextViewDelegate {

    var containerView: UIView
    
    
    var iconView : UIImageView
    
    var titleContainer : UIView
    var titleLabel : UILabel
    
    var textContainer : UIView
    var textView : SZTextView
    
    let X_TRANSFORM = CGFloat(0)
    let Y_TRANSFORM = UIScreen.mainScreen().bounds.size.height
    
    let titleIconName = "icon_notes"
    let titleText = "report_notes_title".localizedString
    let placeholderText = "report_notes_placeholder".localizedString
    
    init() {

        containerView = UIView()
        
        iconView = UIImageView()
        
        titleContainer = UIView()
        titleLabel = UILabel()
        
        textContainer = UIView()
        textView = SZTextView()
        
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
        self.screenName = "Report View - Notes"
        
        if Settings.iOS8OrLater() {
            let translateTransform = CATransform3DMakeTranslation(X_TRANSFORM, Y_TRANSFORM, 0)
            containerView.layer.transform = translateTransform
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if Settings.iOS8OrLater() {
            animate()
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(300 * NSEC_PER_MSEC)), dispatch_get_main_queue(), {
            self.textView.becomeFirstResponder()
        })
    }
    
    func setupSubviews() {
        
        view.addSubview(containerView)
        
        titleContainer.backgroundColor = Styles.Colors.cream2
        containerView.addSubview(titleContainer)
        
        iconView.image = UIImage(named: titleIconName)
        containerView.addSubview(iconView)
        
        titleLabel.font = Styles.Fonts.h2Variable
        titleLabel.textColor = Styles.Colors.petrol2
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.text = titleText
        titleLabel.numberOfLines = 0
        containerView.addSubview(titleLabel)
        
        textContainer.backgroundColor = Styles.Colors.cream2
        textContainer.layer.borderColor = Styles.Colors.beige1.CGColor
        textContainer.layer.borderWidth = 0.5
        containerView.addSubview(textContainer)
        
        let placeholder = NSAttributedString(string: placeholderText, attributes: [NSFontAttributeName: Styles.FontFaces.regular(15)])
        textView.delegate = self
        textView.attributedPlaceholder = placeholder
        textView.placeholderTextColor = Styles.Colors.greyish
        textView.font = Styles.FontFaces.light(15)
        textView.textColor = Styles.Colors.petrol2
        textView.keyboardAppearance = UIKeyboardAppearance.Default
        textView.textAlignment = NSTextAlignment.Left
        textView.backgroundColor = Styles.Colors.cream2
        containerView.addSubview(textView)
        
    }
    
    func setupConstraints () {
        
        let topOffset = UIScreen.mainScreen().bounds.height / 3
        
        containerView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view).with.offset(topOffset)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
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
            make.bottom.equalTo(self.titleLabel).with.offset(14)
        }

        titleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.titleContainer).with.offset(25)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
        }
        
        textContainer.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.titleContainer.snp_bottom)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.bottom.equalTo(self.containerView)
        }
        
        textView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.textContainer).with.offset(14)
            make.left.equalTo(self.textContainer).with.offset(24)
            make.right.equalTo(self.textContainer).with.offset(-24)
            make.height.greaterThanOrEqualTo(88)
        }

        
    }
    
    func animate() {
        
        let translateAnimation = POPBasicAnimation(propertyNamed: kPOPLayerTranslationXY)
        translateAnimation.fromValue = NSValue(CGPoint: CGPoint(x: X_TRANSFORM, y: Y_TRANSFORM))
        translateAnimation.toValue = NSValue(CGPoint: CGPoint(x: 0, y: 0))
        translateAnimation.duration = 0.3
        
        containerView.layer.pop_addAnimation(translateAnimation, forKey: "translateAnimation")
    }
    
}
