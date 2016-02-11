//
//  PPIntroViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2016-02-09.
//  Copyright © 2016 PRKNG. All rights reserved.
//

import UIKit

class PPIntroViewController: AbstractViewController {
    
    var titleLabel = UILabel()
    var logoView = UIImageView()
    var bodyLabel = UILabel()
    var createAccountButton = ViewFactory.redRoundedButtonWithHeight(36, font: Styles.FontFaces.bold(12), text: "create_my_account".localizedString.uppercaseString)
    var signInButton = UIButton()
    
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
        
        view.backgroundColor = Styles.Colors.stone
        
        //TODO: localize all these strings including create_my_account above
        titleLabel.text = "parking_panda_intro_text".localizedString
        titleLabel.font = Styles.FontFaces.bold(25)
        view.addSubview(titleLabel)
        
        logoView.image = UIImage(named: "logo_opening")
        view.addSubview(logoView)
        
        bodyLabel.text = "parking_panda_intro_body_text".localizedString
        bodyLabel.font = Styles.FontFaces.regular(16)
        view.addSubview(bodyLabel)
        
        createAccountButton.setTitle("register".localizedString.uppercaseString, forState: UIControlState.Normal)
        createAccountButton.addTarget(self, action: "createAccountButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(createAccountButton)
        
        signInButton.setTitle("parking_panda_login_text".localizedString.uppercaseString, forState: UIControlState.Normal)
        signInButton.addTarget(self, action: "signInButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(signInButton)

    }
    
    func setupConstraints () {
        
        titleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view.snp_top)
            make.centerX.equalTo(self.view)
        }
        
        logoView.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.view).multipliedBy(0.5)
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
    
    func signInButtonTapped() {
        let signInVC = PPSignInViewController()
        self.presentViewController(signInVC, animated: true, completion: nil)
//        self.presentViewControllerWithFade(signInVC, completion: nil)
    }
    
    func createAccountButtonTapped() {
        let signInVC = PPSignInViewController()
        self.presentViewController(signInVC, animated: true, completion: nil)
//        self.presentViewControllerWithFade(signInVC, completion: nil)
    }
    
    func present() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let rootVC = appDelegate.window?.rootViewController {
            if let navVC = rootVC.navigationController {
                navVC.pushViewController(self, animated: true)
            } else {
                rootVC.presentViewController(self, animated: true, completion: nil)
            }
        }
        
    }
    
}
