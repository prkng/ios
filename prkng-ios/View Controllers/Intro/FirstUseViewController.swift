//
//  IntroViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 7/5/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class FirstUseViewController: AbstractViewController {

    var backgroundImageView : UIImageView
    var logoView : UIImageView
    var parkNowButton : UIButton
    var tourButton : UIButton
    
    
    init() {
        backgroundImageView = UIImageView()
        logoView = UIImageView()
        parkNowButton = ViewFactory.redRoundedButton()
        tourButton = ViewFactory.hugeButton()
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
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        SVProgressHUD.dismiss()
    }
    
    
    func setupViews () {
        
        view.backgroundColor = Styles.Colors.petrol1
        
        backgroundImageView.image = UIImage(named: "bg_opening")
        backgroundImageView.contentMode = UIViewContentMode.ScaleAspectFill
        view.addSubview(backgroundImageView)
        
        logoView.image = UIImage(named: "logo_opening")
        view.addSubview(logoView)
        
        parkNowButton.setTitle(NSLocalizedString("park_now", comment : ""), forState: UIControlState.Normal)
        parkNowButton.addTarget(self, action: "parkNowButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(parkNowButton)
        parkNowButton.hidden = true
        
        tourButton.setTitle(NSLocalizedString("take_the_tour", comment : ""), forState: UIControlState.Normal)
        tourButton.addTarget(self, action: "tourButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(tourButton)
    }
    
    func setupConstraints () {
        
        
        backgroundImageView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }
        
        logoView.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.view).multipliedBy(0.5)
        }
        
        parkNowButton.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.view)
            make.size.equalTo(CGSizeMake(100, 26))
            make.bottom.equalTo(self.tourButton.snp_top).with.offset(-20)
        }
        
        tourButton.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.height.equalTo(Styles.Sizes.hugeButtonHeight)
        }
        
    }
    
    
    
    func parkNowButtonTapped() {
        self.presentViewController(LoginViewController(), animated: true) { () -> Void in
            
        }
    }
    
    
    func tourButtonTapped() {
        
        let tutorial = TutorialViewController()
        tutorial.parent = self
        
        self.presentViewController(tutorial, animated: true) { () -> Void in
            
        }
        
    }

}
