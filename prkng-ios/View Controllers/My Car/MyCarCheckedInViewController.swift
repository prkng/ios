//
//  MyCarCheckedInViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 15/05/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class MyCarCheckedInViewController: MyCarAbstractViewController, UIGestureRecognizerDelegate, POPAnimationDelegate {
    
    var spot : ParkingSpot?
    
    let backgroundImageView = UIImageView(image: UIImage(named:"bg_mycar"))
    
    var logoView : UIImageView
    
    var containerView : UIView
    var locationTitleLabel : UILabel
    var locationLabel : UILabel
    
    var availableTitleLabel : UILabel
    var availableTimeLabel : UILabel //ex: 24+

    var smallButtonContainer : UIView
    var reportButton : UIButton
    
    var bigButtonContainer : UIView
    var shareButton : UIButton
    var leaveButton : UIButton
    
    var checkinMessageVC : CheckinMessageViewController?
    
    var delegate : MyCarCheckedInViewControllerDelegate?
    
    private var timer : NSTimer?
    
    private let SMALL_VERTICAL_MARGIN = 5
    private let MEDIUM_VERTICAL_MARGIN = 10
    private let LARGE_VERTICAL_MARGIN = 20
    
    private var smallerVerticalMargin: Int = 0
    private var largerVerticalMargin: Int = 0

    private let BUTTONS_TRANSLATION_X = CGFloat(Styles.Sizes.hugeButtonHeight * 2)
    
    
    init() {
        logoView = UIImageView()
        
        containerView = UIView()
        
        locationTitleLabel = ViewFactory.formLabel()
        locationLabel = ViewFactory.bigMessageLabel()
        
        availableTitleLabel = ViewFactory.formLabel()
        availableTimeLabel = UILabel()
        
        bigButtonContainer = UIView()
        shareButton = ViewFactory.hugeButton()
        leaveButton = ViewFactory.hugeButton()
        
        smallButtonContainer = UIView()
        reportButton = UIButton()
        
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
        var tapRecognizer1 = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
        var tapRecognizer2 = UITapGestureRecognizer(target: self, action: Selector("handleSingleTap:"))
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
        self.screenName = "My Car - Checked in"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (spot == nil) {
            logoView.alpha = 0
            containerView.alpha = 0
            smallButtonContainer.alpha = 0
            bigButtonContainer.layer.transform = CATransform3DMakeTranslation(CGFloat(0), BUTTONS_TRANSLATION_X, CGFloat(0))
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
                SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Clear)
            }
            
            let setSpot = {(var spot: ParkingSpot?) -> () in
                self.spot = spot
                self.updateValues()
                SVProgressHUD.dismiss()
                if (spot != nil) {
                    self.animateAndShow()
                    
                    if(Settings.firstCheckin()) {
                        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("showFirstCheckinMessage"), userInfo: nil, repeats: false)
                    }
                }
            }
            
            if let savedSpot = Settings.checkedInSpot() {
                setSpot(savedSpot)
            } else {
                SpotOperations.getSpotDetails(Settings.checkedInSpotId()!, completion: { (spot) -> Void in
                    setSpot(spot)
                })
            }
            
        } else {
            self.updateValues()
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
        
        view.addSubview(smallButtonContainer)
        
        reportButton.clipsToBounds = true
        reportButton.layer.cornerRadius = 14
        reportButton.layer.borderWidth = 1
        reportButton.titleLabel?.font = Styles.FontFaces.light(12)
        reportButton.setTitle("report_an_error".localizedString.uppercaseString, forState: UIControlState.Normal)
        reportButton.setTitleColor(Styles.Colors.stone, forState: UIControlState.Normal)
        reportButton.layer.borderColor = Styles.Colors.red2.CGColor
        reportButton.backgroundColor = Styles.Colors.red2
        reportButton.addTarget(self, action: "reportButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        smallButtonContainer.addSubview(reportButton)
        
        view.addSubview(bigButtonContainer)
        
        leaveButton.setTitle("leave_spot".localizedString.lowercaseString, forState: UIControlState.Normal)
        leaveButton.addTarget(self, action: "leaveButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        bigButtonContainer.addSubview(leaveButton)
        
        shareButton.setTitle("share_car_location".localizedString.lowercaseString, forState: UIControlState.Normal)
        shareButton.addTarget(self, action: "shareButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        shareButton.setTitleColor(Styles.Colors.petrol2, forState: .Normal)
        bigButtonContainer.addSubview(shareButton)
        
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
        
        logoView.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(68, 68))
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.view).multipliedBy(0.3)
        }
        
        containerView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.logoView.snp_bottom).with.offset(self.largerVerticalMargin)
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
            make.top.equalTo(self.locationTitleLabel.snp_bottom).with.offset(self.smallerVerticalMargin)
            make.left.equalTo(self.containerView).with.offset(15)
            make.right.equalTo(self.containerView).with.offset(-15)
        }
        
        availableTitleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.locationLabel.snp_bottom).with.offset(self.largerVerticalMargin)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
        }
        
        availableTimeLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.availableTitleLabel.snp_bottom).with.offset(self.smallerVerticalMargin)
            make.left.equalTo(self.containerView)
            make.right.equalTo(self.containerView)
            make.bottom.equalTo(self.containerView)
        }
        
        smallButtonContainer.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.shareButton.snp_top).with.offset(-self.largerVerticalMargin)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(26)
        }
        
        reportButton.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.smallButtonContainer)
            make.size.equalTo(CGSizeMake(155, 26))
            make.centerX.equalTo(self.smallButtonContainer)
        }
        
        bigButtonContainer.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.height.equalTo(Styles.Sizes.hugeButtonHeight * 2)
        }
        
        leaveButton.snp_makeConstraints { (make) -> () in
            make.height.equalTo(Styles.Sizes.hugeButtonHeight)
            make.bottom.equalTo(self.bigButtonContainer)
            make.left.equalTo(self.bigButtonContainer)
            make.right.equalTo(self.bigButtonContainer)
        }
        
        
        shareButton.snp_makeConstraints { (make) -> () in
            make.height.equalTo(Styles.Sizes.hugeButtonHeight)
            make.bottom.equalTo(self.leaveButton.snp_top)
            make.left.equalTo(self.bigButtonContainer)
            make.right.equalTo(self.bigButtonContainer)
        }
        
    }
    
    func updateValues () {
        locationLabel.text = spot?.name
        
        if self.spot != nil {
            switch self.spot!.currentlyActiveRule.ruleType {
            case .Paid:
                let interval = self.spot!.currentlyActiveRuleEndTime
                logoView.image = UIImage(named: "icon_checkin_metered")
                availableTitleLabel.text = "pay_reminder".localizedString.uppercaseString
                
                let smallFont = Styles.FontFaces.regular(16)
                let bigFont = Styles.Fonts.h2r
                
                let attributedString = NSMutableAttributedString(string: "$", attributes: [NSFontAttributeName: smallFont])
                let number = NSMutableAttributedString(string: self.spot!.currentlyActiveRule.paidHourlyRateString, attributes: [NSFontAttributeName: bigFont])
                let perHour = NSMutableAttributedString(string: "/H", attributes: [NSFontAttributeName: smallFont])
                let space = NSMutableAttributedString(string: " • ", attributes: [NSFontAttributeName: bigFont])
                let until = interval.untilAttributedString(bigFont, secondPartFont: smallFont)
                
                attributedString.appendAttributedString(number)
                attributedString.appendAttributedString(perHour)
                attributedString.appendAttributedString(space)
                attributedString.appendAttributedString(until)
                
                availableTimeLabel.attributedText = attributedString
                
                break
            default:
                logoView.image = UIImage(named: "icon_checkin")
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
                break
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
        
        checkinMessageVC!.view.snp_makeConstraints({ (make) -> () in
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
        
        createGoogleMapsLink(spot!.buttonLocation)
    }
    
    func createGoogleMapsLink(location : CLLocation) {
        let latitude = "\(spot!.buttonLocation.coordinate.latitude)"
        let longitude = "\(spot!.buttonLocation.coordinate.longitude)"
        let longUrlString = "http://maps.google.com/maps?q=" + latitude + "," + longitude + "&ll=" + latitude + "," + longitude + "&z=17"

        request(Method.POST, "https://www.googleapis.com/urlshortener/v1/url?key=AIzaSyBVSdiMcYO1qpJIMbcOV9ATgWpSxsGvc1M", parameters: ["longUrl": longUrlString], encoding: ParameterEncoding.JSON).responseSwiftyJSON { (request, response, json, error) -> Void in
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
        var text : String = "share_location_copy".localizedString
        text = text.stringByReplacingOccurrencesOfString("[street_name]", withString: spot!.name)
        text += "\n--\n" + url
        let activityViewController = UIActivityViewController( activityItems: [text], applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    func leaveButtonTapped() {
        
        Settings.checkOut()
        self.delegate?.reloadMyCarTab()
    }
    
    func reportButtonTapped(sender: UIButton) {
        loadReportScreen(self.spot?.identifier)
    }
    
    func setDefaultTimeDisplay() {
        
        if self.spot != nil {
            switch self.spot!.currentlyActiveRule.ruleType {
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
        var fadeAnimation = CATransition()
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
            self.delegate?.showSpotOnMap(parkingSpot)
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
            // Slide in buttons once container fully visible
            let buttonSlideAnimation = POPBasicAnimation(propertyNamed: kPOPLayerTranslationY)
            buttonSlideAnimation.fromValue = NSNumber(float: Float(self.BUTTONS_TRANSLATION_X))
            buttonSlideAnimation.toValue = NSNumber(int: 0)
            buttonSlideAnimation.duration = 0.2
            self.bigButtonContainer.layer.pop_addAnimation(buttonSlideAnimation, forKey: "buttonSlideAnimation")
        }
        self.containerView.layer.pop_addAnimation(containerFadeInAnimation, forKey: "containerFadeInAnimation")

        
        let smallButtonsFadeInAnimation = POPBasicAnimation(propertyNamed: kPOPLayerOpacity)
        smallButtonsFadeInAnimation.fromValue = NSNumber(int: 0)
        smallButtonsFadeInAnimation.toValue = NSNumber(int: 1)
        smallButtonsFadeInAnimation.duration = 0.3
        smallButtonsFadeInAnimation.beginTime = CACurrentMediaTime() + 0.3
        self.smallButtonContainer.layer.pop_addAnimation(smallButtonsFadeInAnimation, forKey: "smallButtonsFadeInAnimation")
    }
    
}


protocol MyCarCheckedInViewControllerDelegate {
    func reloadMyCarTab()
    func showSpotOnMap(spot: ParkingSpot)
}
