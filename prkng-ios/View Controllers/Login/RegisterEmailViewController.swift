//
//  RegisterEmailViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 7/5/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class RegisterEmailViewController: AbstractViewController {
    
    var scrollView : UIScrollView
    var scrollContentView : UIView
    var backButton = ViewFactory.outlineBackButton(Styles.Colors.cream2)
    var topLabel : UILabel
    var inputForm : PRKInputForm
    var registerButton = ViewFactory.bigRedRoundedButton()
    var loginButton = UIButton()
    
    var delegate : RegisterEmailViewControllerDelegate?
    
    private var USABLE_VIEW_HEIGHT = UIScreen.mainScreen().bounds.size.height

    private var nameText: String {
        return inputForm.textForFieldNamed("name".localizedString)
    }
    private var emailText: String {
        return inputForm.textForFieldNamed("email".localizedString)
    }
    private var passwordText: String {
        return inputForm.textForFieldNamed("password".localizedString)
    }
    
    init() {
        
        let list = [
            ("name".localizedString, PRKTextFieldType.NormalNoAutocorrect),
            ("email".localizedString, PRKTextFieldType.Email),
            ("password".localizedString, PRKTextFieldType.Password),
        ]

        scrollView = UIScrollView()
        scrollContentView = UIView()
        topLabel = UILabel()
        inputForm = PRKInputForm(list: list)
        
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
        self.screenName = "Login - Register Email"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        inputForm.makeActive()
    }
    
    func setupViews() {
        
        view.backgroundColor = Styles.Colors.midnight1
        
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        
        backButton.addTarget(self, action: "back", forControlEvents: .TouchUpInside)
        scrollContentView.addSubview(backButton)
        
        topLabel.textColor = Styles.Colors.cream2
        topLabel.font = Styles.FontFaces.regular(12)
        topLabel.text = "create_an_account".localizedString.uppercaseString
        scrollContentView.addSubview(topLabel)
        
        scrollContentView.addSubview(inputForm)
        
        registerButton.setTitle("register".localizedString.uppercaseString, forState: UIControlState.Normal)
        registerButton.addTarget(self, action: "registerButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        scrollContentView.addSubview(registerButton)
        
        loginButton.titleLabel?.font = Styles.FontFaces.light(12)
        loginButton.titleLabel?.textColor = Styles.Colors.anthracite1
        loginButton.setTitle("login_with_email_switch".localizedString.uppercaseString, forState: .Normal)
        loginButton.addTarget(self, action:"loginButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        scrollContentView.addSubview(loginButton)

    }
    
    func setupConstraints() {
        
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
        
        let registerButtonTopOffset = UIScreen.mainScreen().bounds.width == 320 ? 20 : 50

        registerButton.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.inputForm.snp_bottom).offset(registerButtonTopOffset)
            make.left.equalTo(self.view).offset(Styles.Sizes.bigRoundedButtonSideMargin)
            make.right.equalTo(self.view).offset(-Styles.Sizes.bigRoundedButtonSideMargin)
            make.height.equalTo(Styles.Sizes.bigRoundedButtonHeight)
        }
        
        loginButton.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.registerButton.snp_bottom).offset(16)
            make.centerX.equalTo(self.scrollContentView)
        }

        
    }

    func registerButtonTapped() {
        
        if !User.validateInput(nameText, emailText: emailText, passwordText: passwordText, passwordConfirmText: passwordText) {
            return
        }
        
        registerButton.enabled = false
        
        UserOperations.register(emailText, name: nameText, password: passwordText, gender: "", birthYear: "") { (user, apiKey, error) -> Void in
            
            if user == nil || apiKey == nil {
                
                self.registerButton.enabled = true

                var alertView: UIAlertView
                if error == nil {
                    alertView = UIAlertView(title: "register_error_title".localizedString , message: "register_error_message_user_exists".localizedString, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK")
                } else {
                    alertView = UIAlertView(title: "register_error_title".localizedString , message: "register_error_message_generic".localizedString, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK")
                }
                alertView.alertViewStyle = .Default
                alertView.show()
                
                return
            }
            
            AuthUtility.saveUser(user)
            AuthUtility.saveAuthToken(apiKey)
            
            if self.delegate != nil {
                self.delegate!.didRegister()
            }
            
        }
        
        
    }
    
    func loginButtonTapped() {
        self.delegate?.showLogin()
    }
    
    func back() {
        self.delegate?.backFromRegister()
    }
    
}

protocol RegisterEmailViewControllerDelegate {
    func didRegister()
    func showLogin()
    func backFromRegister()
}

