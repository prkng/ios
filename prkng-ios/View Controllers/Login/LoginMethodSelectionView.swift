//
//  LoginMethodSelectionView.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 7/5/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class LoginMethodSelectionView: UIView {
    
    static let HEIGHT = 187
    
    var containerView = UIView()
    var loginTitleLabel = UILabel()
    var facebookButton = ViewFactory.bigRedRoundedButton()
    var googleButton = ViewFactory.bigRedRoundedButton()
    var emailButton = UIButton()
    
    var selectedMethod : LoginMethod?
    
    var delegate : LoginMethodSelectionViewDelegate?
    
    var didSetupSubviews = false
    var didSetupConstraints = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    
    override func layoutSubviews() {
        
        if(!didSetupSubviews) {
            setupSubviews()
            didSetupConstraints = false
            self.setNeedsUpdateConstraints()
        }
        
        super.layoutSubviews()
    }
    
    override func updateConstraints() {
        
        if(!self.didSetupConstraints) {
            setupConstraints()
        }
        super.updateConstraints()
    }
    
    func setupSubviews() {
        
        self.clipsToBounds = true
        addSubview(containerView)
        
        loginTitleLabel.font = Styles.FontFaces.bold(12)
        loginTitleLabel.textColor = Styles.Colors.cream1
        loginTitleLabel.text = "login_with".localizedString
        containerView.addSubview(loginTitleLabel)
        
        facebookButton.backgroundColor = Styles.Colors.facebookBlue
        facebookButton.setTitle("login_with_facebook".localizedString, forState: .Normal)
        facebookButton.addTarget(self, action: "facebookButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        containerView.addSubview(facebookButton)
        
        googleButton.setTitle("login_with_google".localizedString, forState: .Normal)
        googleButton.addTarget(self, action: "googleButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        containerView.addSubview(googleButton)
        
        emailButton.titleLabel?.font = Styles.FontFaces.regular(12)
        emailButton.titleLabel?.textColor = Styles.Colors.anthracite1
        emailButton.setTitle("login_with_email".localizedString, forState: .Normal)
        emailButton.addTarget(self, action: "emailButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        containerView.addSubview(emailButton)
        
        didSetupSubviews = true
    }
    
    func setupConstraints() {
        
        containerView.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.top.equalTo(self)
            make.height.equalTo(LoginMethodSelectionView.HEIGHT)
        }
        
        loginTitleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.containerView)
            make.centerX.equalTo(self.containerView)
        }
        
        facebookButton.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.containerView).with.offset(50)
            make.right.equalTo(self.containerView).with.offset(-50)
            make.top.equalTo(self.loginTitleLabel.snp_bottom).with.offset(14)
            make.height.equalTo(Styles.Sizes.bigRoundedButtonHeight)
        }
        
        googleButton.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.containerView).with.offset(50)
            make.right.equalTo(self.containerView).with.offset(-50)
            make.bottom.equalTo(self.containerView).with.offset(-70)
            make.height.equalTo(Styles.Sizes.bigRoundedButtonHeight)
        }
        
        emailButton.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.containerView)
            make.bottom.equalTo(self.containerView)
            make.height.equalTo(70)
        }
        
        didSetupConstraints = true
    }
    
    
    
    func facebookButtonTapped () {
        
        if(selectedMethod == LoginMethod.Facebook) {
            return
        }
        
        deselectAll()
        selectedMethod = LoginMethod.Facebook
        
        if (delegate != nil) {
            delegate!.loginFacebookSelected()
        }
        
    }
    
    
    func googleButtonTapped () {
        
        if(selectedMethod == LoginMethod.Google) {
            return
        }
        
        deselectAll()
        selectedMethod = LoginMethod.Google
        
        if (delegate != nil) {
            delegate!.loginGoogleSelected()
        }
        
    }
    
    func emailButtonTapped () {
        
        if(selectedMethod == LoginMethod.Email) {
            return
        }
        
        deselectAll()
        selectedMethod = LoginMethod.Email
        
        if (delegate != nil) {
            delegate!.loginEmailSelected()
        }
        
    }
        
    func deselectAll () {
        
        selectedMethod = nil
        
    }
    
}

protocol LoginMethodSelectionViewDelegate {
    
    func loginFacebookSelected()
    func loginGoogleSelected()
    func loginEmailSelected()
    
}


enum LoginMethod {
    case Facebook
    case Google
    case Email
}