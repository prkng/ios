//
//  MyCarCheckedInViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 15/05/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class MyCarReservedCarShareViewController: MyCarAbstractViewController, UIGestureRecognizerDelegate, POPAnimationDelegate {
    
    var carShare: CarShare?
    
    var backgroundImageView: UIImageView

//    var shareButton: UIButton

    var logoView: UIImageView
    
    var containerView: UIView
    var locationTitleLabel: UILabel
    var locationLabel: UILabel
    
    var availableTitleLabel: UILabel
    var availableTimeLabel: UILabel //ex: 24+
    
    var bigButtonContainer: UIView
    var mapButton: UIButton
    var leaveButton: UIButton
    
    var delegate: MyCarAbstractViewControllerDelegate?
    
    private var timer: NSTimer?
    
    private let SMALL_VERTICAL_MARGIN = 5
    private let MEDIUM_VERTICAL_MARGIN = 10
    private let LARGE_VERTICAL_MARGIN = 20
    
    private var smallerVerticalMargin: Int = 0
    private var largerVerticalMargin: Int = 0

    private let BUTTONS_TRANSLATION_X = CGFloat(2*36 + 20 + 14)
    
    let BOTTOM_BUTTON_HEIGHT: CGFloat = 36

    init() {
        
        backgroundImageView = UIImageView(image: UIImage(named:"bg_mycar"))

//        shareButton = ViewFactory.shareButton()

        logoView = UIImageView()
        
        containerView = UIView()
        
        locationTitleLabel = ViewFactory.formLabel()
        locationLabel = ViewFactory.bigMessageLabel()
        
        availableTitleLabel = ViewFactory.formLabel()
        availableTimeLabel = UILabel()
        
        bigButtonContainer = UIView()
        mapButton = ViewFactory.roundedButtonWithHeight(BOTTOM_BUTTON_HEIGHT, backgroundColor: Styles.Colors.stone, font: Styles.FontFaces.regular(12), text: "show_the_map".localizedString.uppercaseString, textColor: Styles.Colors.petrol2, highlightedTextColor: Styles.Colors.petrol1)
        leaveButton = ViewFactory.redRoundedButtonWithHeight(BOTTOM_BUTTON_HEIGHT, font: Styles.FontFaces.regular(12), text: "cancel".localizedString.uppercaseString)
        
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
        self.screenName = "My Car - Reserved Car Share"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if (carShare == nil) {
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
        
        
        if (carShare == nil) {
            
            let setCarShare = {(carShare: CarShare?) -> () in
                self.carShare = carShare
                self.setDefaultTimeDisplay()
                SVProgressHUD.dismiss()
                if (carShare != nil) {
                    
                    if #available(iOS 8.0, *) {
                        self.animateAndShow()
                    }
                    
                }
            }
            
            if let reservedCarShare = Settings.getReservedCarShare() {
                setCarShare(reservedCarShare)
            }
            
        } else {
            self.updateValues()
        }
        

    }
    
    
    func setupViews () {
        
        backgroundImageView.contentMode = .ScaleAspectFill
        view.addSubview(backgroundImageView)
        
        segmentedControl.setPressedHandler(segmentedControlTapped)
        self.view.addSubview(segmentedControl)
        
//        shareButton.addTarget(self, action: "shareButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
//        self.view.addSubview(shareButton)

        logoView.image = UIImage(named: "icon_carshare")
        view.addSubview(logoView)
        
        view.addSubview(containerView)
        
        locationTitleLabel.text = "reserved_car_share_message".localizedString.uppercaseString
        containerView.addSubview(locationTitleLabel)
        
        locationLabel.text = "PRKNG"
        containerView.addSubview(locationLabel)
        
        containerView.addSubview(availableTitleLabel)
        
        availableTimeLabel.textColor = Styles.Colors.red2
        availableTimeLabel.text = "0:00"
        availableTimeLabel.textAlignment = NSTextAlignment.Center
        containerView.addSubview(availableTimeLabel)
        
        view.addSubview(bigButtonContainer)
        
        mapButton.addTarget(self, action: "mapButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        bigButtonContainer.addSubview(mapButton)

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
            make.size.equalTo(CGSize(width: 120, height: 20))
            make.top.equalTo(self.snp_topLayoutGuideBottom).offset(30)
            make.centerX.equalTo(self.view)
        }
        
//        shareButton.snp_makeConstraints { (make) -> Void in
//            make.top.equalTo(self.snp_topLayoutGuideBottom).offset(30)
//            make.centerY.equalTo(self.segmentedControl)
//            make.right.equalTo(self.view).offset(-50)
//        }
        
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
        
        mapButton.snp_makeConstraints { (make) -> () in
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
    }
    
    func updateValues () {
        locationLabel.text = (carShare?.carSharingType.name ?? "") + " - " + (carShare?.name ?? "")
        
        if self.carShare != nil {
            logoView.image = UIImage(named: "icon_carshare")
            let interval = Settings.getReservedCarShareTime()?.timeIntervalSinceNow ?? 0
            availableTimeLabel.text = String(Int(interval / 60)) + " minutes".localizedString
            availableTimeLabel.font = Styles.Fonts.h1r
        }
        
        //update the values every 2 seconds
        if self.timer == nil {
            self.timer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "updateValues", userInfo: nil, repeats: true)
        }
        
    }
    
    func mapButtonTapped() {
        self.delegate?.loadHereTab()
    }

    func leaveButtonTapped() {
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.send(GAIDictionaryBuilder.createEventWithCategory("My Car - Reserved Car Share", action: "Cancel Button Tapped", label: nil, value: nil).build() as [NSObject: AnyObject])

        CarSharingOperations.cancelCarShare(self.carShare!, fromVC: self, completion: { (completed) -> Void in
            if completed {
                self.delegate?.reloadMyCarTab()
            }
        })
    }
    
    func reportButtonTapped(sender: UIButton) {
        
    }

    
    func setDefaultTimeDisplay() {
        
        if self.carShare != nil {
            availableTitleLabel.text = "available_for".localizedString.uppercaseString
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
        
    }
    
    func showSpotOnMap() {
        
//        if let parkingSpot = self.spot {
//            self.delegate?.showSpotOnMap(parkingSpot)
//        }
    }
    
    func handleSingleTap(recognizer: UITapGestureRecognizer) {
        
//        let tap = recognizer.locationInView(self.view)
//        let point = availableTitleLabel.convertPoint(availableTitleLabel.bounds.origin, toView: self.view)
//        let pointY = point.y - CGFloat(largerVerticalMargin)/2
//        
//        if tap.y > pointY {
//            toggleTimeDisplay()
//        } else {
//            showSpotOnMap()
//        }
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
//            // Slide in buttons once container fully visible
//            let buttonSlideAnimation = POPBasicAnimation(propertyNamed: kPOPLayerTranslationY)
//            buttonSlideAnimation.fromValue = NSNumber(float: Float(self.BUTTONS_TRANSLATION_X))
//            buttonSlideAnimation.toValue = NSNumber(int: 0)
//            buttonSlideAnimation.duration = 0.2
//            self.bigButtonContainer.layer.pop_addAnimation(buttonSlideAnimation, forKey: "buttonSlideAnimation")
        }
        self.containerView.layer.pop_addAnimation(containerFadeInAnimation, forKey: "containerFadeInAnimation")

    }
    
}
