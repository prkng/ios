//
//  LoginEmailViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 7/5/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class LoginEmailViewController: AbstractViewController {
    
    var signupButton : UIButton
    
    var formContainer : UIView
    var emailLabel : UILabel
    var emailTextField : UITextField
    var passwordLabel : UILabel
    var passwordTextField : UITextField
    
    var forgotPasswordButton : UIButton
    
    var loginButton : UIButton
    
    var delegate : LoginEmailViewControllerDelegate?
    
    init() {
        
        signupButton = ViewFactory.transparentRoundedButton()
        
        formContainer = UIView()
        emailLabel = ViewFactory.formLabel()
        emailTextField = ViewFactory.formTextField()
        passwordLabel = ViewFactory.formLabel()
        passwordTextField = ViewFactory.formTextField()
        
        forgotPasswordButton = UIButton()
        loginButton = ViewFactory.hugeButton()
        
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
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    func setupViews () {
        
        view.backgroundColor = Styles.Colors.midnight2
        
        signupButton.setTitle("sign_up".localizedString, forState: UIControlState.Normal)
        signupButton.addTarget(self, action:"signUpButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(signupButton)
        
        view.addSubview(formContainer)
        
        emailLabel.text = "your_email".localizedString
        formContainer.addSubview(emailLabel)
        
        formContainer.addSubview(emailTextField)
        
        passwordLabel.text = "your_password".localizedString
        formContainer.addSubview(passwordLabel)
        
        passwordTextField.secureTextEntry = true
        formContainer.addSubview(passwordTextField)
        
        
        forgotPasswordButton.setTitleColor(Styles.Colors.stone, forState: UIControlState.Normal)
        forgotPasswordButton.setTitleColor(Styles.Colors.anthracite1, forState: UIControlState.Highlighted)
        forgotPasswordButton.titleLabel?.font = Styles.FontFaces.light(12)
        forgotPasswordButton.setTitle("forgot_password_text".localizedString, forState: UIControlState.Normal)
        view.addSubview(forgotPasswordButton)
        
        loginButton.setTitle("login".localizedString, forState: UIControlState.Normal)
        view.addSubview(loginButton)
        
    }
    
    func setupConstraints () {
        
        signupButton.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view).with.offset(30)
            make.centerX.equalTo(self.view)
            make.size.equalTo(CGSizeMake(70, 26))
        }
        
        formContainer.snp_makeConstraints { (make) -> () in
            make.centerY.equalTo(self.view).with.offset(-50)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(180)
        }
        
        emailLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.formContainer).with.offset(10)
            make.right.equalTo(self.formContainer).with.offset(-10)
            make.top.equalTo(self.formContainer)
            make.centerX.equalTo(self.formContainer)
            make.height.equalTo(17)
        }
        
        emailTextField.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.formContainer).with.offset(10)
            make.right.equalTo(self.formContainer).with.offset(-10)
            make.top.equalTo(self.emailLabel.snp_bottom)
            make.centerX.equalTo(self.formContainer)
            make.height.equalTo(71)
        }
        
        
        passwordLabel.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.passwordTextField.snp_top)
            make.centerX.equalTo(self.formContainer)
            make.height.equalTo(17)
        }
        
        passwordTextField.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.formContainer).with.offset(10)
            make.right.equalTo(self.formContainer).with.offset(-10)
            make.bottom.equalTo(self.formContainer)
            make.centerX.equalTo(self.formContainer)
            make.height.equalTo(71)
            
        }
        
        forgotPasswordButton.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.loginButton.snp_top).with.offset(-5)
            make.centerX.equalTo(self.view)
            make.size.equalTo(CGSizeMake(200, 37))
        }
        
        loginButton.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(100)
        }
        
        
    }
    
    func signUpButtonTapped() {
        self.delegate!.signUp()
    }
    
}



protocol LoginEmailViewControllerDelegate {
    
    func signUp()
    func login(email : String, password : String) -> String?
    
}
