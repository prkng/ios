//
//  PPIntroViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2016-02-09.
//  Copyright © 2016 PRKNG. All rights reserved.
//

import UIKit

class PPIntroViewController: AbstractViewController, PPHeaderViewDelegate, PPSignInViewControllerDelegate, PPCreateUserViewControllerDelegate {
    
    private var statusView = UIView()
    private var headerView = PPHeaderView()
    private var titleLabel = UILabel()
    private var logoView = UIImageView()
    private var bodyLabel = UILabel()
    private var subBodyButton = UIButton()
    private var createAccountButton = ViewFactory.redRoundedButtonWithHeight(36, font: Styles.FontFaces.bold(12), text: "create_my_account".localizedString.uppercaseString)
    private var signInButton = UIButton()
    
    private(set) var BACKGROUND_COLOR = Styles.Colors.stone
    private(set) var BACKGROUND_TEXT_COLOR = Styles.Colors.anthracite1
    private(set) var BACKGROUND_TEXT_COLOR_EMPHASIZED = Styles.Colors.red2
    private(set) var FOREGROUND_COLOR = Styles.Colors.cream1
    private(set) var FOREGROUND_TEXT_COLOR = Styles.Colors.petrol2
    private(set) var FOREGROUND_TEXT_COLOR_EMPHASIZED = Styles.Colors.red2
    
    private(set) var HEADER_HEIGHT = 80
    private(set) var HEADER_FONT = Styles.FontFaces.regular(12)
    private(set) var MIN_FOOTER_HEIGHT = 65
    private(set) var FOOTER_FONT = Styles.FontFaces.regular(12)
    
    private(set) var SMALL_CELL_HEIGHT: CGFloat = 48
    private(set) var BIG_CELL_HEIGHT: CGFloat = 61

    init() {
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
        self.screenName = "Parking Panda - Intro View"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        SVProgressHUD.dismiss()
    }
    
    func setupViews () {
        
        view.backgroundColor = BACKGROUND_COLOR
        
        statusView.backgroundColor = Styles.Colors.transparentBlack
        self.view.addSubview(statusView)
        
        headerView.delegate = self
        headerView.showsRightButton = false
        headerView.backButtonTapRadius = 40
        headerView.enableRipple = false
        view.addSubview(headerView)

        //TODO: localize all these strings including create_my_account above
        titleLabel.text = "parking_panda_intro_text".localizedString
        titleLabel.font = Styles.FontFaces.bold(25)
        titleLabel.textColor = FOREGROUND_TEXT_COLOR_EMPHASIZED
        titleLabel.textAlignment = .Center
        view.addSubview(titleLabel)
        
        logoView.image = UIImage(named: "logo_opening")
        view.addSubview(logoView)
        
        bodyLabel.text = "parking_panda_intro_body_text".localizedString
        bodyLabel.font = Styles.FontFaces.regular(16)
        bodyLabel.textColor = FOREGROUND_TEXT_COLOR
        bodyLabel.textAlignment = .Center
        view.addSubview(bodyLabel)
        
        subBodyButton.setTitle("parking_panda_intro_body_sub_text".localizedString, forState: .Normal)
        subBodyButton.setTitleColor(BACKGROUND_TEXT_COLOR, forState: .Normal)
        subBodyButton.titleLabel?.font = Styles.FontFaces.regular(12)
        subBodyButton.addTarget(self, action: "subBodyButtonTapped", forControlEvents: .TouchUpInside)
        view.addSubview(subBodyButton)

        createAccountButton.setTitle("register".localizedString.uppercaseString, forState: .Normal)
        createAccountButton.addTarget(self, action: "createAccountButtonTapped", forControlEvents: .TouchUpInside)
        view.addSubview(createAccountButton)
        
        signInButton.setTitle("parking_panda_login_text".localizedString.uppercaseString, forState: .Normal)
        signInButton.setTitleColor(BACKGROUND_TEXT_COLOR, forState: .Normal)
        signInButton.titleLabel?.font = Styles.FontFaces.bold(12)
        signInButton.addTarget(self, action: "signInButtonTapped", forControlEvents: .TouchUpInside)
        view.addSubview(signInButton)

    }
    
    func setupConstraints () {
        
        statusView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.view)
            make.bottom.equalTo(self.snp_topLayoutGuideBottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        headerView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.snp_topLayoutGuideBottom)
            make.height.equalTo(HEADER_HEIGHT)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }

        titleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.headerView.snp_bottom)
            make.centerX.equalTo(self.view)
        }
        
        logoView.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.view).multipliedBy(0.5)
        }
        
        bodyLabel.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(logoView.snp_bottom).offset(20)
            make.left.equalTo(self.view).offset(50)
            make.right.equalTo(self.view).offset(-50)
            make.bottom.equalTo(subBodyButton.snp_top).offset(-20)
        }

        subBodyButton.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(bodyLabel.snp_bottom).offset(20)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(createAccountButton.snp_top).offset(-20)
        }

        createAccountButton.snp_makeConstraints { (make) -> () in
            make.height.equalTo(36)
            make.left.equalTo(self.view).offset(50)
            make.right.equalTo(self.view).offset(-50)
            make.bottom.equalTo(self.signInButton.snp_top).offset(-30)
        }
        
        signInButton.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.view).offset(70)
            make.right.equalTo(self.view).offset(-70)
            make.bottom.equalTo(self.view).offset(-50)
        }
        
    }
    
    func subBodyButtonTapped() {
        //TODO: this should do something
    }
    
    func createAccountButtonTapped() {
        let createUserVC = PPCreateUserViewController()
        createUserVC.delegate = self
        createUserVC.presentWithVC(self)
    }
    
    func signInButtonTapped() {
        let signInVC = PPSignInViewController()
        signInVC.delegate = self
        signInVC.presentWithVC(self)
    }
    
    func presentWithVC(vc: UIViewController?) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let rootVC = vc ?? appDelegate.window?.rootViewController {
            if let navVC = rootVC.navigationController {
                navVC.pushViewController(self, animated: true)
            } else {
                rootVC.presentViewControllerFromRight(0.3, viewController: self, completion: nil)
            }
        }
        
    }
    
    func dismiss() {
        
        if let navVC = self.navigationController {
            navVC.popViewControllerAnimated(true)
        } else {
            self.dismissViewControllerFromLeft(0.3, completion: nil)
        }
        
    }

    //MARK: PPHeaderViewDelegate functions
    func tappedBackButton() {
        self.dismiss()
    }
    
    func tappedNextButton() {
    }
    
    //MARK: PPSignInViewControllerDelegate functions
    func didSignIn() {
        self.dismiss()
    }
    
    //MARK: PPCreateUserViewControllerDelegate functions
    func didCreateAccount() {
        self.dismiss()
    }
}
