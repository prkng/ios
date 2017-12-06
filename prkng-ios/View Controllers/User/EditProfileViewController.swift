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
    let profileContainer = UIView()
    let avatarImageView = UIImageView()
    let avatarButton = UIButton()
    let nameTextField = ViewFactory.formTextField()
    let editProfileLabel = ViewFactory.formLabel()
    var inputForm : PRKInputForm
    let saveButton = ViewFactory.hugeButton()
    let backButton = ViewFactory.hugeButton()
    
    let loginMessageLabel = UILabel()
    
    let imagePicker = UIImagePickerController()
    
    var selectedImage : UIImage?
    
    //2 bottom buttons, tabbar
    fileprivate var BOTTOM_VIEW_HEIGHT = 2*Styles.Sizes.hugeButtonHeight //+ Styles.Sizes.tabbarHeight - Styles.Sizes.statusBarHeight

    fileprivate var nameText: String {
        return inputForm.textForFieldNamed("name".localizedString)
    }
    fileprivate var emailText: String {
        return inputForm.textForFieldNamed("email".localizedString)
    }
    fileprivate var passwordText: String {
        return inputForm.textForFieldNamed("password".localizedString)
    }
    fileprivate var passwordConfirmText: String {
        return inputForm.textForFieldNamed("password_confirm".localizedString)
    }

    init() {

        if let user = AuthUtility.getUser() {
            inputForm = PRKInputForm.inputFormForEditProfile(user.fullName, emailText: user.email)
        } else {
            inputForm = PRKInputForm()
        }
        
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
        updateValues()
        self.screenName = "User - Edit Profile View"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (AuthUtility.loginType()! == LoginType.Email) {
            loginMessageLabel.isHidden = true
            nameTextField.isHidden = true
        } else {
            
            avatarButton.isHidden = true
            editProfileLabel.isHidden = true
            nameTextField.isEnabled = false
            inputForm.isHidden = true
        }
    }
    
    func setupViews() {
        
        view.addSubview(backgroundImageView)
        
        view.addSubview(profileContainer)
        
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = Styles.Sizes.avatarSize.height / 2.0
        profileContainer.addSubview(avatarImageView)
        
        avatarButton.setImage(UIImage(named:"btn_upload_profile_on_top"), for: UIControlState())
        avatarButton.addTarget(self, action: #selector(EditProfileViewController.avatarButtonTapped(_:)), for: .touchUpInside)
        profileContainer.addSubview(avatarButton)
        
        editProfileLabel.text = "edit_profile".localizedString.uppercased()
        profileContainer.addSubview(editProfileLabel)
        profileContainer.addSubview(nameTextField)

        profileContainer.addSubview(inputForm)
        
        if (AuthUtility.loginType() == .Facebook){
            loginMessageLabel.text = "login_edit_message_facebook".localizedString
        } else if (AuthUtility.loginType() == .Google){
            loginMessageLabel.text = "login_edit_message_google".localizedString
        }
        loginMessageLabel.font = Styles.FontFaces.light(17)
        loginMessageLabel.textColor = Styles.Colors.anthracite1
        loginMessageLabel.textAlignment = .center
        profileContainer.addSubview(loginMessageLabel)
        
        saveButton.setTitle("save".localizedString, for: UIControlState())
        saveButton.addTarget(self, action: #selector(EditProfileViewController.saveButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(saveButton)
        
        backButton.setTitle("back".localizedString, for: UIControlState())
        backButton.backgroundColor = Styles.Colors.stone
        backButton.setTitleColor(Styles.Colors.anthracite1, for: UIControlState())
        backButton.addTarget(self, action: #selector(EditProfileViewController.backButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(backButton)
    }
    
    
    func setupConstraints() {
        
        backgroundImageView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }

        let PROFILE_VIEW_HEIGHT = Int(Styles.Sizes.avatarSize.height) + Styles.Sizes.formLabelHeight + 20 + self.inputForm.height() + 20

        profileContainer.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.centerY.equalTo(self.view).offset(-self.BOTTOM_VIEW_HEIGHT/2)
            make.height.equalTo(PROFILE_VIEW_HEIGHT)
        }
        
        avatarImageView.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.profileContainer)
            make.size.equalTo(Styles.Sizes.avatarSize)
            make.top.equalTo(self.profileContainer)
        }
        
        avatarButton.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.avatarImageView)
        }

        nameTextField.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.profileContainer).offset(20)
            make.right.equalTo(self.profileContainer).offset(-20)
            make.top.equalTo(self.editProfileLabel.snp_bottom).offset(10)
            make.height.equalTo(35)
        }
        
        loginMessageLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.profileContainer)
            make.right.equalTo(self.profileContainer)
            make.top.equalTo(self.nameTextField.snp_bottom).offset(2)
        }

        editProfileLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.profileContainer).offset(20)
            make.right.equalTo(self.profileContainer).offset(-20)
            make.top.equalTo(self.avatarImageView.snp_bottom).offset(20)
            make.height.equalTo(Styles.Sizes.formLabelHeight)
        }

        inputForm.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.profileContainer)
            make.right.equalTo(self.profileContainer)
            make.top.equalTo(self.editProfileLabel.snp_bottom).offset(20)
            make.height.greaterThanOrEqualTo(self.inputForm.height())
        }
        
        saveButton.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.backButton.snp_top)
            make.height.equalTo(Styles.Sizes.hugeButtonHeight)
        }
        
        backButton.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.height.equalTo(Styles.Sizes.hugeButtonHeight)
        }

    }
    
    func updateValues() {
        
        if let user = AuthUtility.getUser() {
            
            if let imageUrl = user.imageUrl {
                self.avatarImageView.sd_setImage(with: URL(string: imageUrl))
            }
            
            self.nameTextField.text = user.fullName
            
        }
        
    }
    
    func avatarButtonTapped(_ sender : UIButton) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum){
            print("Button capture")
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: { () -> Void in
            })
        }
        
    }
    
    func saveButtonTapped(_ sender : UIButton) {
        
        if (AuthUtility.loginType()! != LoginType.Email) {
            navigationController?.popViewController(animated: true)
            return
        }
        
        if !User.validateInput(nameText, emailText: emailText, passwordText: passwordText, passwordConfirmText: passwordConfirmText) {
            return
        }
        
        SVProgressHUD.show()
        
        let user = AuthUtility.getUser()!
        
        user.fullName = nameText
        user.email = emailText
        
        let newPassword : String = passwordText
        
        if let image = selectedImage {
            
            UserOperations.uploadAvatar(image, completion: { (completed, imageUrl) -> Void in
                self.updateUserAndGoBack(user, password: newPassword, imageUrl: imageUrl)
            })
            
            
        } else {
            
            updateUserAndGoBack(user, password: newPassword, imageUrl: nil)
            
        }
        
    }
    
    func backButtonTapped(_ sender : UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    
    func updateUserAndGoBack(_ user : User, password: String?, imageUrl : String?) {
        
        UserOperations.updateUser(user, newPassword: password, imageUrl: imageUrl, completion: { (completed, user, message) -> Void in
            if (completed) {
                AuthUtility.saveUser(user)
                SVProgressHUD.setBackgroundColor(Styles.Colors.stone)
                SVProgressHUD.showSuccess(withStatus: "profile_updated_message".localizedString)
                self.navigationController?.popViewController(animated: true)
            }
            else {
                SVProgressHUD.dismiss()
//                GiFHUD.dismiss()
                GeneralHelper.warnUser("profile_updated_error_message".localizedString)
            }
        })
    }
    
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
        
        self.dismiss(animated: true, completion: { () -> Void in
        })
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: false)
        selectedImage = image
        self.avatarImageView.image = image
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: { () -> Void in
        })
        UIApplication.shared.setStatusBarStyle(UIStatusBarStyle.lightContent, animated: false)
    }
    
    
    
}
