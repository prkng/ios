//
//  RegisterEmailViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 7/5/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class RegisterEmailViewController: AbstractViewController {
    
    var stepOneScrollView : UIScrollView
    var stepOneScrollContentView : UIView
    var stepOneTitleLabel : UILabel
    var stepOneStepLabel : UILabel
    var emailLabel : UILabel
    var emailTextField : UITextField
    var passwordLabel : UILabel
    var passwordTextField : UITextField
    var confirmPasswordLabel : UILabel
    var confirmPasswordTextField : UITextField
    var continueButton : UIButton
    
    var stepTwoScrollView : UIScrollView
    var stepTwoScrollContentView : UIView
    var stepTwoTitleLabel : UILabel
    var stepTwoStepLabel : UILabel
    var avatarButton : UIButton
    var nameLabel : UILabel
    var nameTextField : UITextField
    var genderLabel : UILabel
    var genderSelection : SelectionControl
    var birthYearLabel : UILabel
    var birthYearTextField : UITextField
    var backButton: UIButton
    var registerButton : UIButton
    
    var delegate : RegisterEmailViewControllerDelegate?
    
    init() {
        
        stepOneScrollView = UIScrollView()
        stepOneTitleLabel = UILabel()
        stepOneStepLabel = UILabel()
        stepOneScrollContentView = UIView()
        emailLabel = ViewFactory.formLabel()
        emailTextField = ViewFactory.formTextField()
        passwordLabel = ViewFactory.formLabel()
        passwordTextField = ViewFactory.formTextField()
        confirmPasswordLabel = ViewFactory.formLabel()
        confirmPasswordTextField = ViewFactory.formTextField()
        
        stepTwoScrollView = UIScrollView()
        stepTwoScrollContentView = UIView()
        stepTwoTitleLabel = UILabel()
        stepTwoStepLabel = UILabel()
        avatarButton = UIButton()
        nameLabel = ViewFactory.formLabel()
        nameTextField = ViewFactory.formTextField()
        genderLabel = ViewFactory.formLabel()
        genderSelection = SelectionControl(titles: ["male".localizedString.uppercaseString, "female".localizedString.uppercaseString])
        birthYearLabel = ViewFactory.formLabel()
        birthYearTextField = ViewFactory.formTextField()
        backButton = ViewFactory.transparentRoundedButton()
        continueButton = UIButton()
        
        registerButton = ViewFactory.bigButton()
        
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
        
        // Step One
        
        view.addSubview(stepOneScrollView)
        stepOneScrollView.addSubview(stepOneScrollContentView)
        
        stepOneTitleLabel.textColor = Styles.Colors.cream2
        stepOneTitleLabel.font = Styles.FontFaces.light(12)
        stepOneTitleLabel.text = "sign_up".localizedString.uppercaseString
        stepOneScrollView.addSubview(stepOneTitleLabel)
        
        stepOneStepLabel.font = Styles.FontFaces.regular(12)
        stepOneStepLabel.textColor = Styles.Colors.red2
        stepOneStepLabel.text = ("step".localizedString + " 1/2").uppercaseString
        stepOneScrollView.addSubview(stepOneStepLabel)
        
        emailLabel.text = "your_email".localizedString.uppercaseString
        stepOneScrollContentView.addSubview(emailLabel)
        
        stepOneScrollContentView.addSubview(emailTextField)
        
        passwordLabel.text = "your_password".localizedString
        stepOneScrollContentView.addSubview(passwordLabel)
        
        passwordTextField.secureTextEntry = true
        stepOneScrollContentView.addSubview(passwordTextField)
        
        confirmPasswordLabel.text = "confirm_your_password".localizedString
        stepOneScrollContentView.addSubview(confirmPasswordLabel)
        
        confirmPasswordTextField.secureTextEntry = true
        stepOneScrollContentView.addSubview(confirmPasswordTextField)
        
        continueButton.setImage(UIImage(named: "btn_next"), forState: UIControlState.Normal)
        continueButton.addTarget(self, action: "continueButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        stepOneScrollContentView.addSubview(continueButton)
        
        // Step Two
        
        
        view.addSubview(stepTwoScrollView)
        stepTwoScrollView.addSubview(stepTwoScrollContentView)
        
        stepTwoTitleLabel.textColor = Styles.Colors.cream2
        stepTwoTitleLabel.font = Styles.FontFaces.light(12)
        stepTwoTitleLabel.text = "sign_up".localizedString.uppercaseString
        stepTwoScrollContentView.addSubview(stepTwoTitleLabel)
        
        stepTwoStepLabel.font = Styles.FontFaces.regular(12)
        stepTwoStepLabel.textColor = Styles.Colors.red2
        stepTwoStepLabel.text = ("step".localizedString + " 2/2").uppercaseString
        stepTwoScrollContentView.addSubview(stepTwoStepLabel)
        
        avatarButton.setImage(UIImage(named: "btn_upload_profile"), forState: UIControlState.Normal)
        stepTwoScrollContentView.addSubview(avatarButton)
        
        nameLabel.text = "your_name".localizedString.uppercaseString
        stepTwoScrollContentView.addSubview(nameLabel)
        
        stepTwoScrollContentView.addSubview(nameTextField)
        
        genderLabel.text = "your_gender".localizedString.uppercaseString
        stepTwoScrollContentView.addSubview(genderLabel)
        
        genderSelection.buttonSize = CGSizeMake(70, 26)
        stepTwoScrollContentView.addSubview(genderSelection)
        
        birthYearLabel.text = "your_birth_year".localizedString.uppercaseString
        stepTwoScrollContentView.addSubview(birthYearLabel)
        
        birthYearTextField.keyboardType = UIKeyboardType.NumberPad
        stepTwoScrollContentView.addSubview(birthYearTextField)
        
        
        backButton.setTitle("< " + "step".localizedString.uppercaseString + " 1", forState: UIControlState.Normal)
        backButton.addTarget(self, action: "backButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        stepTwoScrollContentView.addSubview(backButton)
        
        registerButton.setTitle("register".localizedString, forState: UIControlState.Normal)
        registerButton.addTarget(self, action: "registerButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        stepTwoScrollContentView.addSubview(registerButton)
    }
    
    func setupConstraints () {
        
        // step one
        
        stepOneScrollView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view)
            make.centerX.equalTo(self.view)
            make.size.equalTo(self.view)
        }
        
        stepOneScrollContentView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.stepOneScrollView)
            make.size.equalTo(CGSizeMake(UIScreen.mainScreen().bounds.width, 540))
        }
        
        stepOneTitleLabel.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.stepOneScrollContentView)
            make.top.equalTo(self.stepOneScrollContentView).with.offset(40)
        }
        
        stepOneStepLabel.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.stepOneScrollContentView)
            make.top.equalTo(self.stepOneTitleLabel.snp_bottom).with.offset(5)
        }
        
        emailLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.stepOneScrollContentView).with.offset(10)
            make.right.equalTo(self.stepOneScrollContentView).with.offset(-10)
            make.top.greaterThanOrEqualTo(self.stepOneStepLabel.snp_bottom).with.offset(60)
            make.centerX.equalTo(self.stepOneScrollContentView)
            make.height.equalTo(17)
        }
        
        emailTextField.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.stepOneScrollContentView).with.offset(10)
            make.right.equalTo(self.stepOneScrollContentView).with.offset(-10)
            make.top.equalTo(self.emailLabel)
            make.centerX.equalTo(self.stepOneScrollContentView)
            make.height.equalTo(71)
        }
        
        
        passwordLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.emailTextField.snp_bottom).with.offset(18)
            make.centerX.equalTo(self.stepOneScrollContentView)
            make.height.equalTo(17)
        }
        
        passwordTextField.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.passwordLabel)
            make.left.equalTo(self.stepOneScrollContentView).with.offset(10)
            make.right.equalTo(self.stepOneScrollContentView).with.offset(-10)
            make.height.equalTo(71)
        }
        
        confirmPasswordLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.passwordTextField.snp_bottom).with.offset(18)
            make.centerX.equalTo(self.stepOneScrollContentView)
            make.height.equalTo(17)
        }
        
        confirmPasswordTextField.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.confirmPasswordLabel)
            make.left.equalTo(self.stepOneScrollContentView).with.offset(10)
            make.right.equalTo(self.stepOneScrollContentView).with.offset(-10)
            make.height.equalTo(71)
        }
        
        continueButton.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.stepOneScrollContentView).with.offset(-20)
            make.centerX.equalTo(self.stepOneScrollContentView)
            make.size.equalTo(CGSizeMake(60, 60))
        }
        
        
        // step two
        
        stepTwoScrollView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.stepOneScrollView.snp_bottom)
            make.centerX.equalTo(self.view)
            make.size.equalTo(self.view)
        }
        
        stepTwoScrollContentView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.stepTwoScrollView)
            make.size.equalTo(CGSizeMake(UIScreen.mainScreen().bounds.width, 540))
        }
        
        stepTwoTitleLabel.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.stepTwoScrollContentView)
            make.top.equalTo(self.stepTwoScrollContentView).with.offset(40)
        }
        
        stepTwoStepLabel.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.stepOneScrollContentView)
            make.top.equalTo(self.stepTwoTitleLabel.snp_bottom).with.offset(5)
        }
        
        avatarButton.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.stepTwoStepLabel.snp_bottom).with.offset(19)
            make.centerX.equalTo(self.stepTwoScrollContentView)
            make.size.equalTo(CGSizeMake(55, 55))
        }
        
        nameLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.avatarButton.snp_bottom).with.offset(16)
            make.centerX.equalTo(self.stepTwoScrollContentView)
            make.height.equalTo(17)
        }
        
        nameTextField.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.nameLabel)
            make.left.equalTo(self.stepOneScrollContentView).with.offset(10)
            make.right.equalTo(self.stepOneScrollContentView).with.offset(-10)
            make.height.equalTo(71)
        }
        
        genderLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.nameTextField.snp_bottom).with.offset(18)
            make.centerX.equalTo(self.stepTwoScrollContentView)
            make.height.equalTo(17)
        }
        
        genderSelection.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.genderLabel.snp_bottom).with.offset(7)
            make.left.equalTo(self.stepOneScrollContentView)
            make.right.equalTo(self.stepOneScrollContentView)
            make.height.equalTo(26)
            make.centerX.equalTo(self.stepTwoScrollContentView)
        }
        
        birthYearLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.genderSelection.snp_bottom).with.offset(16)
            make.centerX.equalTo(self.stepTwoScrollContentView)
            make.height.equalTo(17)
        }
        
        birthYearTextField.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.birthYearLabel)
            make.left.equalTo(self.stepOneScrollContentView).with.offset(10)
            make.right.equalTo(self.stepOneScrollContentView).with.offset(-10)
            make.height.equalTo(71)
        }
        
        backButton.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.birthYearTextField.snp_bottom).with.offset(20)
            make.size.equalTo(CGSizeMake(70, 26))
            make.centerX.equalTo(self.stepTwoScrollContentView)
        }
        
        registerButton.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.stepTwoScrollContentView)
            make.right.equalTo(self.stepTwoScrollContentView)
            make.bottom.equalTo(self.stepTwoScrollContentView)
            make.height.equalTo(Styles.Sizes.hugeButtonHeight)
        }
        
    }
    
    
    func continueButtonTapped () {
        
        
        if (count(emailTextField.text) < 2) {
            let alert = UIAlertView()
            alert.title = ""
            alert.message = "invalid_email".localizedString
            alert.addButtonWithTitle("Okay")
            alert.show()
            
            return
        }
        
        if (count (passwordTextField.text) < 6 || count(confirmPasswordTextField.text) < 6) {
            
            let alert = UIAlertView()
            alert.title = ""
            alert.message = "password_short".localizedString
            alert.addButtonWithTitle("Okay")
            alert.show()
            
            return
        }
 
        
        if (passwordTextField.text != confirmPasswordTextField.text) {
            
            let alert = UIAlertView()
            alert.title = ""
            alert.message = "password_mismatch".localizedString
            alert.addButtonWithTitle("Okay")
            alert.show()
            
            return            
        }
        
        
        
        self.stepOneScrollView.snp_remakeConstraints { (make) -> () in
            make.bottom.equalTo(self.view.snp_top)
            make.centerX.equalTo(self.view)
            make.size.equalTo(self.view)
        }
        
        self.stepOneScrollView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: false)
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            
            self.view.layoutIfNeeded()
            
            }) { (finished) -> Void in
                
                
        }
    }
    
    func backButtonTapped () {
        
        self.stepOneScrollView.snp_remakeConstraints { (make) -> () in
            make.bottom.equalTo(self.view)
            make.centerX.equalTo(self.view)
            make.size.equalTo(self.view)
        }
        
        self.stepOneScrollView.scrollRectToVisible(CGRectMake(0, 0, 1, 1), animated: false)
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            
            self.view.layoutIfNeeded()
            
            }) { (finished) -> Void in
                
        }
        
    }
    
    
    func registerButtonTapped () {
        
        if (count(emailTextField.text) < 2) {
            let alert = UIAlertView()
            alert.title = ""
            alert.message = "invalid_name".localizedString
            alert.addButtonWithTitle("Okay")
            alert.show()
            
            return
        }
        
        
        var gender : String = "male"
        
        if (genderSelection.selectedIndex == 1) {
            gender = "female"
        }
        
        
        UserOperations.register(emailTextField.text, name: nameTextField.text, password: passwordTextField.text, gender: gender, birthYear: birthYearTextField.text) { (user, apiKey) -> Void in
            
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

