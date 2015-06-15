//
//  EditProfileViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 10/06/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class EditProfileViewController: AbstractViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate  {
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
    
    let imagePicker = UIImagePickerController()
    
    var selectedImage : UIImage?
    
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
        updateValues()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setupViews() {
        
        view.addSubview(backgroundImageView)
        
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = Styles.Sizes.avatarSize.height / 2.0
        view.addSubview(avatarImageView)
        
        avatarButton.setImage(UIImage(named:"btn_upload_profile_on_top"), forState: .Normal)
        avatarButton.addTarget(self, action: "avatarButtonTapped:", forControlEvents: .TouchUpInside)
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
        logoutButton.addTarget(self, action: "logoutButtonTapped:", forControlEvents: .TouchUpInside)
        view.addSubview(logoutButton)
        
        saveButton.setTitle("save".localizedString, forState: .Normal)
        saveButton.addTarget(self, action: "saveButtonTapped:", forControlEvents: .TouchUpInside)
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
    
    func avatarButtonTapped(sender : UIButton) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            println("Button capture")
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: { () -> Void in
            })
        }
        
    }
    
    func logoutButtonTapped(sender : UIButton) {
        //        let alert = UIAlertView()
        //        alert.title = "Alert"
        //        alert.message = "Here's a message"
        //        alert.addButtonWithTitle("cancel".localizedString)
        //        alert.addButtonWithTitle("logout".localizedString)
        //        alert.cancelButtonIndex = 0
        //        alert.show()
        
        SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Clear)
        
        AuthUtility.saveAuthToken(nil)
        AuthUtility.saveUser(nil)
        
        UIApplication.sharedApplication().keyWindow!.rootViewController = FirstUseViewController()
    }
    
    func saveButtonTapped(sender : UIButton) {
        
        if nameTextField.text == nil {
            warnUser("name_empty".localizedString)
            return
        }
        
        if emailTextField.text == nil {
            warnUser("email_empty".localizedString)
            return
        }
        
        
        if passwordTextField1.text != passwordTextField2.text {
            warnUser("password_mismatch".localizedString)
            return
        }
        
        
        if count(passwordTextField1.text) < 6 && count(passwordTextField1.text) > 0 {
            warnUser("password_short".localizedString)
            return
        }
        
        SVProgressHUD.showWithMaskType(.Clear)
        
        let user = AuthUtility.getUser()!
        
        user.name = nameTextField.text
        user.email = emailTextField.text
        
        var newPassword : String = passwordTextField1.text
        
        if let image = selectedImage {

            UserOperations.uploadAvatar(image, completion: { (completed, imageUrl) -> Void in
                self.updateUserAndGoBack(user, password: newPassword, imageUrl: imageUrl)
            })
            
            
        } else {
            
            updateUserAndGoBack(user, password: newPassword, imageUrl: nil)
            
        }
        
    }


    func updateUserAndGoBack(user : User, password: String?, imageUrl : String?) {
        
        UserOperations.updateUser(user, newPassword: password, imageUrl: imageUrl, completion: { (completed, user, message) -> Void in
            AuthUtility.saveUser(user)
            SVProgressHUD.showSuccessWithStatus("profile_updated_message".localizedString)
            self.navigationController?.popViewControllerAnimated(true)
        })
    }
    
    func warnUser (message: String) {
        let alert = UIAlertView()
        alert.message = message
        alert.addButtonWithTitle("OK".localizedString)
        alert.show()
    }
    
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
        selectedImage = image
        self.avatarImageView.image = image
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
        UIApplication.sharedApplication().setStatusBarStyle(UIStatusBarStyle.LightContent, animated: false)
    }
    
    
    
}
