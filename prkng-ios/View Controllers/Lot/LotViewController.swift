//
//  LotViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-09-02.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit
import GoogleMaps

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
    private var timeListScrollView = UIScrollView()
    private var timeListContentView = UIView()
    private var timeSpanLabels = [PRKTimeSpanView]()
    private var attributesView = UIView()
    private var attributesViewLabels = [UILabel]()
    private var attributesViewImages = [UIImageView]()

    private var verticalRec: PRKVerticalGestureRecognizer
    private static let HEADER_HEIGHT: CGFloat = 70
    private(set) var LIST_HEIGHT: Int = 185
    private(set) var SCROLL_HEIGHT: Int = UIScreen.mainScreen().bounds.width == 320 ? 185 / 2 : 185
    
    init(lot: Lot, view: UIView) {
        self.lot = lot
        self.parentView = view
        headerView = ModalHeaderView()
        verticalRec = PRKVerticalGestureRecognizer()
        super.init(nibName: nil, bundle: nil)

        self.TOP_PARALLAX_HEIGHT = UIScreen.mainScreen().bounds.height - (LotViewController.HEADER_HEIGHT + 30 + 50 + 52) - CGFloat(Styles.Sizes.tabbarHeight)
        self.TOP_PARALLAX_HEIGHT -= CGFloat(self.SCROLL_HEIGHT)
    }
    
    required init(coder aDecoder: NSCoder) {
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
        topImageView.moveNearCoordinate(lot.coordinate)
        
        view.addSubview(topGradient)
        topGradient.image = UIImage.imageFromGradient(CGSize(width: self.FULL_WIDTH, height: 65.0), fromColor: UIColor.clearColor(), toColor: UIColor.blackColor().colorWithAlphaComponent(0.9))
        
        var operatedByString = NSMutableAttributedString(string: "operated_by".localizedString + " ", attributes: [NSFontAttributeName: Styles.FontFaces.light(12)])
        var operatorString = NSMutableAttributedString(string: lot.lotOperator, attributes: [NSFontAttributeName: Styles.FontFaces.regular(12)])
        operatedByString.appendAttributedString(operatorString)
        view.addSubview(topLabel)
        topLabel.textColor = Styles.Colors.cream1
        topLabel.attributedText = operatedByString
        
        directionsButton.addTarget(self, action: "directionsButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(directionsButton)
        
        view.addSubview(headerView)
        headerView.showsRightButton = false
        headerView.delegate = self
        
        view.addSubview(subHeaderView)
        subHeaderView.backgroundColor = Styles.Colors.lipstick
        
        subHeaderView.addSubview(subHeaderViewLabel)
        subHeaderViewLabel.leftLabel.text = String(format: "capacity_x_places".localizedString, lot.capacity)
        subHeaderViewLabel.leftLabel.font = Styles.FontFaces.regular(11)
        subHeaderViewLabel.leftLabel.textColor = Styles.Colors.cream1

        var currencyString = NSMutableAttributedString(string: "$" + String(Int(lot.hourlyRate)), attributes: [NSFontAttributeName: Styles.FontFaces.regular(14)])
        var numberString = NSMutableAttributedString(string: "/" + "hour".localizedString.uppercaseString, attributes: [NSFontAttributeName: Styles.FontFaces.regular(11)])
        currencyString.appendAttributedString(numberString)
        subHeaderViewLabel.rightLabel.attributedText = currencyString
        subHeaderViewLabel.rightLabel.textColor = Styles.Colors.cream1

        
        timeIconView.image = timeIconView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        timeIconView.tintColor = Styles.Colors.midnight1
        
        view.addSubview(todayTimeHeaderView)
        todayTimeHeaderView.backgroundColor = Styles.Colors.cream1
        todayTimeHeaderView.addSubview(timeIconView)

        let openTimes = lot.openTimes(true)
        let days = DateUtil.sortedDays()
        
        let todayTimeSpanLabel = PRKTimeSpanView(dayString: days[0], startTime: openTimes[0].0, endTime: openTimes[0].1)
        timeSpanLabels.append(todayTimeSpanLabel)
        todayTimeHeaderView.addSubview(todayTimeSpanLabel)
        
        view.addSubview(timeListScrollView)
        timeListScrollView.backgroundColor = Styles.Colors.stone
        timeListScrollView.addSubview(timeListContentView)

        for i in 1..<7 {
            let timeSpanLabel = PRKTimeSpanView(dayString: days[i], startTime: openTimes[i].0, endTime: openTimes[i].1)
            timeSpanLabels.append(timeSpanLabel)
            timeListContentView.addSubview(timeSpanLabel)
        }
        
        for attribute in lot.attributes {
            let caption = attribute.name(false).localizedString.uppercaseString
            let imageName = "icon_" + attribute.name(true) + (attribute.enabled ? "_on" : "_off" )
            
            let attributeLabel = UILabel()
            attributeLabel.text = caption
            attributeLabel.textColor = attribute.enabled ? Styles.Colors.petrol2 : Styles.Colors.greyish
            attributeLabel.font = Styles.FontFaces.regular(9)
            attributesViewLabels.append(attributeLabel)
            
            let attributeImageView = UIImageView(image: UIImage(named: imageName)!)
            attributeImageView.contentMode = .Bottom
            attributesViewImages.append(attributeImageView)
            
            attributesView.addSubview(attributeLabel)
            attributesView.addSubview(attributeImageView)
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
            make.left.equalTo(self.view).with.offset(34)
            make.bottom.equalTo(self.headerView.snp_top).with.offset(-24)
        }
        
        directionsButton.snp_makeConstraints { (make) -> () in
            make.right.equalTo(self.view).with.offset(-30)
            make.bottom.equalTo(self.headerView.snp_top).with.offset(-16)
        }
        
        
        headerView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view).with.offset(self.TOP_PARALLAX_HEIGHT)
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
            make.left.equalTo(self.subHeaderView).with.offset(34)
            make.right.equalTo(self.subHeaderView).with.offset(-40)
            make.centerY.equalTo(self.subHeaderView)
        }
        
        todayTimeHeaderView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.subHeaderView.snp_bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(50)
        }
        
        timeIconView.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.todayTimeHeaderView).with.offset(34)
            make.centerY.equalTo(self.todayTimeHeaderView)
        }
        
        timeListScrollView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.todayTimeHeaderView.snp_bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(self.SCROLL_HEIGHT)
        }
        
        timeListContentView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.timeListScrollView)
            make.width.equalTo(self.view)
            make.height.equalTo(self.LIST_HEIGHT)
        }
        
        timeSpanLabels[0].snp_makeConstraints({ (make) -> () in
            make.left.equalTo(self.todayTimeHeaderView).with.offset(66.5)
            make.right.equalTo(self.todayTimeHeaderView).with.offset(-40)
            make.centerY.equalTo(self.todayTimeHeaderView)
        })

        var topConstraint = self.timeListContentView.snp_top
        for i in 1..<7 {
            let timeSpanLabel = timeSpanLabels[i]
            let topOffset = i == 1 ? 14 : 10
            timeSpanLabel.snp_makeConstraints({ (make) -> () in
                make.top.equalTo(topConstraint).with.offset(topOffset)
                make.left.equalTo(self.timeListContentView).with.offset(34)
                make.right.equalTo(self.timeListContentView).with.offset(-40)
            })
            topConstraint = timeSpanLabel.snp_bottom
        }

        
        attributesView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.timeListScrollView.snp_bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(52)
        }

        for i in 0..<attributesViewImages.count {
            
            let multiplier: Float = 2.0 * Float(i + 1) / (Float(attributesViewImages.count + 1) )  // MAGIC =)
            
            let label = attributesViewLabels[i]
            label.snp_makeConstraints({ (make) -> () in
                make.centerX.equalTo(self.attributesView).multipliedBy(multiplier)
                make.bottom.equalTo(self.attributesView).with.offset(-4.5)
            })
            
            let imageView = attributesViewImages[i]
            imageView.snp_makeConstraints({ (make) -> () in
                make.size.equalTo(CGSize(width: 21, height: 25))
                make.centerX.equalTo(self.attributesView).multipliedBy(multiplier)
                make.bottom.equalTo(label.snp_top).with.offset(-3.5)
            })

        }
        
        
    }
    
    //MARK: Helper methods
    
    func directionsButtonTapped(sender: UIButton) {
        
        let coordinateString = String(stringInterpolationSegment: self.lot.coordinate.latitude) + "," + String(stringInterpolationSegment: self.lot.coordinate.longitude)
        
        let appleMapsURLString = "http://maps.apple.com/?saddr=Current%20Location&daddr=" + coordinateString
        
//        let googleMapsURLStringWithSucessCallback = "comgooglemaps-x-callback://?saddr=&daddr=" + coordinateString + "&x-success=prkng://?resumeAfterNavWithCoordinate" + coordinateString + "&x-source=Prkng"
        let googleMapsURLString = "comgooglemaps-x-callback://?saddr=&daddr=" + coordinateString + "&x-source=Prkng"

        let supportsGoogleMaps = UIApplication.sharedApplication().canOpenURL(NSURL(string: "comgooglemaps://")!)
        
        if supportsGoogleMaps {

            var alert = UIAlertController(title: "directions".localizedString, message: "directions_app_message".localizedString, preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "directions_google_maps_message".localizedString, style: .Default, handler: { (alert) -> Void in
                UIApplication.sharedApplication().openURL(NSURL(string: googleMapsURLString)!)
            }))

            alert.addAction(UIAlertAction(title: "directions_apple_maps_message".localizedString, style: .Default, handler: { (alert) -> Void in
                UIApplication.sharedApplication().openURL(NSURL(string: appleMapsURLString)!)
            }))

            alert.addAction(UIAlertAction(title: "cancel".localizedString, style: .Cancel, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)

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
        return beginTap.y <= self.TOP_PARALLAX_HEIGHT
    }

    func swipeDidBegin() {
        
    }
    
    func swipeInProgress(yDistanceFromBeginTap: CGFloat) {
        if yDistanceFromBeginTap < 0 {
            self.delegate?.shouldAdjustTopConstraintWithOffset(-yDistanceFromBeginTap, animated: false)

            //parallax for the top image/street view!
            let topViewOffset = (-yDistanceFromBeginTap / self.FULL_HEIGHT) * self.TOP_PARALLAX_HEIGHT
            topImageView.snp_updateConstraints { (make) -> () in
                make.top.equalTo(self.view).with.offset(topViewOffset)
            }
            topImageView.layoutIfNeeded()
        }
    }
    
    func swipeDidEndUp() {
        self.delegate?.shouldAdjustTopConstraintWithOffset(0, animated: true)
        
        //fix parallax effect just in case
        self.topParallaxView?.snp_updateConstraints { (make) -> () in
            make.top.equalTo(self.view)
        }
        UIView.animateWithDuration(0.2,
            animations: { () -> Void in
                self.topParallaxView?.updateConstraints()
            },
            completion: nil
        )


    }
    
    func swipeDidEndDown() {
        self.delegate?.hideModalView()
    }
    
    
}
