//
//  LoginMethodSelectionView.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 7/5/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class LoginMethodSelectionView: UIView {
    
    var loginTitleLabel : UILabel
    var facebookButton : UIButton
    var googleButton : UIButton
    var emailButton : UIButton
    
    var selectedMethod : LoginMethod?
    
    var delegate : LoginMethodSelectionViewDelegate?
    
    var didSetupSubviews: Bool
    var didSetupConstraints: Bool
    
    override init(frame: CGRect) {
        didSetupSubviews = false
        didSetupConstraints = false
        loginTitleLabel = UILabel()
        facebookButton = UIButton()
        googleButton = UIButton()
        emailButton = UIButton()
        
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
        
        self.backgroundColor = Styles.Colors.stone
        
        loginTitleLabel.font = Styles.FontFaces.light(12)
        loginTitleLabel.textColor = Styles.Colors.midnight2
        loginTitleLabel.text = NSLocalizedString("login_with", comment : "")
        addSubview(loginTitleLabel)
        
        facebookButton.setImage(UIImage(named: "btn_fb"), forState: UIControlState.Normal)
        facebookButton.setImage(UIImage(named: "btn_fb_active"), forState: UIControlState.Highlighted)
        facebookButton.addTarget(self, action: "facebookButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(facebookButton)
        
        googleButton.setImage(UIImage(named: "btn_google"), forState: UIControlState.Normal)
        googleButton.setImage(UIImage(named: "btn_google_active"), forState: UIControlState.Highlighted)
        googleButton.addTarget(self, action: "googleButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(googleButton)
        
        
        emailButton.setImage(UIImage(named: "btn_email"), forState: UIControlState.Normal)
        emailButton.setImage(UIImage(named: "btn_email_active"), forState: UIControlState.Highlighted)
        emailButton.addTarget(self, action: "emailButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        addSubview(emailButton)
        
        didSetupSubviews = true
    }
    
    func setupConstraints() {
        
        loginTitleLabel.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.facebookButton.snp_top)
            make.centerX.equalTo(self)
        }
        
        facebookButton.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(70, 70))
            make.centerX.equalTo(self).multipliedBy(0.5)
            make.bottom.equalTo(self)
        }
        
        googleButton.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(70, 70))
            make.centerX.equalTo(self).multipliedBy(1.0)
            make.bottom.equalTo(self)
        }
        
        emailButton.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(70, 70))
            make.centerX.equalTo(self).multipliedBy(1.5)
            make.bottom.equalTo(self)
        }
        
        didSetupConstraints = true
    }
    
    
    
    func facebookButtonTapped () {
        
        if(selectedMethod == LoginMethod.Facebook) {
            return
        }
        
        deselectAll()
        selectedMethod = LoginMethod.Facebook
        facebookButton.setImage(UIImage(named: "btn_fb_active"), forState: UIControlState.Normal)
        facebookButton.setImage(UIImage(named: "btn_fb"), forState: UIControlState.Highlighted)
        
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
        googleButton.setImage(UIImage(named: "btn_google_active"), forState: UIControlState.Normal)
        googleButton.setImage(UIImage(named: "btn_google"), forState: UIControlState.Highlighted)
        
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
        emailButton.setImage(UIImage(named: "btn_email_active"), forState: UIControlState.Normal)
        emailButton.setImage(UIImage(named: "btn_email"), forState: UIControlState.Highlighted)
        
        if (delegate != nil) {
            delegate!.loginEmailSelected()
        }
        
    }
        
    func deselectAll () {
        
        selectedMethod = nil
        
        facebookButton.setImage(UIImage(named: "btn_fb"), forState: UIControlState.Normal)
        facebookButton.setImage(UIImage(named: "btn_fb"), forState: UIControlState.Highlighted)
        
        googleButton.setImage(UIImage(named: "btn_google"), forState: UIControlState.Normal)
        googleButton.setImage(UIImage(named: "btn_google_active"), forState: UIControlState.Highlighted)
        
        emailButton.setImage(UIImage(named: "btn_email"), forState: UIControlState.Normal)
        emailButton.setImage(UIImage(named: "btn_email_active"), forState: UIControlState.Highlighted)
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