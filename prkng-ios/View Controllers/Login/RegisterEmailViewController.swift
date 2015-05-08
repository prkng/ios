//
//  RegisterEmailViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 7/5/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class RegisterEmailViewController: AbstractViewController {

    var titleLabel : UILabel
    var stepLabel : UILabel
    
    var stepOneContainer : UIView
    var emailLabel : UILabel
    var emailTextField : UITextField
    var passwordLabel : UILabel
    var passwordTextField : UITextField
    var confirmPasswordLabel : UILabel
    var confirmPasswordTextField : UITextField
    var continueButton : UIButton
    
    
    var stepTwoContainer : UIView
    var avatarButton : UIButton
    var nameLabel : UILabel
    var nameTextField : UITextField
    var genderLabel : UILabel
    var genderSelection : SelectionControl
    var birthYearLabel : UILabel
    var birthYearTextField : UITextField
    var backButton: UIButton
    
    
    var delegate : RegisterEmailViewController?
    
    init() {
        
        titleLabel = UILabel()
        stepLabel = UILabel()
        
        stepOneContainer = UIView()
        emailLabel = ViewFactory.formLabel()
        emailTextField = ViewFactory.formTextField()
        passwordLabel = ViewFactory.formLabel()
        passwordTextField = ViewFactory.formTextField()
        confirmPasswordLabel = ViewFactory.formLabel()
        confirmPasswordTextField = ViewFactory.formTextField()
        
        stepTwoContainer = UIView()
        avatarButton = UIButton()
        nameLabel = ViewFactory.formLabel()
        nameTextField = ViewFactory.formTextField()
        genderLabel = ViewFactory.formLabel()
        genderSelection = SelectionControl(titles: ["male".localizedString.uppercaseString, "female".localizedString.uppercaseString])
        birthYearLabel = ViewFactory.formLabel()
        birthYearTextField = ViewFactory.formTextField()
        backButton = ViewFactory.transparentRoundedButton()
        
        continueButton = UIButton()
        
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
        
        titleLabel.text = "sign_up".localizedString.uppercaseString
        view.addSubview(titleLabel)
        
        stepLabel.text = ("step".localizedString + " 1/2").uppercaseString
        view.addSubview(stepLabel)
        
        // Step One
        
        view.addSubview(stepOneContainer)
        
        emailLabel.text = "your_email".localizedString.uppercaseString
        stepOneContainer.addSubview(emailLabel)
        
        stepOneContainer.addSubview(emailTextField)
        
        passwordLabel.text = "your_password".localizedString
        stepOneContainer.addSubview(passwordLabel)
        
        passwordTextField.secureTextEntry = true
        stepOneContainer.addSubview(passwordTextField)
        
        confirmPasswordLabel.text = "confirm_your_password".localizedString
        stepOneContainer.addSubview(confirmPasswordLabel)
        
        confirmPasswordTextField.secureTextEntry = true
        stepOneContainer.addSubview(confirmPasswordTextField)
        
        continueButton.setImage(UIImage(named: "btn_next"), forState: UIControlState.Normal)
        continueButton.addTarget(self, action: "continueButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        stepOneContainer.addSubview(continueButton)
        
        
        
        // Step Two
        
        view.addSubview(stepTwoContainer)
        
        stepTwoContainer.addSubview(avatarButton)
        
        stepTwoContainer.addSubview(nameLabel)
        
        stepTwoContainer.addSubview(nameTextField)
        
        stepTwoContainer.addSubview(genderLabel)
        
        stepTwoContainer.addSubview(genderSelection)
        
        stepTwoContainer.addSubview(birthYearLabel)
        
        stepTwoContainer.addSubview(birthYearTextField)
        
    }
    
    func setupConstraints () {
        
        titleLabel.snp_makeConstraints { (make) -> () in
            make.centerY.equalTo(self.view)
            make.top.equalTo(self.view).with.offset(40)
        }
        
        stepLabel.snp_makeConstraints { (make) -> () in
            make.centerY.equalTo(self.view)
            make.top.equalTo(self.titleLabel.snp_bottom).with.offset(5)
        }
        
  
        stepOneContainer.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.stepLabel.snp_bottom).with.offset(10)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(270)
        }
        
        emailLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.stepOneContainer).with.offset(10)
            make.right.equalTo(self.stepOneContainer).with.offset(-10)
            make.top.equalTo(self.stepOneContainer)
            make.centerX.equalTo(self.stepOneContainer)
            make.height.equalTo(17)
        }
        
        emailTextField.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.stepOneContainer).with.offset(10)
            make.right.equalTo(self.stepOneContainer).with.offset(-10)
            make.top.equalTo(self.emailLabel.snp_bottom)
            make.centerX.equalTo(self.stepOneContainer)
            make.height.equalTo(71)
        }
        
        
        passwordLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.emailTextField.snp_bottom).with.offset(18)
            make.centerX.equalTo(self.stepOneContainer)
            make.height.equalTo(17)
        }
        
        passwordTextField.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.passwordLabel)
            make.left.equalTo(self.stepOneContainer).with.offset(10)
            make.right.equalTo(self.stepOneContainer).with.offset(-10)
            make.centerX.equalTo(self.stepOneContainer)
            make.height.equalTo(71)
        }
        
        confirmPasswordLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.passwordTextField.snp_bottom).with.offset(18)
            make.centerX.equalTo(self.stepOneContainer)
            make.height.equalTo(17)
        }
        
        confirmPasswordTextField.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.confirmPasswordLabel)
            make.left.equalTo(self.stepOneContainer).with.offset(10)
            make.right.equalTo(self.stepOneContainer).with.offset(-10)
            make.centerX.equalTo(self.stepOneContainer)
            make.height.equalTo(71)
        }
        
        
        
        continueButton.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.view).with.offset(-20)
            make.centerX.equalTo(self.view)
            make.size.equalTo(CGSizeMake(60, 60))
        }
        
        
    }
    
}

