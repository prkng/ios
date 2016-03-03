//
//  PPTransactionViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2016-02-25.
//  Copyright © 2016 PRKNG. All rights reserved.
//

import UIKit

class PPTransactionViewController: UIViewController, ModalHeaderViewDelegate, UIScrollViewDelegate {
    
    private var transaction: ParkingPandaTransaction //customized based on the presence of the lot
    private var lot: Lot?

    private var scrollView = UIScrollView()
    private var contentView = UIView()
    
    private var topImageView = GMSPanoramaView(frame: CGRectZero)
    private var topGradient = UIImageView()
    private var directionsButton = ViewFactory.directionsButton()
    private var topLabel = UILabel()
    
    private var headerView: ModalHeaderView
    
    private var fromTimeView = UIView()
    private var fromTimeIconView = UIImageView(image: UIImage(named: "icon_time_thin"))
    private var fromTimeViewLabel = UILabel()
    private var separator1 = UIView()
    private var toTimeView = UIView()
    private var toTimeIconView = UIImageView(image: UIImage(named: "icon_time_thin"))
    private var toTimeViewLabel = UILabel()
    
    private var separator2 = UIView()
    private var barcodeImageView = UIImageView()
    
    private var payContainerView = UIView()
//    private var creditCardImageView = UIImageView()
    private var payTitleLabel = UILabel()
    private var paySubtitleLabel = UILabel()
    private var priceLabel = UILabel()
    private var separator3 = UIView()

    private var separator4 = UIView()
    private var attributesView = UIView()
    private var attributesViewContainers = [UIView]()
    private var attributesViewLabels = [UILabel]()
    private var attributesViewImages = [UIImageView]()
    
    //TODO: Localize
    private var addToWalletButton = ViewFactory.redRoundedButtonWithHeight(36, font: Styles.FontFaces.bold(12), text: "add_to_wallet".localizedString.uppercaseString)
    
    private let streetViewHeight: CGFloat = 222
    private let headerHeight: CGFloat = 70
    private(set) var gradientHeight: CGFloat = 65
    private let timeViewHeight: CGFloat = 60
    private let barcodeViewHeight: CGFloat = 180
    private let attributesViewHeight: CGFloat = 52
    private let payContainerViewHeight: CGFloat = 60
    private let paddingHeight: CGFloat = 5
    
