//
//  EditProfileViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 10/06/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class EditProfileViewController: AbstractViewController {
    let backgroundImageView = UIImageView(image: UIImage(named:"bg_blue_gradient"))
    let avatarImageView = UIImageView()
    let avatarButton = UIButton()
    let editProfileLabel = ViewFactory.formLabel()
    let nameTextField = ViewFactory.formTextField()
    let emailTextField = UITextField()
    let passwordLabel1 = ViewFactory.formLabel()
    let passwordTextField1 = ViewFactory.formTextField()
    let passwordLabel2 = ViewFactory.formLabel()
    let passwordTextField2 = ViewFactory.formTextField()
    let logoutButton = ViewFactory.transparentRoundedButton()
    let saveButton = ViewFactory.hugeButton()
    
    init() {
        
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
        updateValues()
    }
    
    func setupViews() {
        
        view.addSubview(backgroundImageView)
        
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = Styles.Sizes.avatarSize.height / 2.0
        view.addSubview(avatarImageView)
        
        avatarButton.setImage(UIImage(named:"btn_upload_profile_on_top"), forState: .Normal)
        view.addSubview(avatarButton)
        
        editProfileLabel.text = "edit_profile".localizedString.uppercaseString
        view.addSubview(editProfileLabel)
        
        view.addSubview(nameTextField)
        
        emailTextField.font = Styles.FontFaces.light(17)
        emailTextField.backgroundColor = UIColor.clearColor()
        emailTextField.textColor = Styles.Colors.anthracite1
        emailTextField.textAlignment = NSTextAlignment.Center
        emailTextField.autocorrectionType = UITextAutocorrectionType.No
        view.addSubview(emailTextField)
        
        passwordLabel1.text = "new_password".localizedString.uppercaseString
        view.addSubview(passwordLabel1)
        
        passwordTextField1.secureTextEntry = true
        view.addSubview(passwordTextField1)
        
        passwordLabel2.text = "new_password_confirm".localizedString.uppercaseString
        view.addSubview(passwordLabel2)
        
        passwordTextField2.secureTextEntry = true
        view.addSubview(passwordTextField2)
        
        logoutButton.setTitle("logout".localizedString.uppercaseString, forState: .Normal)
        view.addSubview(logoutButton)
        
        saveButton.setTitle("save".localizedString, forState: .Normal)
        view.addSubview(saveButton)
    }
    
    
    func setupConstraints() {
        
        backgroundImageView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }
        
        saveButton.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.height.equalTo(Styles.Sizes.bigButtonHeight)
        }
        
        logoutButton.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.view)
            make.size.equalTo(CGSizeMake(120, 26))
            make.bottom.equalTo(self.saveButton.snp_top).with.offset(-20)
        }
        
        passwordTextField2.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.view).with.offset(20)
            make.right.equalTo(self.view).with.offset(-20)
            make.bottom.lessThanOrEqualTo(self.logoutButton).with.offset(-46)
            make.height.equalTo(Styles.Sizes.formTextFieldHeight)
            make.bottom.greaterThanOrEqualTo(self.logoutButton).with.offset(-10).priorityHigh()
        }
        
        passwordLabel2.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.view).with.offset(20)
            make.right.equalTo(self.view).with.offset(-20)
            make.top.equalTo(self.passwordTextField2)
            make.height.equalTo(Styles.Sizes.formLabelHeight)
        }
        
        passwordTextField1.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.view).with.offset(20)
            make.right.equalTo(self.view).with.offset(-20)
            make.bottom.equalTo(self.passwordLabel2.snp_top).with.offset(-2)
            make.height.equalTo(Styles.Sizes.formTextFieldHeight)
        }

        passwordLabel1.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.view).with.offset(20)
            make.right.equalTo(self.view).with.offset(-20)
            make.top.equalTo(self.passwordTextField1)
            make.height.equalTo(Styles.Sizes.formLabelHeight)
        }

        emailTextField.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.view).with.offset(20)
            make.right.equalTo(self.view).with.offset(-20)
            make.bottom.greaterThanOrEqualTo(self.passwordTextField1.snp_top).with.offset(-20).priorityHigh()
            make.bottom.lessThanOrEqualTo(self.view.snp_centerY).multipliedBy(0.7).priorityLow()
        }
        
        nameTextField.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.view).with.offset(20)
            make.right.equalTo(self.view).with.offset(-20)
            make.height.equalTo(35)
            make.bottom.equalTo(self.emailTextField.snp_top).with.offset(-2)
        }
        
        editProfileLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.view).with.offset(20)
            make.right.equalTo(self.view).with.offset(-20)
            make.bottom.equalTo(self.nameTextField.snp_top).with.offset(-2)
            make.height.equalTo(Styles.Sizes.formLabelHeight)
        }
        
        avatarImageView.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.view)
            make.size.equalTo(Styles.Sizes.avatarSize)
            make.bottom.equalTo(self.editProfileLabel.snp_top).with.offset(-20)
            make.top.greaterThanOrEqualTo(self.view).with.offset(30)
        }
        
        avatarButton.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.avatarImageView)
        }
        
    }
    
    func updateValues() {
        
        if let user = AuthUtility.getUser() {
            
            if let imageUrl = user.imageUrl {
                self.avatarImageView.sd_setImageWithURL(NSURL(string: imageUrl))
            }
            
            self.nameTextField.text = user.name
            
            self.emailTextField.text = user.email
            
        }
        
    }
}
