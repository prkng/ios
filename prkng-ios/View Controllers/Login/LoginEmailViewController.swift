//
//  LoginEmailViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 7/5/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class LoginEmailViewController: AbstractViewController, UIAlertViewDelegate {

    private var scrollView : UIScrollView
    private var scrollContentView : UIView
    private var backButton = ViewFactory.outlineBackButton()
    private var topLabel : UILabel
    private var inputForm : PRKInputForm
    private var forgotPasswordButton: UIButton
    private var signupButton : UIButton
    private var loginButton : UIButton
    
    var delegate : LoginEmailViewControllerDelegate?
    
    private var USABLE_VIEW_HEIGHT = UIScreen.mainScreen().bounds.size.height
    private var MAIN_BUTTON_OFFSET = UIScreen.mainScreen().bounds.width == 320 ? 70 : 100

    init() {
        
        let list = [
            ("email".localizedString, PRKTextFieldType.Email),
            ("password".localizedString, PRKTextFieldType.Password)
        ]
        
        topLabel = UILabel()
        scrollView = UIScrollView()
        scrollContentView  = UIView()
        inputForm = PRKInputForm(list: list)
        forgotPasswordButton = UIButton()
        signupButton = UIButton()
        loginButton = ViewFactory.bigRedRoundedButton()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func loadView() {
        self.view = UIView()
        setupViews()
        setupConstraints()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenName = "Login - Enter Email Credentials"
    }
        
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        inputForm.makeActive()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func setupViews () {
        
        view.backgroundColor = Styles.Colors.midnight1
        
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        
        backButton.addTarget(self, action: "back", forControlEvents: .TouchUpInside)
        scrollContentView.addSubview(backButton)

        topLabel.text = "login".localizedString.uppercaseString
        topLabel.font = Styles.FontFaces.regular(12)
        topLabel.textColor = Styles.Colors.stone
        scrollContentView.addSubview(topLabel)

        scrollContentView.addSubview(inputForm)

        forgotPasswordButton.titleLabel?.font = Styles.FontFaces.light(12)
        forgotPasswordButton.titleLabel?.textColor = Styles.Colors.anthracite1
        forgotPasswordButton.setTitle("forgot_password_text".localizedString.uppercaseString, forState: .Normal)
        forgotPasswordButton.addTarget(self, action:"didTapForgotPasswordButton", forControlEvents: UIControlEvents.TouchUpInside)
        scrollContentView.addSubview(forgotPasswordButton)
        
        loginButton.setTitle("login".localizedString.uppercaseString, forState: UIControlState.Normal)
        loginButton.addTarget(self, action: "loginButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        scrollContentView.addSubview(loginButton)

        signupButton.titleLabel?.font = Styles.FontFaces.light(12)
        signupButton.titleLabel?.textColor = Styles.Colors.anthracite1
        signupButton.setTitle("register_with_email_switch".localizedString.uppercaseString, forState: .Normal)
        signupButton.addTarget(self, action:"signUpButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        scrollContentView.addSubview(signupButton)
    }
    
    func setupConstraints () {
        
        scrollView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        
        scrollContentView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.scrollView)
            make.size.greaterThanOrEqualTo(CGSizeMake(UIScreen.mainScreen().bounds.size.width, self.USABLE_VIEW_HEIGHT))
        }
        
        backButton.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.scrollContentView).with.offset(24)
            make.centerY.equalTo(self.topLabel)
        }

        topLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.scrollContentView).with.offset(50)
            make.centerX.equalTo(self.scrollContentView)
        }

        inputForm.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.scrollContentView)
            make.right.equalTo(self.scrollContentView)
            make.top.equalTo(self.scrollContentView).with.offset(97)
            make.height.greaterThanOrEqualTo(self.inputForm.height())
        }
        
        forgotPasswordButton.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.inputForm.snp_bottom).with.offset(14)
            make.centerX.equalTo(self.scrollContentView)
        }
        
        loginButton.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.inputForm.snp_bottom).with.offset(self.MAIN_BUTTON_OFFSET)
            make.left.equalTo(self.view).with.offset(Styles.Sizes.bigRoundedButtonSideMargin)
            make.right.equalTo(self.view).with.offset(-Styles.Sizes.bigRoundedButtonSideMargin)
            make.height.equalTo(Styles.Sizes.bigRoundedButtonHeight)
        }
        
        signupButton.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.loginButton.snp_bottom).with.offset(16)
            make.centerX.equalTo(self.scrollContentView)
        }

    }
    
    func signUpButtonTapped() {
        self.delegate!.signUp()
    }
    
    func loginButtonTapped(sender : UIButton) {
        
        UserOperations.login(inputForm.textForFieldNamed("email".localizedString), password: inputForm.textForFieldNamed("password".localizedString)) { (user, apiKey) -> Void in
            
            if (user != nil) {
                AuthUtility.saveUser(user!)
                AuthUtility.saveAuthToken(apiKey!)
                
                if self.delegate != nil {
                    self.delegate!.didLogin()
                }
                
            } else {
                let alert = UIAlertView()
                alert.message = "login_error".localizedString
                alert.addButtonWithTitle("OK")
                alert.show()
            }
        }
        
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
        
        if (buttonIndex == 0) {
            
            if let email = alertView.textFieldAtIndex(0)?.text {
                
                if Int(count(email)) > 4 {
                    
                    SVProgressHUD.show()
                    
                    UserOperations.resetPassword(email, completion: { (completed) -> Void in
                        
                        SVProgressHUD.dismiss()
                        
                        let alert = UIAlertView()
                        alert.message = completed ? "check_email_copy".localizedString : "pasword_reset_error".localizedString
                        alert.addButtonWithTitle("ok".localizedString.uppercaseString)
                        alert.show()
                        
                    })
                    
                } else {
                    
                    let alert = UIAlertView()
                    alert.message = "invalid_email".localizedString
                    alert.addButtonWithTitle("ok".localizedString.uppercaseString)
                    alert.show()
                    
                }
                
            } else {
                let alert = UIAlertView()
                alert.message = "invalid_email".localizedString
                alert.addButtonWithTitle("ok".localizedString.uppercaseString)
                alert.show()
            }
            
        }
    }
    
    func back() {
        self.delegate?.backFromEmail()
    }
    
    
    func didTapForgotPasswordButton() {
        let alert = UIAlertView()
        alert.title = "reset_email_copy".localizedString
        alert.addButtonWithTitle("reset_password".localizedString)
        alert.alertViewStyle = UIAlertViewStyle.PlainTextInput
        alert.addButtonWithTitle("cancel".localizedString)
        alert.delegate = self
        alert.show()
    }

}


protocol LoginEmailViewControllerDelegate {
    func signUp()
    func didLogin()
    func backFromEmail()
}