    init(transaction: ParkingPandaTransaction, lot: Lot?) {

        self.transaction = transaction
        self.lot = lot
        
        headerView = ModalHeaderView()
        
        super.init(nibName: nil, bundle: nil)
        
        contentView = scrollView
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func presentWithVC(vc: UIViewController?) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let rootVC = vc ?? appDelegate.window?.rootViewController {
            if let navVC = rootVC.navigationController {
                navVC.pushViewController(self, animated: true)
            } else {
                rootVC.presentViewController(self, animated: true, completion: nil)
            }
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setupSubviews()
        setupConstraints()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let height = topImageView.frame.size.height + headerHeight + (2*timeViewHeight) + barcodeImageView.frame.size.height + payContainerViewHeight + attributesViewHeight + paddingHeight
        scrollView.contentSize = CGSize(width: UIScreen.mainScreen().bounds.width, height: height)
    }
    
    func setupSubviews() {
        
        scrollView.delegate = self
        scrollView.alwaysBounceVertical = true
        self.view.addSubview(scrollView)
        
        contentView.backgroundColor = Styles.Colors.cream1
        scrollView.addSubview(topImageView)
        topImageView.navigationLinksHidden = true
        
        LotOperations.sharedInstance.findLot(transaction.location.identifier, partnerName: "Parking Panda") { (lot) -> Void in
            self.lot = lot
            self.lotSetup()
        }
        
        scrollView.addSubview(topGradient)
        
        scrollView.addSubview(topLabel)
        topLabel.textColor = Styles.Colors.cream1
        
        scrollView.addSubview(headerView)
        headerView.topText = transaction.location.address
        headerView.showsRightButton = false
        headerView.delegate = self
        headerView.clipsToBounds = true
        
        directionsButton.addTarget(self, action: "directionsButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        scrollView.addSubview(directionsButton)
        
        fromTimeView.backgroundColor = Styles.Colors.cream1
        scrollView.addSubview(fromTimeView)
        
        fromTimeIconView.image = fromTimeIconView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        fromTimeIconView.tintColor = Styles.Colors.midnight1
        fromTimeView.addSubview(fromTimeIconView)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .LongStyle
        dateFormatter.timeStyle = .ShortStyle
        
        fromTimeViewLabel.text = "from".localizedString + "\n" + dateFormatter.stringFromDate(transaction.startDateAndTime ?? NSDate())
        fromTimeViewLabel.textColor = Styles.Colors.midnight1
        fromTimeViewLabel.font = Styles.FontFaces.regular(16)
        fromTimeViewLabel.numberOfLines = 2
        fromTimeView.addSubview(fromTimeViewLabel)
        
        separator1.backgroundColor = Styles.Colors.transparentBlack
        scrollView.addSubview(separator1)
        
        toTimeView.backgroundColor = Styles.Colors.cream1
        scrollView.addSubview(toTimeView)
        
        toTimeIconView.image = toTimeIconView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        toTimeIconView.tintColor = Styles.Colors.midnight1
        toTimeView.addSubview(toTimeIconView)
        
        toTimeViewLabel.text = "to".localizedString + "\n" + dateFormatter.stringFromDate(transaction.endDateAndTime ?? NSDate())
        toTimeViewLabel.textColor = Styles.Colors.midnight1
        toTimeViewLabel.font = Styles.FontFaces.regular(16)
        toTimeViewLabel.numberOfLines = 2
        toTimeView.addSubview(toTimeViewLabel)
        
        separator2.backgroundColor = Styles.Colors.transparentBlack
        scrollView.addSubview(separator2)
        
        if let barcodeUrl = NSURL(string: transaction.barcodeUrlString) {
            barcodeImageView.sd_setImageWithURL(barcodeUrl, completed: { (image, error, cacheType, url) -> Void in
                let currentDate = NSDate()
                if self.transaction.endDateAndTime?.earlierDate(currentDate) == self.transaction.endDateAndTime {
                    self.barcodeImageView.alpha = 0.2
                }
            })
        }
        barcodeImageView.contentMode = .ScaleAspectFit
        scrollView.addSubview(barcodeImageView)
        
        contentView.bringSubviewToFront(directionsButton)
        
        separator3.backgroundColor = Styles.Colors.transparentBlack
        scrollView.addSubview(separator3)

        payContainerView.backgroundColor = Styles.Colors.cream1
        scrollView.addSubview(payContainerView)
        
        //TODO: LOCALIZE
        payTitleLabel.text = "paid_with_parking_panda".localizedString
        payTitleLabel.textColor = Styles.Colors.red2
        payTitleLabel.font = Styles.FontFaces.regular(14)
        payTitleLabel.numberOfLines = 1
        payContainerView.addSubview(payTitleLabel)
        
        paySubtitleLabel.text = transaction.paymentMaskedCardInfo
        paySubtitleLabel.textColor = Styles.Colors.anthracite1
        paySubtitleLabel.font = Styles.FontFaces.regular(12)
        paySubtitleLabel.numberOfLines = 1
        payContainerView.addSubview(paySubtitleLabel)

        let remainder = transaction.amount - Float(Int(transaction.amount))
        var priceString = String(format: " $%.02f", transaction.amount) //this auto rounds to the 2nd decimal place
        if remainder == 0 {
            priceString = String(format: " $%.0f", transaction.amount)
        }
        priceLabel.text = priceString
        priceLabel.textColor = Styles.Colors.midnight1
        priceLabel.font = Styles.FontFaces.bold(14)
        priceLabel.numberOfLines = 1
        priceLabel.textAlignment = .Right
        payContainerView.addSubview(priceLabel)
        
//        if let creditCardTypeImage = transaction CardIOCreditCardInfo.logoForCardType(creditCardType) {
//            creditCardImageView.image = creditCardTypeImage
//        }


        separator4.backgroundColor = Styles.Colors.transparentBlack
        scrollView.addSubview(separator4)

        scrollView.addSubview(attributesView)
        attributesView.backgroundColor = Styles.Colors.cream1
        
    }
    
    func setupConstraints() {
        
        scrollView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        
        topImageView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.contentView)
            make.left.equalTo(self.contentView)
            make.right.equalTo(self.contentView)
            make.height.equalTo(lot != nil ? streetViewHeight : 0)
            make.width.equalTo(self.view)
        }
        
        topGradient.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.headerView.snp_top)
            make.left.equalTo(self.contentView)
            make.right.equalTo(self.contentView)
            make.height.equalTo(gradientHeight)
            make.width.equalTo(self.view)
        }
        
        topLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.contentView).offset(34)
            make.bottom.equalTo(self.headerView.snp_top).offset(-24)
        }
        
        directionsButton.snp_makeConstraints { (make) -> () in
            make.right.equalTo(headerView).offset(-30)
            make.centerY.equalTo(headerView)
        }
        
        headerView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.topImageView.snp_bottom)
            make.left.equalTo(self.contentView)
            make.right.equalTo(self.contentView)
            make.height.equalTo(headerHeight)
        }
        
        fromTimeView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(headerView.snp_bottom)
            make.left.equalTo(contentView)
            make.right.equalTo(contentView)
            make.height.equalTo(timeViewHeight)
            make.width.equalTo(self.view)
        }
        
        fromTimeIconView.snp_makeConstraints { (make) -> () in
            make.left.equalTo(fromTimeView).offset(24)
            make.centerY.equalTo(fromTimeView)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        fromTimeViewLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(fromTimeIconView.snp_right).offset(14)
            make.right.equalTo(fromTimeView).offset(-14)
            make.centerY.equalTo(fromTimeView)
        }
        
        separator1.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(fromTimeView)
            make.left.equalTo(contentView)
            make.right.equalTo(contentView)
            make.height.equalTo(1)
        }
        
        toTimeView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(fromTimeView.snp_bottom)
            make.left.equalTo(contentView)
            make.right.equalTo(contentView)
            make.height.equalTo(timeViewHeight)
            make.width.equalTo(self.view)
        }
        
        toTimeIconView.snp_makeConstraints { (make) -> () in
            make.left.equalTo(toTimeView).offset(24)
            make.centerY.equalTo(toTimeView)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        toTimeViewLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(toTimeIconView.snp_right).offset(14)
            make.right.equalTo(toTimeView).offset(-14)
            make.centerY.equalTo(toTimeView)
        }
        
        separator2.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(toTimeView)
            make.left.equalTo(contentView)
            make.right.equalTo(contentView)
            make.height.equalTo(1)
        }
        
        barcodeImageView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(toTimeView.snp_bottom)
            make.left.equalTo(contentView)
            make.right.equalTo(contentView)
            make.width.equalTo(self.view)
        }
        
        separator3.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(barcodeImageView)
            make.left.equalTo(contentView)
            make.right.equalTo(contentView)
            make.height.equalTo(1)
        }
        
        payContainerView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(barcodeImageView.snp_bottom)
            make.left.equalTo(contentView)
            make.right.equalTo(contentView)
            make.width.equalTo(self.view)
            make.height.equalTo(payContainerViewHeight)
        }
        
