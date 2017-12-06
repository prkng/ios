//
//  LoginPermissionsViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-11-10.
//  Copyright © 2015 PRKNG. All rights reserved.
//

import UIKit

class LoginPermissionsViewController: AbstractViewController {
    
    fileprivate var backgroundImageView = UIImageView()
    fileprivate var centerImageView = UIImageView()
    fileprivate var bottomLabel = UILabel()
    fileprivate var bottomLabelBackgroundView = UIView()
    fileprivate var arrow = UIImageView(image: UIImage(named: "icon_arrow_up")!)
    fileprivate var notificationFrame = UIView()
    
    fileprivate var work: () -> Void
    fileprivate var completion: () -> Void
    
    fileprivate var passedPermissions = [String]()
    
    init(work: @escaping () -> Void, completion: @escaping () -> Void) {
        self.work = work
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginPermissionsViewController.didGetPermission(_:)), name: NSNotification.Name(rawValue: "registeredUserNotificationSettings"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(LoginPermissionsViewController.didGetPermission(_:)), name: NSNotification.Name(rawValue: "changedLocationPermissions"), object: nil)
    }

    func didGetPermission(_ notification: Notification) {
        passedPermissions.append(notification.name.rawValue)
        
        if notification.name == "registeredUserNotificationSettings" {
            centerImageView.image = UIImage(named: "img_permissions_location")
            let transition = CATransition()
            transition.duration = 0.7
            transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
            transition.type = kCATransitionFade
            centerImageView.layer.add(transition, forKey: nil)
            bottomLabel.text = "location_permissions_bottom_text".localizedString
        }
        
        if passedPermissions.count >= 2 {
            self.dismiss(animated: true, completion: { () -> Void in
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "registeredUserNotificationSettings"), object: nil)
                NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "changedLocationPermissions"), object: nil)
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
    
    override func viewDidAppear(_ animated: Bool) {
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
        
        if UIScreen.main.bounds.width == 320 {
            bottomLabelBackgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        }
        view.addSubview(bottomLabelBackgroundView)
        
        bottomLabel.numberOfLines = 0
        bottomLabel.shadowColor = Styles.Colors.transparentBlack
        bottomLabel.shadowOffset = CGSize(width: 1, height: 1)
        bottomLabel.font = Styles.FontFaces.regular(17)
        bottomLabel.textColor = Styles.Colors.cream1
        bottomLabel.textAlignment = .center
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
        
        bottomLabelBackgroundView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(self.bottomLabel).offset(-6)
            make.bottom.equalTo(self.view)
        }
        
    }
    
    
}
