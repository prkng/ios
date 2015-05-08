//
//  LoginViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 06/05/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class LoginViewController: AbstractViewController, LoginMethodSelectionViewDelegate, LoginEmailViewControllerDelegate {
    
    var backgroundImageView : UIImageView
    var logoView : UIImageView
    var methodSelectionView : LoginMethodSelectionView
    
    var loginEmailViewController : LoginEmailViewController?
    var registerEmailViewController : RegisterEmailViewController?
    
    var selectedMethod : LoginMethod?
    
    init() {
        backgroundImageView = UIImageView()
        logoView = UIImageView()
        methodSelectionView = LoginMethodSelectionView()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func loadView() {
        self.view = TouchForwardingView()
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
        
        view.backgroundColor = Styles.Colors.petrol1
        
        backgroundImageView.image = UIImage(named: "bg_login")
        backgroundImageView.contentMode = UIViewContentMode.ScaleAspectFill
        view.addSubview(backgroundImageView)
        
        logoView.image = UIImage(named: "logo_opening")
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
            make.height.equalTo(100)
        }
        
    }
    
    // MARK: LoginMethodSelectionViewDelegate
    
    func loginFacebookSelected() {
        if (selectedMethod == LoginMethod.Facebook) {
            return
        }
        
    }
    
    func loginGoogleSelected() {
        
        if (selectedMethod == LoginMethod.Google) {
            return
        }
        
        
        
    }
    
    func loginEmailSelected() {
        
        if (selectedMethod == LoginMethod.Email) {
            return
        }
        
        loginEmailViewController = LoginEmailViewController()
        loginEmailViewController!.delegate = self
        self.addChildViewController(loginEmailViewController!)
        self.view.insertSubview(loginEmailViewController!.view, belowSubview: methodSelectionView)
        loginEmailViewController!.didMoveToParentViewController(self)
        
        
        loginEmailViewController!.view.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.methodSelectionView.snp_bottom)
            make.centerX.equalTo(self.view)
            make.size.equalTo(self.view).with.offset(CGSizeMake(0, -125))
        }
        self.loginEmailViewController!.view.layoutIfNeeded()
        
        
        methodSelectionView.snp_remakeConstraints { (make) -> () in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(self.view)
            make.height.equalTo(125)
        }
        
        
        UIView.animateWithDuration(0.15, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }) { (finished) -> Void in
                
        }
        
        
        selectedMethod = LoginMethod.Email
    }
    
    
    // MARK: LoginEmailViewControllerDelegate
    
    
    func signUp() {
        
        registerEmailViewController = RegisterEmailViewController()
        //        registerEmailViewController.delegate = self
        self.addChildViewController(registerEmailViewController!)
        self.view.insertSubview(registerEmailViewController!.view, belowSubview: loginEmailViewController!.view)
        registerEmailViewController!.didMoveToParentViewController(self)
        
        
        registerEmailViewController!.view.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.loginEmailViewController!.view.snp_bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(self.view).with.offset(-225)
        }
        
        registerEmailViewController!.view.layoutIfNeeded()
        
        
        loginEmailViewController!.view.snp_remakeConstraints { (make) -> () in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(self.view).with.offset(-225)
            make.bottom.equalTo(self.methodSelectionView)
        }
        
        UIView.animateWithDuration(0.15, animations: { () -> Void in
            self.view.layoutIfNeeded()
            
            }) { (completed) -> Void in
                
                self.registerEmailViewController!.view.snp_makeConstraints { (make) -> () in
                    make.top.equalTo(self.methodSelectionView.snp_bottom)
                    make.left.equalTo(self.view)
                    make.right.equalTo(self.view)
                    make.height.equalTo(self.view).with.offset(-225)
                }
                
                self.loginEmailViewController!.view.removeFromSuperview()
                self.loginEmailViewController!.removeFromParentViewController()
                self.loginEmailViewController!.didMoveToParentViewController(nil)
                self.loginEmailViewController = nil
        }
        
        
    }
    
    func login(email: String, password: String) -> String? {
        return ""
    }
    
    
    
}
