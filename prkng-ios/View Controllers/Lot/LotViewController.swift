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
    
    private var topImageView = GMSPanoramaView(frame: CGRectZero)
    private var topGradient = UIImageView()
    private var directionsButton = ViewFactory.directionsButton()
    private var topLabel = UILabel()
    private var headerView: ModalHeaderView
    private var subHeaderView = UIView()
    private var subHeaderViewLabel = PRKTimeSpanView()
    private var todayTimeHeaderView = UIView()
    private var timeIconView = UIImageView(image: UIImage(named: "icon_time"))
    private var timeListView = UIView()
    private var timeSpanLabels = [PRKTimeSpanView]()
    private var attributesView = UIView()
    private var attributesViewLabels = [UILabel]()
    private var attributesViewImages = [UIImageView]()

    private var verticalRec: PRKVerticalGestureRecognizer
    private static let HEADER_HEIGHT: CGFloat = 70
    private static let FULL_WIDTH: CGFloat = UIScreen.mainScreen().bounds.width
    private static let TOP_IMAGE_HEIGHT: CGFloat = UIScreen.mainScreen().bounds.height - (HEADER_HEIGHT + 30 + 50 + 185 + 52) - CGFloat(Styles.Sizes.tabbarHeight)

    
    init(lot: Lot, view: UIView) {
        self.lot = lot
        self.parentView = view
        headerView = ModalHeaderView()
        verticalRec = PRKVerticalGestureRecognizer()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        headerView.titleLabel.text = lot.headerText
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
        view.backgroundColor = Styles.Colors.stone
        setupViews()
        setupConstraints()
    }
    
    func setupViews() {
        
        view.addSubview(topImageView)
        //width, height, lat, long
//        let urlString = String(format:"https://maps.googleapis.com/maps/api/streetview?size=%dx%d&location=%f,%f&key=AIzaSyAjtDb1VW1rnICr_JMFPmzWi3pMshLusA8", Int(Settings.screenScale * LotViewController.FULL_WIDTH), Int(Settings.screenScale * LotViewController.TOP_IMAGE_HEIGHT), lot.coordinate.latitude, lot.coordinate.longitude)
//        topImageView.sd_setImageWithURL(NSURL(string: urlString))
//        topImageView.sd_setImageWithURL(url: NSURL(string: "https://maps.googleapis.com/maps/api/streetview?size=600x300&location=46.414382,10.013988&heading=151.78&pitch=-0.76&key=AIzaSyAjtDb1VW1rnICr_JMFPmzWi3pMshLusA8"))
        topImageView.moveNearCoordinate(lot.coordinate)
        
        view.addSubview(topGradient)
        topGradient.image = UIImage.imageFromGradient(CGSize(width: LotViewController.FULL_WIDTH, height: 64.0), fromColor: UIColor.clearColor(), toColor: UIColor.blackColor().colorWithAlphaComponent(0.75))
        
        view.addSubview(topLabel)
        topLabel.textColor
        view.addSubview(directionsButton)
        
        view.addSubview(headerView)
        headerView.showsRightButton = false
        headerView.delegate = self
        headerView.layer.shadowColor = UIColor.blackColor().CGColor
        headerView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        headerView.layer.shadowOpacity = 0.2
        headerView.layer.shadowRadius = 0.5
        
        view.addSubview(subHeaderView)
        subHeaderView.backgroundColor = Styles.Colors.red2
        
        subHeaderView.addSubview(subHeaderViewLabel)
        subHeaderViewLabel.leftLabel.text = String(format: "capacity_x_places".localizedString, lot.capacity)
        subHeaderViewLabel.leftLabel.font = Styles.FontFaces.regular(11)
        subHeaderViewLabel.leftLabel.textColor = Styles.Colors.cream1

        subHeaderViewLabel.leftLabel.font = Styles.FontFaces.regular(11)

        var currencyString = NSMutableAttributedString(string: "$" + String(Int(lot.mainHourlyRate)), attributes: [NSFontAttributeName: Styles.FontFaces.regular(14)])
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
        
        view.addSubview(timeListView)
        timeListView.backgroundColor = Styles.Colors.stone

        for i in 1..<7 {
            let timeSpanLabel = PRKTimeSpanView(dayString: days[i], startTime: openTimes[i].0, endTime: openTimes[i].1)
            timeSpanLabels.append(timeSpanLabel)
            timeListView.addSubview(timeSpanLabel)
        }
        
        for attribute in lot.attributes {
            let caption = attribute.name.localizedString.uppercaseString
            let imageName = "icon_" + attribute.name + (attribute.enabled ? "_on" : "_off" )
            
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
            make.height.equalTo(LotViewController.TOP_IMAGE_HEIGHT)
        }
        
        topGradient.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.topImageView)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(64)
        }
        
        
        
        headerView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view).with.offset(LotViewController.TOP_IMAGE_HEIGHT)
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
        
        timeListView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.todayTimeHeaderView.snp_bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(185)
        }
        
        timeSpanLabels[0].snp_makeConstraints({ (make) -> () in
            make.left.equalTo(self.todayTimeHeaderView).with.offset(66.5)
            make.right.equalTo(self.todayTimeHeaderView).with.offset(-40)
            make.centerY.equalTo(self.todayTimeHeaderView)
        })

        var topConstraint = self.timeListView.snp_top
        for i in 1..<7 {
            let timeSpanLabel = timeSpanLabels[i]
            let topOffset = i == 1 ? 14 : 10
            timeSpanLabel.snp_makeConstraints({ (make) -> () in
                make.top.equalTo(topConstraint).with.offset(topOffset)
                make.left.equalTo(self.timeListView).with.offset(34)
                make.right.equalTo(self.timeListView).with.offset(-40)
            })
            topConstraint = timeSpanLabel.snp_bottom
        }

        
        attributesView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.timeListView.snp_bottom)
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
    
    func shouldShowSchedule() -> Bool {
        
        let defaultModalView = (NSUserDefaults.standardUserDefaults().valueForKey("DEFAULT_MODAL_VIEW") as? Int) ?? 0
        
        switch defaultModalView {
        case 0:
            return true
        case 1:
            return false
        default:
            return true
        }
        
    }
    
    func updateHeader(viewController: PRKModalViewControllerChild) {
        let isSchedule = viewController is ScheduleViewController
        if isSchedule {
            headerView.makeRightButtonList(true)
        } else {
            headerView.makeRightButtonColumns(true)
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
        return beginTap.y <= LotViewController.TOP_IMAGE_HEIGHT
    }

    func swipeDidBegin() {
        
    }
    
    func swipeInProgress(yDistanceFromBeginTap: CGFloat) {
        if yDistanceFromBeginTap < 0 {
            self.delegate?.shouldAdjustTopConstraintWithOffset(-yDistanceFromBeginTap, animated: false)
        }
    }
    
    func swipeDidEndUp() {
        self.delegate?.shouldAdjustTopConstraintWithOffset(0, animated: true)
    }
    
    func swipeDidEndDown() {
        self.delegate?.hideModalView()
    }
    
    
    //NOTE: we use this to flip the icon between transitions. the method above will ensure we always end up with the right header icon
    func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [AnyObject], transitionCompleted completed: Bool) {
        
        if let fromViewController = previousViewControllers[0] as? PRKModalViewControllerChild {
            if !completed {
                updateHeader(fromViewController)
            }
        }
        
    }
    
}
