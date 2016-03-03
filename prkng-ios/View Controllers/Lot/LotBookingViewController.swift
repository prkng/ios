//
//  LotViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-09-02.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class LotBookingViewController: PRKModalDelegatedViewController, ModalHeaderViewDelegate, UIDatePickerViewControllerDelegate {
    
    var lot: Lot
    var user: ParkingPandaUser
    var parentView: UIView
    
    private var location: ParkingPandaLocation?
    
    private var dateFormatter: NSDateFormatter
    private var pickerVC: UIDatePickerViewController
    
    override var topParallaxView: UIView? { get {
        return topImageView
        }
    }
    
    private var topImageView = GMSPanoramaView(frame: CGRectZero)
    private var topGradient = UIImageView()
    private var topLabel = UILabel()
    
    private var headerView: ModalHeaderView
    
    private var timeViewButton = ViewFactory.openScheduleButton()
    private var timeView = UIView()
    private var timeIconView = UIImageView(image: UIImage(named: "icon_time_thin"))
    private var timeViewLabel = UILabel()
    private var timeViewRightArrow = UIImageView(image: UIImage(named: "btn_arrow_departure_1"))
    
    private var sliderContainerView = UIView()
    private var sliderLabel = UILabel()
    private var sliderForLabel = UILabel()
    private var slider = UISlider()
    
    private var payContainerView = UIView()
    private var payLabel = UILabel()
    //TODO: Localize
    private var payButton = ViewFactory.redRoundedButtonWithHeight(36, font: Styles.FontFaces.bold(12), text: String(format: "pay_with_x".localizedString.uppercaseString, "parking_panda".localizedString.uppercaseString))

    private static let HEADER_HEIGHT: CGFloat = 70
    private static let TIME_VIEW_HEIGHT: CGFloat = 60
    private static let SLIDER_VIEW_HEIGHT: CGFloat = 120
    private static let BOTTOM_VIEW_HEIGHT: CGFloat = 140
    
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
    
    init(lot: Lot, user: ParkingPandaUser, view: UIView) {
        self.lot = lot
        self.user = user
        self.parentView = view
        headerView = ModalHeaderView()
        
        self.dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .LongStyle
        dateFormatter.timeStyle = .ShortStyle
        
        //the minimum date is the nearest 30 minute
        let minimumDate = NSDate().skipToNextEvenMinuteInterval(30)
        self.pickerVC = UIDatePickerViewController(datePickerMode: .DateAndTime, minuteInterval: 30, minimumDate: minimumDate, maximumDate: minimumDate.dateByAddingDays(30), dateFormatter: dateFormatter, completion: nil)

        super.init(nibName: nil, bundle: nil)

        slider.minimumValue = 1
        
        self.pickerVC.delegate = self

        self.TOP_PARALLAX_HEIGHT = UIScreen.mainScreen().bounds.height - (LotBookingViewController.HEADER_HEIGHT + LotBookingViewController.TIME_VIEW_HEIGHT + LotBookingViewController.SLIDER_VIEW_HEIGHT + LotBookingViewController.BOTTOM_VIEW_HEIGHT) - CGFloat(Styles.Sizes.tabbarHeight)

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        headerView.topText = lot.headerText
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
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) { () -> Void in
            if self.lot.streetViewPanoramaId == nil {
                self.topImageView.moveNearCoordinate(self.lot.coordinate)
            } else {
                self.topImageView.moveToPanoramaID(self.lot.streetViewPanoramaId!)
            }
            if let heading = self.lot.streetViewHeading {
                let cameraUpdate = GMSPanoramaCameraUpdate.setHeading(CGFloat(heading))
                self.topImageView.updateCamera(cameraUpdate, animationDuration: 0.2)
            }
            let cameraUpdate = GMSPanoramaCameraUpdate.setZoom(3)
            self.topImageView.updateCamera(cameraUpdate, animationDuration: 0.2)
        }
        
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
        
        view.addSubview(headerView)
        headerView.rightImageViewWithLabel.image = UIImage(named: "btn_info_styled")
        headerView.rightImageViewLabel.text = "info".localizedString
        headerView.showsRightButton = false
        headerView.delegate = self
        headerView.clipsToBounds = true
        
        timeView.backgroundColor = Styles.Colors.cream1
        view.addSubview(timeView)

        timeIconView.image = timeIconView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        timeIconView.tintColor = Styles.Colors.midnight1
        timeView.addSubview(timeIconView)

        timeViewLabel.text = pickerVC.dateString
        timeViewLabel.textColor = Styles.Colors.midnight1
        timeViewLabel.font = Styles.FontFaces.regular(16)
        timeView.addSubview(timeViewLabel)
        
        timeView.addSubview(timeViewRightArrow)
        
        timeViewButton.addTarget(self, action: "timeViewTapped", forControlEvents: UIControlEvents.TouchUpInside)
        timeView.addSubview(timeViewButton)
        timeView.sendSubviewToBack(timeViewButton)
        
        sliderContainerView.backgroundColor = Styles.Colors.cream1
        view.addSubview(sliderContainerView)
        
        sliderLabel.text = ""
        sliderLabel.textAlignment = .Center
        sliderLabel.textColor = Styles.Colors.midnight1
        sliderLabel.numberOfLines = 0
        sliderContainerView.addSubview(sliderLabel)

        sliderForLabel.text = "for".localizedString.uppercaseString
        sliderForLabel.textColor = Styles.Colors.midnight1
        sliderForLabel.font = Styles.FontFaces.regular(12)
        sliderContainerView.addSubview(sliderForLabel)
        
        slider.maximumTrackTintColor = Styles.Colors.red2
        slider.minimumTrackTintColor = Styles.Colors.red2
        slider.thumbTintColor = Styles.Colors.stone
        slider.continuous = true
        slider.minimumValue = 1
        slider.maximumValue = 24
        slider.addTarget(self, action: "sliderValueChanged", forControlEvents: UIControlEvents.TouchUpInside)
        slider.addTarget(self, action: "sliderValueChanging", forControlEvents: UIControlEvents.ValueChanged)
        sliderContainerView.addSubview(slider)
        
        payContainerView.backgroundColor = Styles.Colors.stone
        view.addSubview(payContainerView)
        
        payLabel.text = ""
        payLabel.textAlignment = .Center
        payLabel.textColor = Styles.Colors.midnight1
        payContainerView.addSubview(payLabel)
        
        payButton.addTarget(self, action: "payButtonTapped", forControlEvents: .TouchUpInside)
        payButton.enabled = false
        payContainerView.addSubview(payButton)

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

        headerView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view).offset(self.TOP_PARALLAX_HEIGHT)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(LotBookingViewController.HEADER_HEIGHT)
        }

        timeView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.headerView.snp_bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(LotBookingViewController.TIME_VIEW_HEIGHT)
        }
        
        timeIconView.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.timeView).offset(24)
            make.centerY.equalTo(self.timeView)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        timeViewLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(timeIconView.snp_right).offset(14)
            make.right.equalTo(timeViewRightArrow.snp_left).offset(-14)
            make.centerY.equalTo(timeView)
        }
        
        timeViewRightArrow.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(timeView).offset(-25)
            make.centerY.equalTo(timeView)
            make.size.equalTo(CGSize(width: 5, height: 11))
        }
        
        timeViewButton.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(timeView)
        }
        
        sliderContainerView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.timeView.snp_bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(LotBookingViewController.SLIDER_VIEW_HEIGHT)
        }
        
        sliderForLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.sliderContainerView).offset(24)
            make.top.equalTo(self.sliderContainerView).offset(24)
        }
        
        sliderLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(sliderContainerView).offset(25)
            make.right.equalTo(sliderContainerView).offset(-25)
            make.centerY.equalTo(sliderContainerView).multipliedBy(0.66)
        }
        
        slider.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(sliderContainerView).offset(43)
            make.right.equalTo(sliderContainerView).offset(-43)
            make.centerY.equalTo(sliderContainerView).multipliedBy(1.33)
        }
        
        payContainerView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.sliderContainerView.snp_bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(LotBookingViewController.BOTTOM_VIEW_HEIGHT)
        }
        
        payLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(payContainerView).offset(25)
            make.right.equalTo(payContainerView).offset(-25)
            make.centerY.equalTo(payContainerView).multipliedBy(0.66)
        }
        
        payButton.snp_makeConstraints { (make) -> Void in
            make.height.equalTo(36)
            make.left.equalTo(payContainerView).offset(50)
            make.right.equalTo(payContainerView).offset(-50)
            make.centerY.equalTo(payContainerView).multipliedBy(1.33)
        }

    }
    
    //MARK: Helper and selector functions
    
    func setSliderLabelText(sliderHours: Int, parkUntil: NSDate?) {
        
        //TODO: Localize
        let line1Attributes = [NSFontAttributeName: Styles.FontFaces.bold(25), NSForegroundColorAttributeName: Styles.Colors.midnight1]
        let hourString = sliderHours == 1 ? "hour".localizedString : "hours".localizedString
        let textLine1 = NSMutableAttributedString(string: String(format: "%d %@\n", sliderHours, hourString), attributes: line1Attributes)
        
        let line2Attributes = [NSFontAttributeName: Styles.FontFaces.regular(12), NSForegroundColorAttributeName: Styles.Colors.red2]
        if parkUntil != nil {
            let dateFormatter = NSDateFormatter()
            if parkUntil!.isToday() {
                dateFormatter.dateFormat = "h:mm a"
            } else {
                dateFormatter.dateFormat = "h:mm a, MMM dd"
            }
            let dateString = dateFormatter.stringFromDate(parkUntil!)
            
            let textLine2 = NSAttributedString(string: "Park until " + dateString, attributes: line2Attributes)
            textLine1.appendAttributedString(textLine2)
        } else {
            let textLine2 = NSAttributedString(string: "Release slider to check availability", attributes: line2Attributes)
            textLine1.appendAttributedString(textLine2)
        }
        
        sliderLabel.attributedText = textLine1
    }

    func setPayLabelText(price: Float?) {
        
        if price == nil {
            payLabel.attributedText = nil
            return
        }
        
        let remainder = price! - Float(Int(price!))
        var priceString = String(format: " $%.02f", price!) //this auto rounds to the 2nd decimal place
        if remainder == 0 {
            priceString = String(format: " $%.0f", price!)
        }
        
        let totalTextAttributes = [NSFontAttributeName: Styles.FontFaces.regular(12), NSForegroundColorAttributeName: Styles.Colors.midnight1, NSBaselineOffsetAttributeName: 7]
        //TODO: Localize
        let attributedText = NSMutableAttributedString(string: "total".localizedString.uppercaseString, attributes: totalTextAttributes)
        
        let priceAttributes = [NSFontAttributeName: Styles.FontFaces.bold(25), NSForegroundColorAttributeName: Styles.Colors.midnight1]
        let priceText = NSAttributedString(string: priceString, attributes: priceAttributes)
        attributedText.appendAttributedString(priceText)
        
        payLabel.attributedText = attributedText
    }

    func timeViewTapped() {
        self.presentAsModalWithTransparency(pickerVC, completion: nil)
    }
    
    func sliderValueChanging() {
        setSliderLabelText(Int(round(slider.value)), parkUntil: nil)
    }
    
    //this also serves to update the UI for the price and dates on-screen
    func sliderValueChanged() {
        //first, round the value
        slider.setValue(round(slider.value), animated: true)
        setSliderLabelText(Int(slider.value), parkUntil: nil)
        
        //next get the start
        let startDate = self.pickerVC.date
        let endDate = startDate.dateByAddingHours(Int(slider.value))
        
        ParkingPandaOperations.getLocation(self.user,
            locationId: self.lot.partnerId,
            startDate: startDate,
            endDate: endDate) { (location, error) -> Void in

                let success = (location?.isAvailable ?? false) && error?.errorType == .NoError
                
                self.location = location
                
                if success {
                    //plus update the label
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.payButton.enabled = true
                        self.payButton.backgroundColor = Styles.Colors.red2
                        self.setSliderLabelText(Int(self.slider.value), parkUntil: location!.endDateAndTime)
                        self.setPayLabelText(location!.price)
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.payButton.enabled = false
                        self.payButton.backgroundColor = Styles.Colors.pinGrey
                        self.setSliderLabelText(0, parkUntil: nil)
                        self.setPayLabelText(nil)
                    })
                }

        }
        
    }
    
    func payButtonTapped() {
        if self.location != nil {
            SVProgressHUD.show()
            ParkingPandaOperations.createTransaction(self.user, location: self.location!, completion: { (transaction, error) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    SVProgressHUD.dismiss()
                })
                if transaction != nil {
                    //TODO: Localize
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.delegate?.hideModalView()
                        let transactionVC = PPTransactionViewController(transaction: transaction!, lot: self.lot)
                        transactionVC.presentWithVC(nil)
                        GeneralHelper.warnUserWithSucceedMessage("Successfully paid with Parking Panda!")
                    })
                }
            })
        } else {
            //TODO: Localize
            GeneralHelper.warnUserWithErrorMessage("Check availability first using the slider before trying to pay!")
        }
    }
    
    //MARK: UIDatePickerViewControllerDelegate
    
    func didSelectDate(date: NSDate, dateString: String) {
        print("selected the formatted date: " + dateString)
        timeViewLabel.text = pickerVC.dateString
        sliderValueChanged()
    }
    
    //MARK: ModalHeaderViewDelegate
    
    func tappedBackButton() {
        self.delegate?.hideModalView()
    }
    
    func tappedRightButton() {
        tappedBackButton()
    }
    
}
