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
    var topLabel : UILabel
    var inputForm : PRKInputForm
    var registerButton : UIButton
    
    var delegate : RegisterEmailViewControllerDelegate?
    
    private var USABLE_VIEW_HEIGHT = UIScreen.mainScreen().bounds.size.height - CGFloat(Styles.Sizes.hugeButtonHeight)

    private var nameText: String {
        return inputForm.textForFieldNamed("name".localizedString)
    }
    private var emailText: String {
        return inputForm.textForFieldNamed("email".localizedString)
    }
    private var passwordText: String {
        return inputForm.textForFieldNamed("password".localizedString)
    }
    private var passwordConfirmText: String {
        return inputForm.textForFieldNamed("password_confirm".localizedString)
    }
    
    init() {
        
        let list = [
            ("name".localizedString, PRKTextFieldType.NormalNoAutocorrect),
            ("email".localizedString, PRKTextFieldType.Email),
            ("password".localizedString, PRKTextFieldType.Password),
            ("password_confirm".localizedString, PRKTextFieldType.Password),
        ]

        scrollView = UIScrollView()
        scrollContentView = UIView()
        topLabel = UILabel()
        inputForm = PRKInputForm(list: list)
        registerButton = ViewFactory.hugeButton()
        
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
        self.screenName = "Login - Register Email"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    func setupViews () {
        
        view.backgroundColor = Styles.Colors.midnight1
        
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        
        topLabel.textColor = Styles.Colors.cream2
        topLabel.font = Styles.FontFaces.light(12)
        topLabel.text = "sign_up".localizedString.uppercaseString
        scrollContentView.addSubview(topLabel)
        
        scrollContentView.addSubview(inputForm)

        registerButton.setTitle("register".localizedString, forState: UIControlState.Normal)
        registerButton.addTarget(self, action: "registerButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(registerButton)
    }
    
    func setupConstraints () {
        
        scrollView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.registerButton.snp_top)
        }
        
        scrollContentView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.scrollView)
            make.size.greaterThanOrEqualTo(CGSizeMake(UIScreen.mainScreen().bounds.size.width, self.USABLE_VIEW_HEIGHT))
        }

        topLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.scrollContentView).with.offset(20)
            make.centerX.equalTo(self.scrollContentView)
        }
        
        inputForm.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.scrollContentView)
            make.right.equalTo(self.scrollContentView)
            make.centerY.equalTo(self.scrollContentView)
            make.height.greaterThanOrEqualTo(self.inputForm.height())
        }
        
        registerButton.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(Styles.Sizes.hugeButtonHeight)
        }
        
    }

    func registerButtonTapped () {
        
        if !User.validateInput(nameText, emailText: emailText, passwordText: passwordText, passwordConfirmText: passwordConfirmText) {
            return
        }
        
        UserOperations.register(emailText, name: nameText, password: passwordText, gender: "", birthYear: "") { (user, apiKey, error) -> Void in
            
            if user == nil || apiKey == nil {
                
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
    
}

protocol RegisterEmailViewControllerDelegate {
    func didRegister()
}

