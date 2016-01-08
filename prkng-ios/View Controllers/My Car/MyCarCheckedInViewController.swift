//
//  MyCarCheckedInViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 15/05/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class MyCarCheckedInViewController: MyCarAbstractViewController, UIGestureRecognizerDelegate, POPAnimationDelegate {
    
    var spot: ParkingSpot?
    
    var backgroundImageView: UIImageView

    var shareButton: UIButton

    var logoView: UIImageView
    
    var containerView: UIView
    var locationTitleLabel: UILabel
    var locationLabel: UILabel
    
    var availableTitleLabel: UILabel
    var availableTimeLabel: UILabel //ex: 24+
    
    var bottomButtonContainer: UIView
    var bottomButtonLabel: UILabel
    var bottomPillButton: UIButton
    var bottomSelectionControl: SelectionControl
    
    var bigButtonContainer: UIView
    var reportButton: UIButton
    var leaveButton: UIButton
    
    var checkinMessageVC: CheckinMessageViewController?
    
    var delegate: MyCarAbstractViewControllerDelegate?
    
    private var timer: NSTimer?
    private var didAnimate = false
    
    private let SMALL_VERTICAL_MARGIN = 5
    private let MEDIUM_VERTICAL_MARGIN = 10
    private let LARGE_VERTICAL_MARGIN = 20
    
    private var smallerVerticalMargin: Int = 0
    private var largerVerticalMargin: Int = 0

    private let BUTTONS_TRANSLATION_X = CGFloat(2*36 + 20 + 14)
    
    let BOTTOM_BUTTON_HEIGHT: CGFloat = 36

    init() {
        
        backgroundImageView = UIImageView(image: UIImage(named:"bg_mycar"))

        shareButton = ViewFactory.shareButton()

        logoView = UIImageView()
        
        containerView = UIView()
        
        locationTitleLabel = ViewFactory.formLabel()
        locationLabel = ViewFactory.bigMessageLabel()
        
        availableTitleLabel = ViewFactory.formLabel()
        availableTimeLabel = UILabel()
        
        bottomButtonContainer = UIView()
        bottomButtonLabel = UILabel()
        bottomPillButton = UIButton()
        bottomSelectionControl = SelectionControl(titles: ["yes".localizedString.uppercaseString, "no".localizedString.uppercaseString])

        bigButtonContainer = UIView()
        leaveButton = ViewFactory.redRoundedButtonWithHeight(BOTTOM_BUTTON_HEIGHT, font: Styles.FontFaces.regular(12), text: "cancel".localizedString.uppercaseString)
        
        reportButton = ViewFactory.roundedButtonWithHeight(BOTTOM_BUTTON_HEIGHT, backgroundColor: Styles.Colors.stone, font: Styles.FontFaces.regular(12), text: "report_an_error".localizedString.uppercaseString, textColor: Styles.Colors.petrol2, highlightedTextColor: Styles.Colors.petrol1)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func loadView() {
        self.view = UIView()
        setupViews()
        setupConstraints()
        
        //add a tap gesture recognizer
        let tapRecognizer1 = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
        let tapRecognizer2 = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
        let tapRecognizer3 = UITapGestureRecognizer(target: self, action: Selector("showSpotOnMap"))
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
        self.screenName = "My Car - Checked in"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (spot == nil) {
            if #available(iOS 8.0, *) {
                logoView.alpha = 0
                containerView.alpha = 0
//                bigButtonContainer.layer.transform = CATransform3DMakeTranslation(CGFloat(0), BUTTONS_TRANSLATION_X, CGFloat(0))
            }
        }
        
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.timer?.invalidate()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        if (spot == nil) {
            
            if (!Settings.firstCheckin()) {
                SVProgressHUD.setBackgroundColor(UIColor.clearColor())
                SVProgressHUD.show()
            }
            
            let setSpot = {(spot: ParkingSpot?) -> () in
                self.spot = spot
                self.setDefaultTimeDisplay()
                SVProgressHUD.dismiss()
                if (spot != nil) {
                    
                    if #available(iOS 8.0, *) {
                        self.animateAndShow()
                    }
                    
                    if(Settings.firstCheckin()) {
                        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("showFirstCheckinMessage"), userInfo: nil, repeats: false)
                    }
                }
            }
            
            if let savedSpot = Settings.checkedInSpot() {
                setSpot(savedSpot)
            }
            if let spotId = Settings.checkedInSpotId() {
                SpotOperations.getSpotDetails(spotId, completion: { (spot) -> Void in
                    setSpot(spot)
                })
            }
            
        } else {
            self.updateValues()
        }
        

    }
    
    
    func setupViews () {
        
//        let screenHeight = UIScreen.mainScreen().bounds.height
//        let screenWidth = UIScreen.mainScreen().bounds.width
//        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let root = delegate.window?.rootViewController
//        let bounds = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
//        
//        UIGraphicsBeginImageContextWithOptions(bounds.size,
//            true, 1)
//        root!.view.drawViewHierarchyInRect(bounds,
//            afterScreenUpdates: true)
//        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        let blur = screenshot.applyBlurWithRadius(3, tintColor: UIColor.blackColor().colorWithAlphaComponent(0.85), saturationDeltaFactor: 1, maskImage: UIImage(named:"bg_mycar"))
//        
//        backgroundImageView.image = blur
        backgroundImageView.contentMode = .ScaleAspectFill
        view.addSubview(backgroundImageView)
        
        segmentedControl.setPressedHandler(segmentedControlTapped)
        self.view.addSubview(segmentedControl)
        
        shareButton.addTarget(self, action: "shareButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        self.view.addSubview(shareButton)

        logoView.image = UIImage(named: "icon_checkin")
        view.addSubview(logoView)
        
        view.addSubview(containerView)
        
        locationTitleLabel.text = "checked_in_message".localizedString.uppercaseString
        containerView.addSubview(locationTitleLabel)
        
        locationLabel.text = "PRKNG"
        containerView.addSubview(locationLabel)
        
        containerView.addSubview(availableTitleLabel)
        
        availableTimeLabel.textColor = Styles.Colors.red2
        availableTimeLabel.text = "0:00"
        availableTimeLabel.textAlignment = NSTextAlignment.Center
        containerView.addSubview(availableTimeLabel)
        
        view.addSubview(bigButtonContainer)
        
        bottomButtonContainer.backgroundColor = Styles.Colors.dark15
        self.view.addSubview(bottomButtonContainer)
        
        bottomButtonLabel.font = Styles.FontFaces.light(12)
        bottomButtonLabel.textColor = Styles.Colors.stone
        bottomButtonContainer.addSubview(bottomButtonLabel)
        
        bottomPillButton.clipsToBounds = true
        bottomPillButton.layer.cornerRadius = 12
        bottomPillButton.layer.borderWidth = 1
        bottomPillButton.titleLabel?.font = Styles.FontFaces.regular(12)
        bottomPillButton.setTitle("pay".localizedString.uppercaseString, forState: UIControlState.Normal)
        bottomPillButton.setTitleColor(Styles.Colors.stone, forState: UIControlState.Normal)
        bottomPillButton.layer.borderColor = Styles.Colors.stone.CGColor
        bottomPillButton.addTarget(self, action: "payButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        bottomButtonContainer.addSubview(bottomPillButton)

        bottomSelectionControl.addTarget(self, action: "nightBeforeSelectionValueChanged", forControlEvents: UIControlEvents.ValueChanged)
        bottomButtonContainer.addSubview(bottomSelectionControl)
        
        reportButton.addTarget(self, action: "reportButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        bigButtonContainer.addSubview(reportButton)

        leaveButton.addTarget(self, action: "leaveButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        bigButtonContainer.addSubview(leaveButton)
        
    }
    
    func setupConstraints () {
        
        smallerVerticalMargin = MEDIUM_VERTICAL_MARGIN
        largerVerticalMargin = LARGE_VERTICAL_MARGIN
        
        if UIScreen.mainScreen().bounds.size.height == 480 {
            smallerVerticalMargin = SMALL_VERTICAL_MARGIN
            largerVerticalMargin = MEDIUM_VERTICAL_MARGIN
        }
        
        backgroundImageView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }
        
        segmentedControl.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(CGSize(width: 140, height: 24))
            make.top.equalTo(self.snp_topLayoutGuideBottom).offset(30)
            make.centerX.equalTo(self.view)
        }
        
        shareButton.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.snp_topLayoutGuideBottom).offset(30)
            make.centerY.equalTo(self.segmentedControl).offset(-2)
            make.right.equalTo(self.view).offset(-50)
        }
        
        logoView.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(68, 68))
            make.centerX.equalTo(self.view)
            make.top.equalTo(self.segmentedControl.snp_bottom).offset(40)
        }
        
        containerView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.logoView.snp_bottom).offset(self.largerVerticalMargin)
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
            make.top.equalTo(self.locationTitleLabel.snp_bottom).offset(self.smallerVerticalMargin)
            make.left.equalTo(self.containerView).offset(15)
            make.right.equalTo(self.containerView).offset(-15)
        }
        
        availableTitleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.locationLabel.snp_bottom).offset(self.largerVerticalMargin)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
        }
        
        availableTimeLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.availableTitleLabel.snp_bottom).offset(self.smallerVerticalMargin)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.bottom.equalTo(self.containerView)
        }
        
        bigButtonContainer.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.height.equalTo(self.BUTTONS_TRANSLATION_X)
        }
        
        reportButton.snp_makeConstraints { (make) -> () in
            make.height.equalTo(BOTTOM_BUTTON_HEIGHT)
            make.bottom.equalTo(self.leaveButton.snp_top).offset(-14)
            make.left.equalTo(self.bigButtonContainer).offset(50)
            make.right.equalTo(self.bigButtonContainer).offset(-50)
        }
        
        leaveButton.snp_makeConstraints { (make) -> () in
            make.height.equalTo(BOTTOM_BUTTON_HEIGHT)
            make.bottom.equalTo(self.bigButtonContainer).offset(-20)
            make.left.equalTo(self.bigButtonContainer).offset(50)
            make.right.equalTo(self.bigButtonContainer).offset(-50)
        }
        
        bottomButtonContainer.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.reportButton.snp_top).offset(-14)
            make.left.equalTo(self.bigButtonContainer)
            make.right.equalTo(self.bigButtonContainer)
            make.height.equalTo(50)
        }
        
        bottomButtonLabel.snp_makeConstraints { (make) -> () in
            make.centerY.equalTo(self.bottomButtonContainer)
            make.left.equalTo(self.bottomButtonContainer).offset(27)
        }
        
        bottomPillButton.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSize(width: 92, height: 24))
            make.centerY.equalTo(self.bottomButtonContainer)
            make.right.equalTo(self.bottomButtonContainer).offset(-31)
        }
        
        bottomSelectionControl.snp_makeConstraints { (make) -> () in
            make.height.equalTo(self.bottomButtonContainer)
            make.centerY.equalTo(self.bottomButtonContainer)
            if #available(iOS 8.0, *) {
                make.left.equalTo(self.bottomButtonLabel.snp_rightMargin)
            } else {
                make.left.equalTo(self.bottomButtonLabel.snp_right)
            }
            make.right.equalTo(self.bottomButtonContainer)
        }
    }
    
    func updateValues () {
        locationLabel.text = spot?.name
        
        if self.spot != nil {
            switch self.spot!.currentlyActiveRuleType {
            case .Paid:
                let interval = self.spot!.currentlyActiveRuleEndTime
                logoView.image = UIImage(named: "icon_checkin_metered")
                availableTitleLabel.text = "pay_reminder".localizedString.uppercaseString
                
                let smallFont = Styles.FontFaces.regular(16)
                let bigFont = Styles.Fonts.h2r
                
                let attributedString = NSMutableAttributedString(string: "$", attributes: [NSFontAttributeName: smallFont, NSBaselineOffsetAttributeName: 5])
                let number = NSMutableAttributedString(string: self.spot!.currentlyActiveRule.paidHourlyRateString, attributes: [NSFontAttributeName: bigFont])
                let perHour = NSMutableAttributedString(string: "/H", attributes: [NSFontAttributeName: smallFont])
                let space = NSMutableAttributedString(string: " • ", attributes: [NSFontAttributeName: bigFont])
                let until = interval.untilAttributedString(bigFont, secondPartFont: smallFont)
                
                attributedString.appendAttributedString(number)
                attributedString.appendAttributedString(perHour)
                attributedString.appendAttributedString(space)
                attributedString.appendAttributedString(until)
                
                availableTimeLabel.attributedText = attributedString
                
                bottomButtonContainer.hidden = false
                bottomSelectionControl.hidden = true
                
                let coordinate = spot!.selectedButtonLocation ?? spot!.buttonLocations.first!
                if let closestCity = CityOperations.sharedInstance.closestCityToCoordinate(coordinate) {
                    switch closestCity.name {
                    case "montreal":
                        bottomButtonLabel.text = "p_service_mobile_user".localizedString.uppercaseString
                    case "quebec":
                        bottomButtonLabel.text = "copilote_mobile_user".localizedString.uppercaseString
                    default:
                        bottomButtonContainer.hidden = true
                    }
                } else {
                    bottomButtonContainer.hidden = true
                }

                
                break
            default:
                logoView.image = UIImage(named: "icon_checkin")
                let interval = Settings.checkInTimeRemaining()
                if spot!.isAlwaysAuthorized() {
                    availableTitleLabel.text = spot!.bottomRightTitleText
                    availableTimeLabel.attributedText = spot!.bottomRightPrimaryText
                } else {
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
                
                bottomButtonContainer.hidden = true
                bottomSelectionControl.hidden = false
                bottomPillButton.hidden = true

                let intervalInEndDay = (DateUtil.timeIntervalSinceDayStart() + interval) % (24*3600)
                let isDayBefore = interval <= 24*3600
                if intervalInEndDay < 12*3600 && (DateUtil.timeIntervalSinceDayStart() <= 16*3600 || !isDayBefore) {
                    bottomButtonContainer.hidden = false
                    bottomButtonLabel.text = "notified_night_before".localizedString.uppercaseString
                    let i = Settings.shouldNotifyTheNightBefore() ? 0 : 1
                    bottomSelectionControl.selectOption(bottomSelectionControl.buttons[i], animated: false)
                }
                break
            }
            if spot!.currentlyActiveRule.ruleType == .Free
                && spot!.nextRule?.ruleType == .SnowRestriction {
                    logoView.image = UIImage(named: "icon_checkin_snowflake")
                    availableTitleLabel.text = spot!.bottomRightTitleText
                    availableTimeLabel.attributedText = spot!.bottomRightPrimaryText
            }
            
        }
        
        //update the values every 2 seconds
        if self.timer == nil {
            self.timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "updateValues", userInfo: nil, repeats: true)

        }
        
    }
    
    
    func showFirstCheckinMessage() {
        
        checkinMessageVC = CheckinMessageViewController()
        
        self.addChildViewController(checkinMessageVC!)
        self.view.addSubview(checkinMessageVC!.view)
        checkinMessageVC!.didMoveToParentViewController(self)
        
        checkinMessageVC!.view.snp_makeConstraints(closure: { (make) -> () in
            make.edges.equalTo(self.view)
        })
        
        let tap = UITapGestureRecognizer(target: self, action: "hideFirstCheckinMessage")
        checkinMessageVC!.view.addGestureRecognizer(tap)
        
        checkinMessageVC!.view.alpha = 0.0
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.checkinMessageVC!.view.alpha = 1.0
        })
        
        
        Settings.setFirstCheckinPassed(true)
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
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.send(GAIDictionaryBuilder.createEventWithCategory("My Car - Checked In", action: "Share Button Tapped", label: nil, value: nil).build() as [NSObject: AnyObject])

        createGoogleMapsLink(spot!.selectedButtonLocation ?? spot!.buttonLocations.first!)
    }
    
    func createGoogleMapsLink(coordinate: CLLocationCoordinate2D) {
        let latitude = "\(coordinate.latitude)"
        let longitude = "\(coordinate.longitude)"
        let longUrlString = "http://maps.google.com/maps?q=" + latitude + "," + longitude + "&ll=" + latitude + "," + longitude + "&z=17"

        request(Method.POST, URLString: "https://www.googleapis.com/urlshortener/v1/url?key=AIzaSyBVSdiMcYO1qpJIMbcOV9ATgWpSxsGvc1M", parameters: ["longUrl": longUrlString], encoding: ParameterEncoding.JSON).responseSwiftyJSON { (request, response, json, error) -> Void in
            if error == nil && response?.statusCode == 200 {
                if let shortUrlString = json["id"].string {
                    self.shareButtonTappedCompletion(shortUrlString)
                }
            } else {
                self.shareButtonTappedCompletion(longUrlString)
            }
        }
    }
    
    func shareButtonTappedCompletion(url: String) {
        var text: String = "share_location_copy".localizedString
        text = text.stringByReplacingOccurrencesOfString("[street_name]", withString: spot!.name)
        text += "\n--\n" + url
        let activityViewController = UIActivityViewController( activityItems: [text], applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    func leaveButtonTapped() {
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.send(GAIDictionaryBuilder.createEventWithCategory("My Car - Checked In", action: "Check Out Button Tapped", label: nil, value: nil).build() as [NSObject: AnyObject])

//        SpotOperations.checkout({ (completed) -> Void in
            Settings.checkOut()
            self.delegate?.reloadMyCarTab()
//        })
    }
    
    func reportButtonTapped(sender: UIButton) {
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.send(GAIDictionaryBuilder.createEventWithCategory("My Car - Checked In", action: "Report Button Tapped", label: nil, value: nil).build() as [NSObject: AnyObject])

        loadReportScreen(self.spot?.identifier)
    }
    
    func payButtonTapped(sender: UIButton) {

        let tracker = GAI.sharedInstance().defaultTracker
        tracker.send(GAIDictionaryBuilder.createEventWithCategory("My Car - Checked In", action: "Pay Button Tapped", label: bottomButtonLabel.text, value: nil).build() as [NSObject: AnyObject])

        var url = NSURL(string: "")

        let coordinate = spot!.selectedButtonLocation ?? spot!.buttonLocations.first!
        if let closestCity = CityOperations.sharedInstance.closestCityToCoordinate(coordinate) {
            switch closestCity.name {
            case "montreal":
                url = NSURL(string: "https://itunes.apple.com/ca/app/p-service-mobile/id535957293")
            case "quebec":
                url = NSURL(string: "copilote://")
                if !UIApplication.sharedApplication().canOpenURL(url!) {
                    url = NSURL(string: "https://itunes.apple.com/ca/app/copilote/id936501366")
                }
            default:
                break
            }
        }

        UIApplication.sharedApplication().openURL(url!)
    }
    
    func nightBeforeSelectionValueChanged() {
        
        if self.spot != nil {
            switch(bottomSelectionControl.selectedIndex) {
            case 0:
                //yes you stupid iphone, remind me the night before
                Settings.setShouldNotifyTheNightBefore(true)
                
                let interval = Settings.checkInTimeRemaining()
                let intervalInEndDay = (DateUtil.timeIntervalSinceDayStart() + interval) % (24*60*60)
                
                var date8pmBefore = NSDate(timeIntervalSinceNow:interval - intervalInEndDay - (4*60*60))
                date8pmBefore = date8pmBefore.dateBySubtractingMinutes(date8pmBefore.minute())

                Settings.scheduleNotification(date8pmBefore)
                
                break
            case 1:
                //no you stupid iphone, stop trying to make early reminders happen. they're not going to happen.
                Settings.setShouldNotifyTheNightBefore(false)
                Settings.scheduleNotification(NSDate(timeIntervalSinceNow: Settings.checkInTimeRemaining() - NSTimeInterval(Settings.notificationTime() * 60)))
                
                break
            default:break
            }
        }
    }


    
    func setDefaultTimeDisplay() {
        
        if self.spot != nil {
            switch self.spot!.currentlyActiveRuleType {
            case .Paid:
                availableTitleLabel.text = "pay_reminder".localizedString.uppercaseString
                break
            default:
                let interval = Settings.checkInTimeRemaining()
                
                if (interval > 2*3600) { // greater than 2 hours = show available until... by default
                    availableTitleLabel.text = "available_until".localizedString.uppercaseString
                } else {
                    availableTitleLabel.text = "available_for".localizedString.uppercaseString
                }
                break
            }
        }
        updateValues()
    }
    
    func toggleTimeDisplay() {
        //toggle between available until and available for
        let fadeAnimation = CATransition()
        fadeAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        fadeAnimation.type = kCATransitionFade
        fadeAnimation.duration = 0.4
        availableTitleLabel.layer.addAnimation(fadeAnimation, forKey: "fade")
        availableTimeLabel.layer.addAnimation(fadeAnimation, forKey: "fade")
        
        //update values just in case we've run out of time since the last tap...
        updateValues()
        
        if availableTimeLabel.text != "time_up".localizedString
            && availableTimeLabel.text != "pay_reminder".localizedString.uppercaseString {
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
            let coordinate = parkingSpot.selectedButtonLocation ?? parkingSpot.buttonLocations.first!
            let name = parkingSpot.name
            self.delegate?.goToCoordinate(coordinate, named: name, showing: false)
        }
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        
        let tap = recognizer.locationInView(self.view)
        let point = availableTitleLabel.convertPoint(availableTitleLabel.bounds.origin, toView: self.view)
        let pointY = point.y - CGFloat(largerVerticalMargin)/2
        
        if tap.y > pointY {
            toggleTimeDisplay()
        } else {
            showSpotOnMap()
        }
    }
    
    //MARK- gesture recognizer delegate
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    func animateAndShow() {
        
        if didAnimate {
            return
        }
        
        let logoFadeInAnimation = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
        logoFadeInAnimation.fromValue = NSNumber(int: 0)
        logoFadeInAnimation.toValue = NSNumber(int: 1)
        logoFadeInAnimation.duration = 0.3
        logoView.layer.pop_addAnimation(logoFadeInAnimation, forKey: "logoFadeInAnimation")
        
        let logoSpringAnimation = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)
        logoSpringAnimation.fromValue = NSValue(CGPoint: CGPoint(x: 0.5, y: 0.5))
        logoSpringAnimation.toValue = NSValue(CGPoint: CGPoint(x: 1, y: 1))
        logoSpringAnimation.springBounciness = 20
        logoView.layer.pop_addAnimation(logoSpringAnimation, forKey: "logoSpringAnimation")
        
        let containerFadeInAnimation = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
        containerFadeInAnimation.fromValue = NSNumber(int: 0)
        containerFadeInAnimation.toValue = NSNumber(int: 1)
        containerFadeInAnimation.duration = 0.6
        containerFadeInAnimation.beginTime = CACurrentMediaTime() + 0.15
        containerFadeInAnimation.completionBlock = {(anim, finished) in
//            // Slide in buttons once container fully visible
//            let buttonSlideAnimation = POPBasicAnimation(propertyNamed: kPOPLayerTranslationY)
//            buttonSlideAnimation.fromValue = NSNumber(float: Float(self.BUTTONS_TRANSLATION_X))
//            buttonSlideAnimation.toValue = NSNumber(int: 0)
//            buttonSlideAnimation.duration = 0.2
//            self.bigButtonContainer.layer.pop_addAnimation(buttonSlideAnimation, forKey: "buttonSlideAnimation")
        }
        self.containerView.layer.pop_addAnimation(containerFadeInAnimation, forKey: "containerFadeInAnimation")

        self.didAnimate = true
    }
    
}

