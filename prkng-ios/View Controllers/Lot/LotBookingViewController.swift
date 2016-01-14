//
//  LotViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-09-02.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

//TODO: This is a complete mess. It makes no sense. But it can be the basis of the booking controller.
class LotBookingViewController: PRKModalDelegatedViewController, ModalHeaderViewDelegate, PRKVerticalGestureRecognizerDelegate {
    
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
    private var dateContainer = UIView()
    private var timeContainer = UIView()
    private var timeIconView = UIImageView(image: UIImage(named: "icon_time_thin"))
    private var timeContentView = UIView()
    private var payButton = UIButton()

    private var verticalRec: PRKVerticalGestureRecognizer
    private static let HEADER_HEIGHT: CGFloat = 70
    private static let DATE_VIEW_HEIGHT = 60
    private static let TIME_VIEW_HEIGHT = 110
    private static let BOTTOM_VIEW_HEIGHT = 120
    private(set) var LIST_HEIGHT: Int = 185
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

        self.TOP_PARALLAX_HEIGHT = UIScreen.mainScreen().bounds.height - (LotBookingViewController.HEADER_HEIGHT + 30 + 50 + 52) - CGFloat(Styles.Sizes.tabbarHeight)
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
        ParkingPandaOperations.login("urby@me.com", password: "parkinganta") { (user) -> Void in
            if user != nil {
                ParkingPandaOperations.getTransactions(user!, forTime: ParkingPandaOperations.ParkingPandaTransactionTime.All, completion: { (transactions, completed) -> Void in
                    print(completed)
                })
            }
        }
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
        
        if lot.lotOperator != nil {
            let operatedByString = NSMutableAttributedString(string: "operated_by".localizedString + " ", attributes: [NSFontAttributeName: Styles.FontFaces.light(12)])
            let operatorString = NSMutableAttributedString(string: lot.lotOperator!, attributes: [NSFontAttributeName: Styles.FontFaces.regular(12)])
            operatedByString.appendAttributedString(operatorString)
            topLabel.attributedText = operatedByString
        } else if lot.lotPartner != nil {
            let operatedByString = NSMutableAttributedString(string: "operated_by".localizedString + " ", attributes: [NSFontAttributeName: Styles.FontFaces.light(12)])
            let partnerString = NSMutableAttributedString(string: lot.lotPartner!, attributes: [NSFontAttributeName: Styles.FontFaces.regular(12)])
            operatedByString.appendAttributedString(partnerString)
            topLabel.attributedText = operatedByString
        }
        view.addSubview(topLabel)
        topLabel.textColor = Styles.Colors.cream1
        
        directionsButton.addTarget(self, action: "directionsButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(directionsButton)
        
        view.addSubview(headerView)
        headerView.showsRightButton = false
        headerView.delegate = self
        headerView.clipsToBounds = true
        
        timeIconView.image = timeIconView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        timeIconView.tintColor = Styles.Colors.midnight1
        
        verticalRec = PRKVerticalGestureRecognizer(view: self.view, superViewOfView: self.parentView)
        verticalRec.delegate = self
        
        view.bringSubviewToFront(headerView)
        
    }
    
    func setupConstraints() {
        
//        topImageView.snp_makeConstraints { (make) -> () in
//            make.top.equalTo(self.view)
//            make.left.equalTo(self.view)
//            make.right.equalTo(self.view)
//            make.height.equalTo(self.TOP_PARALLAX_HEIGHT)
//        }
//        
//        topGradient.snp_makeConstraints { (make) -> () in
//            make.bottom.equalTo(self.headerView.snp_top)
//            make.left.equalTo(self.view)
//            make.right.equalTo(self.view)
//            make.height.equalTo(65)
//        }
//        
//        topLabel.snp_makeConstraints { (make) -> () in
//            make.left.equalTo(self.view).offset(34)
//            make.bottom.equalTo(self.headerView.snp_top).offset(-24)
//        }
//        
//        directionsButton.snp_makeConstraints { (make) -> () in
//            make.right.equalTo(self.view).offset(-30)
//            make.bottom.equalTo(self.headerView.snp_top).offset(-16)
//        }
//        
//        headerView.snp_makeConstraints { (make) -> () in
//            make.top.equalTo(self.view).offset(self.TOP_PARALLAX_HEIGHT)
//            make.left.equalTo(self.view)
//            make.right.equalTo(self.view)
//            make.height.equalTo(LotBookingViewController.HEADER_HEIGHT)
//        }
//        
//        timeIconView.snp_makeConstraints { (make) -> () in
//            make.left.equalTo(self.headerView).offset(34)
//            make.centerY.equalTo(self.headerView)
//        }
        
    }
    
    //MARK: Helper methods
    
    func directionsButtonTapped(sender: UIButton) {
        DirectionsAction.perform(onViewController: self, withCoordinate: self.lot.coordinate, shouldCallback: false)
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
        self.topOffset = self.topOffset == 0 ? self.LIST_HEIGHT : 0
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
