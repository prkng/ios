//
//  MyCarCheckedInViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 15/05/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class MyCarCheckedInViewController: AbstractViewController {
    
    var spot : ParkingSpot?

    var logoView : UIImageView
    
    var activityIndicator : UIActivityIndicatorView
    
    var containerView : UIView
    var locationTitleLabel : UILabel
    var locationLabel : UILabel
    
    var availableTitleLabel : UILabel
    var availableTimeLabel : UILabel
    
    var notificationsButton : UIButton
    
//    var shareButton : UIButton
    var leaveButton : UIButton
    
    var checkinMessageVC : CheckinMessageViewController?
    
    var delegate : MyCarCheckedInViewControllerDelegate?
    
    init() {
        logoView = UIImageView()
        
        activityIndicator = UIActivityIndicatorView()
        
        containerView = UIView()
        locationTitleLabel = ViewFactory.formLabel()
        locationLabel = ViewFactory.bigMessageLabel()

        availableTitleLabel = ViewFactory.formLabel()
        availableTimeLabel = UILabel()
        leaveButton = ViewFactory.bigButton()
        
        notificationsButton = UIButton()
        
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
        
        if (spot == nil) {
            containerView.hidden = true
            activityIndicator.startAnimating()
            
            if (Settings.checkedIn()) {
                SpotOperations.getSpotDetails(Settings.checkedInSpotId()!, completion: { (spot) -> Void in
                    self.spot = spot
                    self.updateValues()
                    self.activityIndicator.stopAnimating()
                    if (spot != nil) {
                        self.containerView.hidden = false
                    }

                })
            }
        }
        
        
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if (Settings.firstCheckin()) {
            showFirstCheckinMessage()
            Settings.setFirstCheckinPassed(true)
        }
    }
    
    
    func setupViews () {

        view.backgroundColor = UIColor(red: 48.0/255.0, green: 58/255.0, blue: 66/255.0, alpha: 0.9) //FIXME
        
        logoView.image = UIImage(named: "icon_checkin")
        view.addSubview(logoView)
        
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
        
        view.addSubview(containerView)
        
        locationTitleLabel.text = "checked_in_message".localizedString.uppercaseString
        containerView.addSubview(locationTitleLabel)
        
        locationLabel.text = "PRKNG"
        containerView.addSubview(locationLabel)
        
        availableTitleLabel.text = "available_for".localizedString.uppercaseString
        containerView.addSubview(availableTitleLabel)
        
        availableTimeLabel.font = Styles.FontFaces.regular(40)
        availableTimeLabel.textColor = Styles.Colors.red2
        availableTimeLabel.text = "0:00"
        availableTimeLabel.textAlignment = NSTextAlignment.Center
        containerView.addSubview(availableTimeLabel)
        
        notificationsButton.clipsToBounds = true
        notificationsButton.layer.cornerRadius = 14
        notificationsButton.layer.borderWidth = 1
        notificationsButton.titleLabel?.font = Styles.FontFaces.light(12)
        notificationsButton.setTitleColor(Styles.Colors.stone, forState: UIControlState.Normal)
        notificationsButton.setTitleColor(Styles.Colors.anthracite1, forState: UIControlState.Highlighted)
        notificationsButton.addTarget(self, action: "toggleNotifications", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(notificationsButton)
        updateNotificationsButton()
        
        leaveButton.setTitle("leave_spot".localizedString.lowercaseString, forState: UIControlState.Normal)
        leaveButton.addTarget(self, action: "leaveButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(leaveButton)
        
    }
    
    func setupConstraints () {
        
        logoView.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(68, 68))
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.view).multipliedBy(0.3)
        }
        
        activityIndicator.snp_makeConstraints { (make) -> () in
            make.center.equalTo(self.view)
        }
        
        containerView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.logoView.snp_bottom).with.offset(20)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        locationTitleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.containerView)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
        }

        locationLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.locationTitleLabel.snp_bottom).with.offset(10)
            make.left.equalTo(self.containerView).with.offset(15)
            make.right.equalTo(self.containerView).with.offset(-15)
        }
        
        availableTitleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.locationLabel.snp_bottom).with.offset(20)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
        }
        
        availableTimeLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.availableTitleLabel.snp_bottom).with.offset(10)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.bottom.equalTo(self.containerView)
        }
        
        
        notificationsButton.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.leaveButton.snp_top).with.offset(-20)
            make.size.equalTo(CGSizeMake(155, 26))
            make.centerX.equalTo(self.view)
        }
        
        leaveButton.snp_makeConstraints { (make) -> () in
            make.height.equalTo(Styles.Sizes.bigButtonHeight)
            make.bottom.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
    }
    
    func updateValues () {
        locationLabel.text = spot?.name
        availableTimeLabel.text = spot?.availableHourString()
    }
    
    func toggleNotifications () {
        
        if Settings.notificationTime() > 0 {
            Settings.setNotificationTime(0)
            Settings.cancelAlarm()
        } else {
            Settings.setNotificationTime(30)
            Settings.scheduleAlarm(NSDate(timeIntervalSinceNow: self.spot!.availableTimeInterval() - (30 * 60)))            
        }
        
        updateNotificationsButton()
    }
    
    func updateNotificationsButton() {
     
        if (Settings.notificationTime() > 0) {
            
            notificationsButton.setTitle("notifications_on".localizedString.uppercaseString, forState: UIControlState.Normal)
            notificationsButton.layer.borderColor = Styles.Colors.red2.CGColor
            notificationsButton.backgroundColor = Styles.Colors.red2
            
        } else {
            
            notificationsButton.setTitle("notifications_off".localizedString.uppercaseString, forState: UIControlState.Normal)
            notificationsButton.layer.borderColor = Styles.Colors.stone.CGColor
            notificationsButton.backgroundColor = UIColor.clearColor()
        }
        
        
    }
    
    
    func showFirstCheckinMessage() {
        
        checkinMessageVC = CheckinMessageViewController()
        
        self.addChildViewController(checkinMessageVC!)
        self.view.addSubview(checkinMessageVC!.view)
        checkinMessageVC!.didMoveToParentViewController(self)
        
        checkinMessageVC!.view.snp_makeConstraints({ (make) -> () in
            make.edges.equalTo(self.view)
        })
        
        let tap = UITapGestureRecognizer(target: self, action: "hideFirstCheckinMessage")
        checkinMessageVC!.view.addGestureRecognizer(tap)
        
        checkinMessageVC!.view.alpha = 0.0
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.checkinMessageVC!.view.alpha = 1.0
        })
        
    }
    
    func hideFirstCheckinMessage () {
        
        if let checkinMessageVC = self.checkinMessageVC {
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                checkinMessageVC.view.alpha = 0.0
                }, completion: { (finished) -> Void in
                    checkinMessageVC.removeFromParentViewController()
                    checkinMessageVC.view.removeFromSuperview()
                    checkinMessageVC.didMoveToParentViewController(nil)
                    self.checkinMessageVC = nil
            })
            
        }
        
        
    }    
    
    func leaveButtonTapped() {
        
        Settings.saveCheckInData(nil, time: nil)
        Settings.cancelAlarm()
        self.delegate?.reloadMyCarTab()
    }
    
    
}


protocol MyCarCheckedInViewControllerDelegate {
    func reloadMyCarTab()
}
