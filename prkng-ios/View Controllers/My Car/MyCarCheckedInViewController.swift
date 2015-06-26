//
//  MyCarCheckedInViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 15/05/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class MyCarCheckedInViewController: MyCarAbstractViewController, UIGestureRecognizerDelegate {
    
    var spot : ParkingSpot?
    
    let backgroundImageView = UIImageView(image: UIImage(named:"bg_mycar"))
    
    var logoView : UIImageView
    
    var containerView : UIView
    var locationTitleLabel : UILabel
    var locationLabel : UILabel
    
    var availableTitleLabel : UILabel
    var availableTimeLabel : UILabel //ex: 24+
    
    var notificationsButton : UIButton
    
    var reportButton : UIButton
    
    var shareButton : UIButton
    var leaveButton : UIButton
    
    var checkinMessageVC : CheckinMessageViewController?
    
    var delegate : MyCarCheckedInViewControllerDelegate?
    
    
    private var SMALL_VERTICAL_MARGIN = 5
    private var MEDIUM_VERTICAL_MARGIN = 10
    private var LARGE_VERTICAL_MARGIN = 20
    
    
    init() {
        logoView = UIImageView()
        
        containerView = UIView()
        
        locationTitleLabel = ViewFactory.formLabel()
        locationLabel = ViewFactory.bigMessageLabel()
        
        availableTitleLabel = ViewFactory.formLabel()
        availableTimeLabel = UILabel()
        shareButton = ViewFactory.bigButton()
        leaveButton = ViewFactory.bigButton()
        
        notificationsButton = UIButton()
        reportButton = ViewFactory.reportButton()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func loadView() {
        self.view = UIView()
        setupViews()
        setupConstraints()
        
        //add a tap gesture recognizer
        var tapRecognizer1 = UITapGestureRecognizer(target: self, action: Selector("toggleTimeDisplay"))
        var tapRecognizer2 = UITapGestureRecognizer(target: self, action: Selector("toggleTimeDisplay"))
        var tapRecognizer3 = UITapGestureRecognizer(target: self, action: Selector("showSpotOnMap"))
        tapRecognizer1.delegate = self
        tapRecognizer2.delegate = self
        tapRecognizer3.delegate = self
        containerView.addGestureRecognizer(tapRecognizer1)
        backgroundImageView.addGestureRecognizer(tapRecognizer2)
        backgroundImageView.userInteractionEnabled = true
        logoView.addGestureRecognizer(tapRecognizer3)
        logoView.userInteractionEnabled = true
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (spot == nil) {
            containerView.hidden = true
            SVProgressHUD.setBackgroundColor(UIColor.clearColor())
            SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Clear)
            
            if (Settings.checkedIn()) {
                SpotOperations.getSpotDetails(Settings.checkedInSpotId()!, completion: { (spot) -> Void in
                    self.spot = spot
                    self.updateValues()
                    SVProgressHUD.dismiss()
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
        
        view.addSubview(backgroundImageView)
        
        logoView.image = UIImage(named: "icon_checkin")
        view.addSubview(logoView)
        
        view.addSubview(containerView)
        
        locationTitleLabel.text = "checked_in_message".localizedString.uppercaseString
        containerView.addSubview(locationTitleLabel)
        
        locationLabel.text = "PRKNG"
        containerView.addSubview(locationLabel)
        
        setDefaultTimeDisplay()
        containerView.addSubview(availableTitleLabel)
        
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
        
        reportButton.addTarget(self, action: "reportButtonTapped:", forControlEvents: .TouchUpInside)
        view.addSubview(reportButton)
        
        leaveButton.setTitle("leave_spot".localizedString.lowercaseString, forState: UIControlState.Normal)
        leaveButton.addTarget(self, action: "leaveButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(leaveButton)
        
        shareButton.setTitle("share_car_location".localizedString.lowercaseString, forState: UIControlState.Normal)
        shareButton.addTarget(self, action: "shareButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        shareButton.setTitleColor(Styles.Colors.petrol2, forState: .Normal)
        shareButton.layer.shadowColor = UIColor.blackColor().CGColor
        shareButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        shareButton.layer.shadowOpacity = 0.05
        shareButton.clipsToBounds = false
        view.addSubview(shareButton)
        
    }
    
    func setupConstraints () {
        
        var smallerVerticalMargin = MEDIUM_VERTICAL_MARGIN
        var largerVerticalMargin = LARGE_VERTICAL_MARGIN
        
        if UIScreen.mainScreen().bounds.size.height == 480 {
            smallerVerticalMargin = SMALL_VERTICAL_MARGIN
            largerVerticalMargin = MEDIUM_VERTICAL_MARGIN
        }
        
        backgroundImageView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }
        
        logoView.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(68, 68))
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.view).multipliedBy(0.3)
        }
        
        containerView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.logoView.snp_bottom).with.offset(largerVerticalMargin)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        locationTitleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.containerView)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.height.equalTo(20)
        }
        
        locationLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.locationTitleLabel.snp_bottom).with.offset(smallerVerticalMargin)
            make.left.equalTo(self.containerView).with.offset(15)
            make.right.equalTo(self.containerView).with.offset(-15)
        }
        
        availableTitleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.locationLabel.snp_bottom).with.offset(largerVerticalMargin)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
        }
        
        availableTimeLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.availableTitleLabel.snp_bottom).with.offset(smallerVerticalMargin)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.bottom.equalTo(self.containerView)
        }
        
        
        notificationsButton.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.shareButton.snp_top).with.offset(-largerVerticalMargin)
            make.size.equalTo(CGSizeMake(155, 26))
            make.centerX.equalTo(self.view)
        }
        
        reportButton.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(24, 24))
            make.bottom.equalTo(self.notificationsButton)
            make.centerX.equalTo(self.view).multipliedBy(1.66)
        }
        
        leaveButton.snp_makeConstraints { (make) -> () in
            make.height.equalTo(Styles.Sizes.hugeButtonHeight)
            make.bottom.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        
        shareButton.snp_makeConstraints { (make) -> () in
            make.height.equalTo(Styles.Sizes.hugeButtonHeight)
            make.bottom.equalTo(self.leaveButton.snp_top)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
    }
    
    func updateValues () {
        locationLabel.text = spot?.name
        
        let interval = Settings.checkInTimeRemaining()
        
        if (interval > 59) {
            if availableTitleLabel.text == "available_until".localizedString.uppercaseString {
                availableTimeLabel.attributedText = ParkingSpot.availableUntilAttributed(interval, firstPartFont: Styles.Fonts.h1r, secondPartFont: Styles.Fonts.h3r)
            } else {
                availableTimeLabel.attributedText = NSAttributedString(string: ParkingSpot.availableHourString(interval, limited: false))
                availableTimeLabel.font = Styles.Fonts.h1r
            }
        } else {
            availableTimeLabel.attributedText = NSAttributedString(string: "time_up".localizedString)
            availableTimeLabel.font = Styles.Fonts.h1r
        }
        
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
    
    func shareButtonTapped() {
        
        var text : String = "share_location_copy".localizedString
        text = text.stringByReplacingOccurrencesOfString("[street_name]", withString: spot!.name)
        let url = createGoogleMapsLink(spot!.buttonLocation)
        
        let activityViewController = UIActivityViewController( activityItems: [text, url], applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    func createGoogleMapsLink(location : CLLocation) -> NSURL {
        let latitude = "\(spot!.buttonLocation.coordinate.latitude)"
        let longitude = "\(spot!.buttonLocation.coordinate.longitude)"
        let urlStr = "http://maps.google.com/maps?q=" + latitude + "," + longitude + "&ll=" + latitude + "," + longitude + "&z=17"
        return NSURL(string: urlStr)!
    }
    
    func leaveButtonTapped() {
        
        Settings.checkOut()
        self.delegate?.reloadMyCarTab()
    }
    
    func reportButtonTapped(sender: UIButton) {
        loadReportScreen(self.spot?.identifier)
    }
    
    func setDefaultTimeDisplay() {
        
        let interval = Settings.checkInTimeRemaining()
        
        if (interval > 2*60*60) { // greater than 2 hours = show available until... by default
            availableTitleLabel.text = "available_until".localizedString.uppercaseString
        } else {
            availableTitleLabel.text = "available_for".localizedString.uppercaseString
        }
        
        updateValues()
    }
    
    func toggleTimeDisplay() {
        //toggle between available until and available for
        var fadeAnimation = CATransition()
        fadeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        fadeAnimation.type = kCATransitionFade
        fadeAnimation.duration = 0.4
        availableTitleLabel.layer.addAnimation(fadeAnimation, forKey: "fade")
        availableTimeLabel.layer.addAnimation(fadeAnimation, forKey: "fade")
        
        //update values just in case we've run out of time since the last tap...
        updateValues()
        
        if availableTimeLabel.text != "time_up".localizedString {
            if availableTitleLabel.text == "available_for".localizedString.uppercaseString {
                availableTitleLabel.text = "available_until".localizedString.uppercaseString
            } else {
                availableTitleLabel.text = "available_for".localizedString.uppercaseString
            }
            updateValues()
        }
        
    }
    
    func showSpotOnMap() {
        
        if let parkingSpot = self.spot {
            self.delegate?.showSpotOnMap(parkingSpot)
        }
    }
    
    //MARK- gesture recognizer delegate
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}


protocol MyCarCheckedInViewControllerDelegate {
    func reloadMyCarTab()
    func showSpotOnMap(spot: ParkingSpot)
}