//        creditCardImageView.snp_makeConstraints { (make) -> Void in
//            make.left.equalTo(payContainerView).offset(24)
//            make.centerY.equalTo(self.contentView).multipliedBy(0.5)
//            make.size.equalTo(CGSize(width: 36, height: 25)) //this is the default size of CardIO's CardIOCreditCardInfo.logoForCardType(cardType: CardIOCreditCardType) method
//        }
        
        payTitleLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(payContainerView).offset(24)
            make.centerY.equalTo(payContainerView).multipliedBy(0.66)
            make.right.equalTo(payContainerView).offset(-70)
        }
        
        paySubtitleLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(payContainerView).offset(24)
            make.centerY.equalTo(payContainerView).multipliedBy(1.33)
            make.right.equalTo(payContainerView).offset(-70)
        }
        
        priceLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(payContainerView.snp_right).offset(-70)
            make.right.equalTo(payContainerView).offset(-14)
            make.centerY.equalTo(payContainerView)
        }
        
        separator4.snp_makeConstraints { (make) -> Void in
            make.bottom.equalTo(payContainerView)
            make.left.equalTo(contentView)
            make.right.equalTo(contentView)
            make.height.equalTo(1)
        }
        
    }

    func lotSetup() {
        
        topImageView.snp_remakeConstraints { (make) -> () in
            make.top.equalTo(self.contentView)
            make.left.equalTo(self.contentView)
            make.right.equalTo(self.contentView)
            make.height.equalTo(lot != nil ? streetViewHeight : 0)
            make.width.equalTo(self.view)
        }

        if lot != nil {
            
            if lot!.streetViewPanoramaId == nil {
                topImageView.moveNearCoordinate(lot!.coordinate)
            } else {
                topImageView.moveToPanoramaID(lot!.streetViewPanoramaId!)
            }
            if let heading = lot!.streetViewHeading {
                let cameraUpdate = GMSPanoramaCameraUpdate.setHeading(CGFloat(heading))
                topImageView.updateCamera(cameraUpdate, animationDuration: 0.2)
            }
            let cameraUpdate = GMSPanoramaCameraUpdate.setZoom(3)
            topImageView.updateCamera(cameraUpdate, animationDuration: 0.2)
            
            let screenWidth = UIScreen.mainScreen().bounds.width
            topGradient.image = UIImage.imageFromGradient(CGSize(width: screenWidth, height: 65.0), fromColor: UIColor.clearColor(), toColor: UIColor.blackColor().colorWithAlphaComponent(0.9))
            
            if lot!.lotOperator != nil {
                let operatedByString = NSMutableAttributedString(string: "operated_by".localizedString + " ", attributes: [NSFontAttributeName: Styles.FontFaces.light(12)])
                let operatorString = NSMutableAttributedString(string: lot!.lotOperator!, attributes: [NSFontAttributeName: Styles.FontFaces.regular(12)])
                operatedByString.appendAttributedString(operatorString)
                topLabel.attributedText = operatedByString
            } else if lot!.lotPartner != nil {
                let operatedByString = NSMutableAttributedString(string: "operated_by".localizedString + " ", attributes: [NSFontAttributeName: Styles.FontFaces.light(12)])
                let partnerString = NSMutableAttributedString(string: lot!.lotPartner!, attributes: [NSFontAttributeName: Styles.FontFaces.regular(12)])
                operatedByString.appendAttributedString(partnerString)
                topLabel.attributedText = operatedByString
            }
            
            //attributes!
            
            for attribute in lot!.attributes {
                
                let attributesViewContainer = UIView()
                attributesViewContainers.append(attributesViewContainer)
                
                let caption = attribute.name(false).localizedString.uppercaseString
                let imageName = "icon_attribute_" + attribute.name(true) + (attribute.enabled ? "_on" : "_off" )
                
                let attributeLabel = UILabel()
                attributeLabel.text = caption
                attributeLabel.textColor = attribute.showAsEnabled ? Styles.Colors.petrol2 : Styles.Colors.greyish
                attributeLabel.font = Styles.FontFaces.regular(9)
                attributesViewLabels.append(attributeLabel)
                
                let attributeImageView = UIImageView(image: UIImage(named: imageName)!)
                attributeImageView.contentMode = .Center
                attributesViewImages.append(attributeImageView)
                
                attributesViewContainer.addSubview(attributeLabel)
                attributesViewContainer.addSubview(attributeImageView)
                attributesView.addSubview(attributesViewContainer)
            }
            
            attributesView.snp_makeConstraints { (make) -> () in
                make.top.equalTo(self.payContainerView.snp_bottom)
                make.left.equalTo(self.view)
                make.right.equalTo(self.view)
                make.height.equalTo(attributesViewHeight)
            }
            
            var leftConstraint = self.attributesView.snp_left
            
            for i in 0..<attributesViewContainers.count {
                
                let width = Int(UIScreen.mainScreen().bounds.width)/attributesViewContainers.count
                
                let attributesViewContainer = attributesViewContainers[i]
                attributesViewContainer.snp_makeConstraints(closure: { (make) -> () in
                    make.left.equalTo(leftConstraint)
                    make.top.equalTo(self.attributesView)
                    make.bottom.equalTo(self.attributesView)
                    make.width.equalTo(width)
                })
                
                let label = attributesViewLabels[i]
                label.snp_makeConstraints(closure: { (make) -> () in
                    make.centerX.equalTo(attributesViewContainer.snp_centerX)
                    make.bottom.equalTo(self.attributesView).offset(-4.5)
                })
                
                let imageView = attributesViewImages[i]
                imageView.snp_makeConstraints(closure: { (make) -> () in
                    //make.size.equalTo(CGSize(width: 32, height: 32))
                    make.centerX.equalTo(label.snp_centerX)
                    make.bottom.equalTo(label.snp_top).offset(-3.5)
                })
                
                leftConstraint = attributesViewContainer.snp_right
            }

        }
    
    }
    
    //MARK: UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let xOffset = 0 - scrollView.contentOffset.y
        if xOffset < 0 {
            topImageView.snp_remakeConstraints { (make) -> () in
                make.top.equalTo(self.contentView)
                make.left.equalTo(self.contentView)
                make.right.equalTo(self.contentView)
                make.height.equalTo(lot != nil ? streetViewHeight : 0)
                make.width.equalTo(self.view)
            }
        } else {
            topImageView.snp_remakeConstraints { (make) -> () in
                make.top.equalTo(self.view)
                make.left.equalTo(self.contentView)
                make.right.equalTo(self.contentView)
                make.height.equalTo(lot != nil ? streetViewHeight + xOffset : 0)
                make.width.equalTo(self.view)
            }
        }
    }
    
    //MARK: PPHeaderViewDelegate functions
    
    func tappedBackButton() {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tappedRightButton() {
        directionsButtonTapped(directionsButton)
    }
    
    //MARK: Helper methods
    
    func directionsButtonTapped(sender: UIButton) {
        if lot?.coordinate != nil {
            DirectionsAction.perform(onViewController: self, withCoordinate: lot!.coordinate, shouldCallback: false)
        }
    }

}
