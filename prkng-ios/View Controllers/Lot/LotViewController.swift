//
//  LotViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-09-02.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class LotViewController: PRKModalDelegatedViewController, ModalHeaderViewDelegate, PRKVerticalGestureRecognizerDelegate {
    
//    var delegate : PRKModalViewControllerDelegate?
    var lot : Lot
    var parentView: UIView
    
    override var topParallaxView: UIView? { get {
        return topImageView
        }
    }
    
    private var topImageView = GMSPanoramaView(frame: CGRectZero)
    private var topGradient = UIImageView()
    private var directionsButton = ViewFactory.directionsButton()
    private var topLabel = UILabel()
    private var headerView: ModalHeaderView
    private var subHeaderView = UIView()
    private var subHeaderViewLabel = PRKTimeSpanView()
    private var todayTimeHeaderView = UIView()
    private var timeIconView = UIImageView(image: UIImage(named: "icon_time_thin"))
    private var timeListContentView = UIView()
    private var timeSpanLabels = [PRKTimeSpanView]()
    private var attributesView = UIView()
    private var attributesViewContainers = [UIView]()
    private var attributesViewLabels = [UILabel]()
    private var attributesViewImages = [UIImageView]()

    private var verticalRec: PRKVerticalGestureRecognizer
    private static let HEADER_HEIGHT: CGFloat = 70
    private(set) var LIST_HEIGHT: Int = 185
    private(set) var SCROLL_HEIGHT: Int = UIScreen.mainScreen().bounds.width == 320 ? 185 / 2 : 185
    var topOffset: Int = 0 {
        didSet {
            if topOffset > TOP_OFFSET_MAX {
                topOffset = TOP_OFFSET_MAX
            }
            if topOffset < 0 {
                topOffset = 0
            }
        }
    }
    private(set) var TOP_OFFSET_MAX: Int = UIScreen.mainScreen().bounds.width == 320 ? 185 / 2 : 0
    private var swipeBeganWithListAt: Int = 0
    
    init(lot: Lot, view: UIView) {
        self.lot = lot
        self.parentView = view
        headerView = ModalHeaderView()
        verticalRec = PRKVerticalGestureRecognizer()
        super.init(nibName: nil, bundle: nil)

        self.TOP_PARALLAX_HEIGHT = UIScreen.mainScreen().bounds.height - (LotViewController.HEADER_HEIGHT + 30 + 50 + 52) - CGFloat(Styles.Sizes.tabbarHeight)
        self.TOP_PARALLAX_HEIGHT -= CGFloat(self.SCROLL_HEIGHT)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        headerView.topText = lot.headerText
        headerView.rightViewTitleLabel.text = "daily".localizedString.uppercaseString
        headerView.rightViewPrimaryLabel.attributedText = lot.bottomLeftPrimaryText
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func loadView() {
        self.view = UIView()
        setupViews()
        setupConstraints()
    }
    
    func setupViews() {
        
        view.addSubview(topImageView)
        topImageView.navigationLinksHidden = true
        if lot.streetViewPanoramaId == nil {
            topImageView.moveNearCoordinate(lot.coordinate)
        } else {
            topImageView.moveToPanoramaID(lot.streetViewPanoramaId!)
        }
        if let heading = lot.streetViewHeading {
            let cameraUpdate = GMSPanoramaCameraUpdate.setHeading(CGFloat(heading))
            topImageView.updateCamera(cameraUpdate, animationDuration: 0.2)
        }
        let cameraUpdate = GMSPanoramaCameraUpdate.setZoom(3)
        topImageView.updateCamera(cameraUpdate, animationDuration: 0.2)

        
        view.addSubview(topGradient)
        topGradient.image = UIImage.imageFromGradient(CGSize(width: self.FULL_WIDTH, height: 65.0), fromColor: UIColor.clearColor(), toColor: UIColor.blackColor().colorWithAlphaComponent(0.9))
        
        let operatedByString = NSMutableAttributedString(string: "operated_by".localizedString + " ", attributes: [NSFontAttributeName: Styles.FontFaces.light(12)])
        let operatorString = NSMutableAttributedString(string: lot.lotOperator, attributes: [NSFontAttributeName: Styles.FontFaces.regular(12)])
        operatedByString.appendAttributedString(operatorString)
        view.addSubview(topLabel)
        topLabel.textColor = Styles.Colors.cream1
        topLabel.attributedText = operatedByString
        
        directionsButton.addTarget(self, action: "directionsButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(directionsButton)
        
        view.addSubview(headerView)
        headerView.showsRightButton = false
        headerView.delegate = self
        headerView.clipsToBounds = true
        
        view.addSubview(subHeaderView)
        subHeaderView.backgroundColor = Styles.Colors.lipstick
        
        subHeaderView.addSubview(subHeaderViewLabel)
        subHeaderViewLabel.leftLabel.text = String(format: "capacity_x_places".localizedString, lot.capacity)
        subHeaderViewLabel.leftLabel.font = Styles.FontFaces.regular(11)
        subHeaderViewLabel.leftLabel.textColor = Styles.Colors.cream1

        let currencyString = NSMutableAttributedString(string: "$" + String(Int(lot.hourlyRate)), attributes: [NSFontAttributeName: Styles.FontFaces.regular(14)])
        let numberString = NSMutableAttributedString(string: "/" + "hour".localizedString.uppercaseString, attributes: [NSFontAttributeName: Styles.FontFaces.regular(11)])
        currencyString.appendAttributedString(numberString)
        subHeaderViewLabel.rightLabel.attributedText = currencyString
        subHeaderViewLabel.rightLabel.textColor = Styles.Colors.cream1

        
        timeIconView.image = timeIconView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        timeIconView.tintColor = Styles.Colors.midnight1
        
        let todayTimeHeaderTapRec = UITapGestureRecognizer(target: self, action: "timesTapped")
        todayTimeHeaderView.addGestureRecognizer(todayTimeHeaderTapRec)
        view.addSubview(todayTimeHeaderView)
        todayTimeHeaderView.backgroundColor = Styles.Colors.cream1
        todayTimeHeaderView.addSubview(timeIconView)

        let openTimes = lot.openTimes(true)
        let days = DateUtil.sortedDays()
        
        let todayTimeSpanLabel = PRKTimeSpanView(dayString: days[0], startTime: openTimes[0].0, endTime: openTimes[0].1)
        timeSpanLabels.append(todayTimeSpanLabel)
        todayTimeHeaderView.addSubview(todayTimeSpanLabel)
        
        let timeListTapRec = UITapGestureRecognizer(target: self, action: "timesTapped")
        timeListContentView.addGestureRecognizer(timeListTapRec)
        timeListContentView.backgroundColor = Styles.Colors.stone
        view.addSubview(timeListContentView)

        for i in 1..<7 {
            let timeSpanLabel = PRKTimeSpanView(dayString: days[i], startTime: openTimes[i].0, endTime: openTimes[i].1)
            timeSpanLabels.append(timeSpanLabel)
            timeListContentView.addSubview(timeSpanLabel)
        }
        
        for attribute in lot.attributes {
            
            let attributesViewContainer = UIView()
            attributesViewContainers.append(attributesViewContainer)
            
            let caption = attribute.name(false).localizedString.uppercaseString
            let imageName = "icon_" + attribute.name(true) + (attribute.enabled ? "_on" : "_off" )
            
            let attributeLabel = UILabel()
            attributeLabel.text = caption
            attributeLabel.textColor = attribute.showAsEnabled ? Styles.Colors.petrol2 : Styles.Colors.greyish
            attributeLabel.font = Styles.FontFaces.regular(9)
            attributesViewLabels.append(attributeLabel)
            
            let attributeImageView = UIImageView(image: UIImage(named: imageName)!)
            attributeImageView.contentMode = .Bottom
            attributesViewImages.append(attributeImageView)
            
            attributesViewContainer.addSubview(attributeLabel)
            attributesViewContainer.addSubview(attributeImageView)
            attributesView.addSubview(attributesViewContainer)
        }
        
        view.addSubview(attributesView)
        attributesView.backgroundColor = Styles.Colors.stone
        
        verticalRec = PRKVerticalGestureRecognizer(view: self.view, superViewOfView: self.parentView)
        verticalRec.delegate = self
        
        view.bringSubviewToFront(headerView)
        
    }
    
    func setupConstraints() {
        
        topImageView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(self.TOP_PARALLAX_HEIGHT)
        }
        
        topGradient.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.headerView.snp_top)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(65)
        }
        
        topLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.view).offset(34)
            make.bottom.equalTo(self.headerView.snp_top).offset(-24)
        }
        
        directionsButton.snp_makeConstraints { (make) -> () in
            make.right.equalTo(self.view).offset(-30)
            make.bottom.equalTo(self.headerView.snp_top).offset(-16)
        }
        
        
        headerView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view).offset(self.TOP_PARALLAX_HEIGHT)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(LotViewController.HEADER_HEIGHT)
        }
        
        subHeaderView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.headerView.snp_bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(30)
        }

        subHeaderViewLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.subHeaderView).offset(34)
            make.right.equalTo(self.subHeaderView).offset(-40)
            make.centerY.equalTo(self.subHeaderView)
        }
        
        todayTimeHeaderView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.subHeaderView.snp_bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(50)
        }
        
        timeIconView.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.todayTimeHeaderView).offset(34)
            make.centerY.equalTo(self.todayTimeHeaderView)
        }
        
        timeListContentView.snp_makeConstraints { (make) -> () in
            make.height.equalTo(self.LIST_HEIGHT)
            make.top.equalTo(self.todayTimeHeaderView.snp_bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        timeSpanLabels[0].snp_makeConstraints(closure: { (make) -> () in
            make.left.equalTo(self.todayTimeHeaderView).offset(66.5)
            make.right.equalTo(self.todayTimeHeaderView).offset(-40)
            make.centerY.equalTo(self.todayTimeHeaderView)
        })

        var topConstraint = self.timeListContentView.snp_top
        for i in 1..<7 {
            let timeSpanLabel = timeSpanLabels[i]
            let listTopOffset = i == 1 ? 14 : 10
            timeSpanLabel.snp_makeConstraints(closure: { (make) -> () in
                make.top.equalTo(topConstraint).offset(listTopOffset)
                make.left.equalTo(self.timeListContentView).offset(34)
                make.right.equalTo(self.timeListContentView).offset(-40)
            })
            topConstraint = timeSpanLabel.snp_bottom
        }

        
        attributesView.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.view.snp_bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(52)
        }

        //the below is a little overly complicated, to make it much simpler just debug the view hierarchy and you will easily see how/where things are aligned.
        var leftConstraint = self.attributesView.snp_left
        
        for i in 0..<attributesViewContainers.count {
            
            var width = Int(self.FULL_WIDTH)/3
            if i == 1 || i == 2 {
                width = Int(self.FULL_WIDTH)/6
            }
            
            let attributesViewContainer = attributesViewContainers[i]
            attributesViewContainer.snp_makeConstraints(closure: { (make) -> () in
                make.left.equalTo(leftConstraint)
                make.top.equalTo(self.attributesView)
                make.bottom.equalTo(self.attributesView)
                make.width.equalTo(width)
            })
            
            let label = attributesViewLabels[i]

            if i == 1 {
                label.snp_makeConstraints(closure: { (make) -> () in
                    make.left.equalTo(attributesViewContainer.snp_left)
                    make.bottom.equalTo(self.attributesView).offset(-4.5)
                })
            } else if i == 2 {
                label.snp_makeConstraints(closure: { (make) -> () in
                    make.right.equalTo(attributesViewContainer.snp_right)
                    make.bottom.equalTo(self.attributesView).offset(-4.5)
                })
            } else {
                label.snp_makeConstraints(closure: { (make) -> () in
                    make.centerX.equalTo(attributesViewContainer.snp_centerX)
                    make.bottom.equalTo(self.attributesView).offset(-4.5)
                })
            }
            
            let imageView = attributesViewImages[i]
            imageView.snp_makeConstraints(closure: { (make) -> () in
                make.size.equalTo(CGSize(width: 21, height: 25))
                make.centerX.equalTo(label.snp_centerX)
                make.bottom.equalTo(label.snp_top).offset(-3.5)
            })
            
            leftConstraint = attributesViewContainer.snp_right
        }

        
    }
    
    //MARK: Helper methods
    
    func directionsButtonTapped(sender: UIButton) {
        
        let coordinateString = String(stringInterpolationSegment: self.lot.coordinate.latitude) + "," + String(stringInterpolationSegment: self.lot.coordinate.longitude)
        
        let appleMapsURLString = "http://maps.apple.com/?saddr=Current%20Location&daddr=" + coordinateString
        
        let googleMapsURLString = "comgooglemaps-x-callback://?saddr=&daddr=" + coordinateString + "&x-success=ng.prk.prkng-ios://?returningFromGoogleMaps=true&x-source=Prkng"

        let supportsGoogleMaps = UIApplication.sharedApplication().canOpenURL(NSURL(string: "comgooglemaps://")!)
        
        if supportsGoogleMaps {

            if #available(iOS 8.0, *) {
                let alert = UIAlertController(title: "directions".localizedString, message: "directions_app_message".localizedString, preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "directions_google_maps_message".localizedString, style: .Default, handler: { (alert) -> Void in
                    UIApplication.sharedApplication().openURL(NSURL(string: googleMapsURLString)!)
                }))
                alert.addAction(UIAlertAction(title: "directions_apple_maps_message".localizedString, style: .Default, handler: { (alert) -> Void in
                    UIApplication.sharedApplication().openURL(NSURL(string: appleMapsURLString)!)
                }))
                alert.addAction(UIAlertAction(title: "cancel".localizedString, style: .Cancel, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                // Fallback on earlier versions
                //TODO: PUT SOMETHING HERE FOR IOS 7
            }

        } else {

            UIApplication.sharedApplication().openURL(NSURL(string: appleMapsURLString)!)

        }
    }
    
    
    //MARK: ModalHeaderViewDelegate
    
    func tappedBackButton() {
        self.delegate?.hideModalView()
    }
    
    func tappedRightButton() {
        tappedBackButton()
    }
    
    
    //MARK: PRKVerticalGestureRecognizerDelegate methods
    
    func shouldIgnoreSwipe(beginTap: CGPoint) -> Bool {
        let yPosition = self.TOP_PARALLAX_HEIGHT - CGFloat(self.topOffset)
        return beginTap.y <= yPosition
    }

    func swipeDidBegin() {
        self.swipeBeganWithListAt = self.topOffset
    }
    
    func swipeInProgress(yDistanceFromBeginTap: CGFloat) {
//        NSLog("Swipe in progress with distance: %f, list began at: %d, top offset: %d", yDistanceFromBeginTap, self.swipeBeganWithListAt, self.topOffset)
        
        if yDistanceFromBeginTap < 0 {
            //if yDistanceFromBeginTap < 0 then we're moving down

            if self.topOffset != 0 {
                //then our swipe down should compress the list
                self.topOffset = self.TOP_OFFSET_MAX + Int(yDistanceFromBeginTap)
//                NSLog("swiping down, top offset is now %d", self.topOffset)
                adjustTopOffsetForTimeList(false)
            } else {
                
                //if we started off with a not-fully-expanded list, then we shouldn't auto-close this.
                if self.swipeBeganWithListAt != 0 {
                    return
                }
                
//                NSLog("swiping down, top offset is STILL %d", self.topOffset)
                
                let newYDistanceFromBeginTap = CGFloat(swipeBeganWithListAt) + yDistanceFromBeginTap

                self.delegate?.shouldAdjustTopConstraintWithOffset(-newYDistanceFromBeginTap, animated: false)
                
                //parallax for the top image/street view!
                let topViewOffset = (-newYDistanceFromBeginTap / self.FULL_HEIGHT) * self.TOP_PARALLAX_HEIGHT
                topImageView.snp_updateConstraints { (make) -> () in
                    make.top.equalTo(self.view).offset(topViewOffset)
                }
                topImageView.layoutIfNeeded()
            }
        } else if self.topOffset != self.TOP_OFFSET_MAX {
//            NSLog("swiping up, top offset is now %d", self.topOffset)
            
            //else we're moving up. Expand the list
            self.topOffset = Int(yDistanceFromBeginTap)
            adjustTopOffsetForTimeList(false)
        }
        
    }
    
    func swipeDidEndUp() {
        
        self.topOffset = self.TOP_OFFSET_MAX
        adjustTopOffsetForTimeList(true)
        
        self.delegate?.shouldAdjustTopConstraintWithOffset(0, animated: true)
        
        //fix parallax effect just in case
        self.topParallaxView?.snp_updateConstraints { (make) -> () in
            make.top.equalTo(self.view).offset(-self.topOffset)
        }
        UIView.animateWithDuration(0.2,
            animations: { () -> Void in
                self.topParallaxView?.updateConstraints()
            },
            completion: nil
        )
        
    }
    
    func swipeDidEndDown() {
        if self.swipeBeganWithListAt != 0 {
            self.topOffset = 0
            adjustTopOffsetForTimeList(true)
        } else {
            self.delegate?.hideModalView()
        }
    }

    func timesTapped() {
        self.topOffset = self.topOffset == 0 ? self.LIST_HEIGHT - self.SCROLL_HEIGHT : 0
        adjustTopOffsetForTimeList(true)
    }
    
    func adjustTopOffsetForTimeList(animate: Bool) {
        
        topImageView.snp_updateConstraints { (make) -> () in
            make.top.equalTo(self.view).offset(-self.topOffset)
        }
        
        self.headerView.snp_updateConstraints { (make) -> () in
            make.top.equalTo(self.view).offset(self.TOP_PARALLAX_HEIGHT - CGFloat(self.topOffset))
        }
        
        self.view.setNeedsLayout()
        if animate {
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        } else {
            self.view.layoutIfNeeded()
        }

    }
    
    
}
