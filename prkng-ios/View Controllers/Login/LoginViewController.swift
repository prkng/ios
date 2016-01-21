//
//  LoginViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 06/05/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class LoginViewController: AbstractViewController, LoginMethodSelectionViewDelegate, LoginEmailViewControllerDelegate, LoginExternalViewControllerDelegate, RegisterEmailViewControllerDelegate, GIDSignInDelegate, GIDSignInUIDelegate {
    
    var backgroundImageView : UIImageView
    var logoView : UIImageView
    var methodSelectionView : LoginMethodSelectionView
    
    var loginEmailViewController : LoginEmailViewController?
    var registerEmailViewController : RegisterEmailViewController?
//    var loginExternalViewController : LoginExternalViewController?
    
    var selectedMethod : LoginMethod?
    
    init() {
        backgroundImageView = UIImageView()
        logoView = UIImageView()
        methodSelectionView = LoginMethodSelectionView()
        
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
        self.screenName = "Login - First Screen"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    
    func setupViews () {
        
        view.backgroundColor = Styles.Colors.petrol1
        
        backgroundImageView.image = UIImage(named: "bg_login")
        backgroundImageView.contentMode = UIViewContentMode.ScaleAspectFill
        view.addSubview(backgroundImageView)
        
        logoView.image = UIImage(named: "logo_opening")
        logoView.contentMode = UIViewContentMode.Bottom
        view.addSubview(logoView)
        
        methodSelectionView.delegate = self
        view.addSubview(methodSelectionView)
    }
    
    func setupConstraints () {
        
        backgroundImageView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }
        
        logoView.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.view).multipliedBy(0.5)
        }
        
        methodSelectionView.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.height.equalTo(LoginMethodSelectionView.HEIGHT)
        }
        
    }
    
    // MARK: LoginMethodSelectionViewDelegate
    
    func loginFacebookSelected() {
        if (selectedMethod == LoginMethod.Facebook) {
            return
        }
        
        self.methodSelectionView.userInteractionEnabled = false
        
        let login = FBSDKLoginManager()
        login.logOut()
        
        let permissions = ["email", "public_profile"]
        login.logInWithReadPermissions(permissions) { (result, error) -> Void in
            
            if (error != nil || result.isCancelled) {
                // Handle errors and cancellations
                
                self.deselectMethod()
                
                let alertView = UIAlertView(title: "login_error_title_facebook".localizedString , message: "login_error_message".localizedString, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK")
                alertView.alertViewStyle = .Default
                alertView.show()
                
            } else {
                
                self.methodSelectionView.userInteractionEnabled = false
                
                UserOperations.loginWithFacebook(FBSDKAccessToken.currentAccessToken().tokenString, completion: { (user, apiKey) -> Void in
                    AuthUtility.saveUser(user)
                    AuthUtility.saveAuthToken(apiKey)
//                    self.displayExternalInfo(user, loginType: .Facebook)
                    self.didLoginExternal(.Facebook)
                })
            }
            
        }
        
        selectedMethod = LoginMethod.Facebook
        
    }
    
    func loginGoogleSelected() {
        
        if (selectedMethod == LoginMethod.Google) {
            return
        }
        
        GIDSignIn.sharedInstance().signOut()
        
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
        
        
        selectedMethod = LoginMethod.Google
        
    }
    
    func loginEmailSelected() {
        
        if (selectedMethod == LoginMethod.Email) {
            return
        }
        
        signUp()
        
        selectedMethod = LoginMethod.Email
    }
    
    //used to show a view controller, now we just log in right away
//    func displayExternalInfo(user: User, loginType : LoginType) {
//        
//        loginExternalViewController = LoginExternalViewController(usr : user, loginType : loginType)
//        loginExternalViewController!.delegate = self
//        self.addChildViewController(loginExternalViewController!)
//        self.view.insertSubview(loginExternalViewController!.view, belowSubview: methodSelectionView)
//        loginExternalViewController!.didMoveToParentViewController(self)
//        
//        
//        loginExternalViewController!.view.snp_makeConstraints { (make) -> () in
//            make.top.equalTo(self.methodSelectionView.snp_bottom)
//            make.centerX.equalTo(self.view)
//            make.size.equalTo(self.view)
//        }
//        self.loginExternalViewController!.view.layoutIfNeeded()
//        
//        
//        methodSelectionView.snp_remakeConstraints { (make) -> () in
//            make.left.equalTo(self.view)
//            make.right.equalTo(self.view)
//            make.top.equalTo(self.view)
//            make.height.equalTo(0)
//        }
//        
//        
//        UIView.animateWithDuration(0.15, animations: { () -> Void in
//            self.view.layoutIfNeeded()
//            }) { (finished) -> Void in
//                
//        }
//        
//    }
    
    // MARK: GIDSignInDelegate
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError!) {
        
        if error != nil {
            //error!
            deselectMethod()
            
            let alertView = UIAlertView(title: "login_error_title_google".localizedString , message: "login_error_message".localizedString, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK")
            alertView.alertViewStyle = .Default
            alertView.show()
            
        } else {
            //success!
            // Perform any operations on signed in user here.
//            let userId = user.userID                  // For client-side use only!
            let idToken = user.authentication.idToken // Safe to send to the server
            let name = user.profile.name
            let email = user.profile.email
            let profileImageUrl = user.profile.imageURLWithDimension(600).absoluteString

            self.methodSelectionView.userInteractionEnabled = false
            
            UserOperations.loginWithGoogle(idToken, name: name, email: email, profileImageUrl: profileImageUrl, completion: { (user, apiKey) -> Void in
                AuthUtility.saveUser(user)
                AuthUtility.saveAuthToken(apiKey)
//                self.displayExternalInfo(user, loginType : .Google)
                self.didLoginExternal(.Google)
            })
        }
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user: GIDGoogleUser!, withError error: NSError!) {
    }
    
    // MARK: GIDSignInUIDelegate
    
    
    
    // MARK: LoginEmailViewControllerDelegate
    
    func signUp() {
        
        loginEmailViewController?.dismissViewControllerFromLeft({ () -> Void in
            self.loginEmailViewController = nil
        })

        //if registerEmailViewController already exists, then it was behind loginEmailViewController and we *don't* need to present it
        if registerEmailViewController == nil {
            registerEmailViewController = RegisterEmailViewController()
            registerEmailViewController!.delegate = self
            self.presentViewControllerFromRight(registerEmailViewController!, completion: nil)
        }
        
    }
    
    func didLogin() {
        AuthUtility.saveLoginType(.Email)
        askForPermissions()
    }
    
    // MARK: LoginExternalViewControllerDelegate
    func didLoginExternal(loginType : LoginType) {
        AuthUtility.saveLoginType(loginType)
        askForPermissions()
    }
    
    // MARK: RegisterEmailViewControllerDelegate
    func didRegister() {
        AuthUtility.saveLoginType(.Email)
        askForPermissions()
    }
    
    func askForPermissions() {
        //shows the permissions view controller
        let permissionsVC = LoginPermissionsViewController(work: { () -> Void in
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.loggedInOperations()
            }) { () -> Void in
                self.dismiss()
        }

        let hasLocationPermission = CLLocationManager.authorizationStatus() != .NotDetermined
        if !hasLocationPermission {
            self.presentViewController(permissionsVC, animated: true, completion: nil)
        } else {
            self.dismiss()
        }

    }
    
    func showLogin() {

        //do not dismiss register, show email on top of it instead
        loginEmailViewController = LoginEmailViewController()
        loginEmailViewController!.delegate = self
        (registerEmailViewController ?? self).presentViewControllerFromRight(loginEmailViewController!, completion: nil)
    }

    
    // MARK: All login delegates
    func backFromRegister() {
        
        methodSelectionView.snp_remakeConstraints { (make) -> () in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.height.equalTo(LoginMethodSelectionView.HEIGHT)
        }
        
        registerEmailViewController?.dismissViewControllerFromLeft({ () -> Void in
            self.registerEmailViewController = nil
        })
        
        deselectMethod()
        
    }
    
    func backFromEmail() {
        
        methodSelectionView.snp_remakeConstraints { (make) -> () in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.height.equalTo(LoginMethodSelectionView.HEIGHT)
        }
        

        loginEmailViewController?.dismissViewControllerFromLeft({ () -> Void in
            self.loginEmailViewController = nil
        })

    }
    
    func dismiss() {
        
        Settings.setFirstUsePassed(true)
        
        self.dismissViewControllerWithFade { () -> Void in
            
            let window: UIWindow = (UIApplication.sharedApplication().delegate as! AppDelegate).window!
            let tabController = TabController()
            
            window.rootViewController = tabController
            window.makeKeyWindow()
            
        }
    }
    
    func deselectMethod() {
        selectedMethod = nil
        self.methodSelectionView.userInteractionEnabled = true
        self.methodSelectionView.deselectAll()

    }
}
