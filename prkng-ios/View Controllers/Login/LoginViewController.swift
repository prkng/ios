//
//  LoginViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 06/05/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class LoginViewController: AbstractViewController {
    
    var backgroundImageView : UIImageView
    var bottomContainer : UIView
    var loginTitleLabel : UILabel
    var facebookButton : UIButton
    var googlePlusButton : UIButton
    var emailButton : UIButton
    
    
    init() {
        backgroundImageView = UIImageView()
        bottomContainer = UIView()
        loginTitleLabel = UILabel()
        facebookButton = UIButton()
        googlePlusButton = UIButton()
        emailButton = UIButton()
        
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
        
        view.addSubview(backgroundImageView)
        
        view.addSubview(bottomContainer)
        
        loginTitleLabel.font = Styles.FontFaces.light(12)
        loginTitleLabel.textColor = Styles.Colors.midnight2
        bottomContainer.addSubview(loginTitleLabel)
        
        facebookButton.setImage(UIImage(named: ""), forState: <#UIControlState#>)
        bottomContainer.addSubview(facebookButton)
        
        bottomContainer.addSubview(googlePlusButton)
        
        bottomContainer.addSubview(emailButton)
        
    }
    
    func setupConstraints () {
        
        backgroundImageView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }
        
        bottomContainer.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.height.equalTo(100)
        }
        
        loginTitleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.bottomContainer).with.offset(13)
            make.centerX.equalTo(self.bottomContainer)
        }
        
        facebookButton.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(70, 70))
            make.centerX.equalTo(self.bottomContainer).multipliedBy(0.5)
        }
        
        googlePlusButton.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(70, 70))
            make.centerX.equalTo(self.bottomContainer).multipliedBy(0.5)
        }
        
        emailButton.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(70, 70))
            make.centerX.equalTo(self.bottomContainer).multipliedBy(0.5)
        }
        
    }
    
    
}
