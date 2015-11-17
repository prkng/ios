//
//  LoginPermissionsViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-11-10.
//  Copyright © 2015 PRKNG. All rights reserved.
//

import UIKit

class LoginPermissionsViewController: AbstractViewController {
    
    private var backgroundImageView = UIImageView()
    private var centerImageView = UIImageView()
    private var bottomLabel = UILabel()
    private var arrow = UIImageView(image: UIImage(named: "icon_arrow_up")!)
    private var notificationFrame = UIView()
    
    private var work: () -> Void
    private var completion: () -> Void
    
    private var passedPermissions = [String]()
    
    init(work: () -> Void, completion: () -> Void) {
        self.work = work
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didGetPermission:", name: "registeredUserNotificationSettings", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "didGetPermission:", name: "changedLocationPermissions", object: nil)
    }

    func didGetPermission(notification: NSNotification) {
        passedPermissions.append(notification.name)
        
        if notification.name == "registeredUserNotificationSettings" {
            centerImageView.image = UIImage(named: "img_permissions_location")
            let transition = CATransition()
            transition.duration = 0.7
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionFade
            centerImageView.layer.addAnimation(transition, forKey: nil)
        }
        
        if passedPermissions.count >= 2 {
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                NSNotificationCenter.defaultCenter().removeObserver(self, name: "registeredUserNotificationSettings", object: nil)
                NSNotificationCenter.defaultCenter().removeObserver(self, name: "changedLocationPermissions", object: nil)
                self.completion()
            })
        }
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
        self.screenName = "Permissions View"
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.work()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    func setupViews () {
        
        view.backgroundColor = Styles.Colors.midnight1
        
        view.addSubview(notificationFrame)
        
        backgroundImageView.image = UIImage(named: "bg_permissions")
        view.addSubview(backgroundImageView)
        
        centerImageView.image = UIImage(named: "img_permissions_notifications")
        view.addSubview(centerImageView)
        
        bottomLabel.numberOfLines = 0
        bottomLabel.shadowColor = Styles.Colors.transparentBlack
        bottomLabel.shadowOffset = CGSize(width: 1, height: 1)
        bottomLabel.font = Styles.FontFaces.regular(17)
        bottomLabel.textColor = Styles.Colors.cream1
        bottomLabel.textAlignment = .Center
        bottomLabel.text = "login_permissions_bottom_text".localizedString
        view.addSubview(bottomLabel)
        
        view.addSubview(arrow)

    }
    
    func setupConstraints () {
        
        notificationFrame.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(CGSize(width: 269, height: 181))
            make.center.equalTo(self.view)
        }
        
        arrow.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.notificationFrame.snp_bottom).offset(8)
            make.centerX.equalTo(self.notificationFrame.snp_centerX).offset(269/4)
        }

        backgroundImageView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }

        centerImageView.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(self.view.snp_centerY).multipliedBy(0.87)
            make.left.equalTo(self.view).offset(30)
            make.right.equalTo(self.view).offset(-30)
        }
        
        bottomLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.view).offset(40)
            make.right.equalTo(self.view).offset(-40)
            make.centerY.equalTo(self.view.snp_centerY).multipliedBy(1.6)
        }
        
    }
    
    
}
