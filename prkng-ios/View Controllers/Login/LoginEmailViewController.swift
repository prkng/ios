//
//  LoginEmailViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 7/5/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class LoginEmailViewController: AbstractViewController, UIAlertViewDelegate {

    fileprivate var scrollView : UIScrollView
    fileprivate var scrollContentView : UIView
    fileprivate var backButton = ViewFactory.outlineBackButton(Styles.Colors.cream2)
    fileprivate var topLabel : UILabel
    fileprivate var inputForm : PRKInputForm
    fileprivate var forgotPasswordButton: UIButton
    fileprivate var signupButton : UIButton
    fileprivate var loginButton : UIButton
    
    var delegate : LoginEmailViewControllerDelegate?
    
    fileprivate var USABLE_VIEW_HEIGHT = UIScreen.main.bounds.size.height
    fileprivate var MAIN_BUTTON_OFFSET = UIScreen.main.bounds.width == 320 ? 70 : 100

    init() {
        
        let list = [
            ("email".localizedString, PRKTextFieldType.email),
            ("password".localizedString, PRKTextFieldType.password)
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
    
    required init?(coder aDecoder: NSCoder) {
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
        
    override func viewDidAppear(_ animated: Bool) {
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
        
        backButton.addTarget(self, action: "back", for: .touchUpInside)
        scrollContentView.addSubview(backButton)

        topLabel.text = "login".localizedString.uppercased()
        topLabel.font = Styles.FontFaces.regular(12)
        topLabel.textColor = Styles.Colors.stone
        scrollContentView.addSubview(topLabel)

        scrollContentView.addSubview(inputForm)

        forgotPasswordButton.titleLabel?.font = Styles.FontFaces.light(12)
        forgotPasswordButton.titleLabel?.textColor = Styles.Colors.anthracite1
        forgotPasswordButton.setTitle("forgot_password_text".localizedString.uppercased(), for: UIControlState())
        forgotPasswordButton.addTarget(self, action:#selector(LoginEmailViewController.didTapForgotPasswordButton), for: UIControlEvents.touchUpInside)
        scrollContentView.addSubview(forgotPasswordButton)
        
        loginButton.setTitle("login".localizedString.uppercased(), for: UIControlState())
        loginButton.addTarget(self, action: #selector(LoginEmailViewController.loginButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        scrollContentView.addSubview(loginButton)

        signupButton.titleLabel?.font = Styles.FontFaces.light(12)
        signupButton.titleLabel?.textColor = Styles.Colors.anthracite1
        signupButton.setTitle("register_with_email_switch".localizedString.uppercased(), for: UIControlState())
        signupButton.addTarget(self, action:#selector(LoginEmailViewController.signUpButtonTapped), for: UIControlEvents.touchUpInside)
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
            make.size.greaterThanOrEqualTo(CGSize(width: UIScreen.main.bounds.size.width, height: self.USABLE_VIEW_HEIGHT))
            make.width.equalTo(self.view)
        }
        
        backButton.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.scrollContentView.snp_left).offset(29)
            make.centerY.equalTo(self.topLabel)
            make.size.equalTo(CGSize(width: 50, height: 50))
        }

        topLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.scrollContentView).offset(50)
            make.centerX.equalTo(self.scrollContentView)
        }

        inputForm.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.scrollContentView)
            make.right.equalTo(self.scrollContentView)
            make.top.equalTo(self.scrollContentView).offset(97)
            make.height.greaterThanOrEqualTo(self.inputForm.height())
        }
        
        forgotPasswordButton.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.inputForm.snp_bottom).offset(14)
            make.centerX.equalTo(self.scrollContentView)
        }
        
        loginButton.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.inputForm.snp_bottom).offset(self.MAIN_BUTTON_OFFSET)
            make.left.equalTo(self.view).offset(Styles.Sizes.bigRoundedButtonSideMargin)
            make.right.equalTo(self.view).offset(-Styles.Sizes.bigRoundedButtonSideMargin)
            make.height.equalTo(Styles.Sizes.bigRoundedButtonHeight)
        }
        
        signupButton.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.loginButton.snp_bottom).offset(16)
            make.centerX.equalTo(self.scrollContentView)
        }

    }
    
    func signUpButtonTapped() {
        self.delegate!.signUp()
    }
    
    func loginButtonTapped(_ sender : UIButton) {
        
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
                alert.addButton(withTitle: "OK")
                alert.show()
            }
        }
        
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        
        if (buttonIndex == 0) {
            
            if let email = alertView.textField(at: 0)?.text {
                
                if Int(email.characters.count) > 4 {
                    
                    SVProgressHUD.show()
                    
                    UserOperations.resetPassword(email, completion: { (completed) -> Void in
                        
                        SVProgressHUD.dismiss()
                        
                        let alert = UIAlertView()
                        alert.message = completed ? "check_email_copy".localizedString : "pasword_reset_error".localizedString
                        alert.addButton(withTitle: "ok".localizedString.uppercased())
                        alert.show()
                        
                    })
                    
                } else {
                    
                    let alert = UIAlertView()
                    alert.message = "invalid_email".localizedString
                    alert.addButton(withTitle: "ok".localizedString.uppercased())
                    alert.show()
                    
                }
                
            } else {
                let alert = UIAlertView()
                alert.message = "invalid_email".localizedString
                alert.addButton(withTitle: "ok".localizedString.uppercased())
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
        alert.addButton(withTitle: "reset_password".localizedString)
        alert.alertViewStyle = UIAlertViewStyle.plainTextInput
        alert.addButton(withTitle: "cancel".localizedString)
        alert.delegate = self
        alert.show()
    }

}


protocol LoginEmailViewControllerDelegate {
    func signUp()
    func didLogin()
    func backFromEmail()
}
