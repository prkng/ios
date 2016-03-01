//
//  PPTransactionView.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2016-02-24.
//  Copyright © 2016 PRKNG. All rights reserved.
//

import UIKit

class PPTransactionView: UIView, ModalHeaderViewDelegate, UIScrollViewDelegate {

    weak var viewController: UIViewController?
    var delegate: PPTransactionViewDelegate?
    var coordinate: CLLocationCoordinate2D?
    
    private var scrollView = UIScrollView()
    private var contentView = UIView()//UIcontentView()

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
    private var barcodeView = UIView()
    private var barcodeImageView = UIImageView()

    //TODO: Localize
    private var addToWalletButton = ViewFactory.redRoundedButtonWithHeight(36, font: Styles.FontFaces.bold(12), text: "add_to_wallet".localizedString.uppercaseString)

    private var transaction: ParkingPandaTransaction //customized based on the presence of the lot
    private var lot: Lot?
    
    private let streetViewHeight = 222
    private let headerHeight = 70
    private(set) var gradientHeight = 65
    private let timeViewHeight = 60
    private let barcodeViewHeight = 180
    
    init(transaction: ParkingPandaTransaction, lot: Lot?) {
        
        self.transaction = transaction
        self.lot = lot
        
        headerView = ModalHeaderView()
        
        super.init(frame: CGRectZero)
        
        setupSubviews()
        setupConstraints()
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        
        scrollView.delegate = self
        self.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(topImageView)
        topImageView.navigationLinksHidden = true
        
        
        CLGeocoder().geocodeAddressString(transaction.location.fullAddress) { (placemarks, error) -> Void in
            if error == nil && placemarks != nil {
                if let placemark = placemarks?.first {
                    if let coordinate = placemark.location?.coordinate {
                        self.coordinate = coordinate
                        self.topImageView.moveNearCoordinate(coordinate)
                        self.topImageView.snp_updateConstraints(closure: { (make) -> Void in
                            make.height.equalTo(self.streetViewHeight)
                        })
                    }
                }
            }
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
        }
        
        contentView.addSubview(topGradient)
        
        if lot != nil {
            
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
        }
        
        contentView.addSubview(topLabel)
        topLabel.textColor = Styles.Colors.cream1
        
        contentView.addSubview(headerView)
        headerView.topText = transaction.location.address
        headerView.showsRightButton = false
        headerView.delegate = self
        headerView.clipsToBounds = true
        
        directionsButton.addTarget(self, action: "directionsButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        contentView.addSubview(directionsButton)

        fromTimeView.backgroundColor = Styles.Colors.cream1
        contentView.addSubview(fromTimeView)

        fromTimeIconView.image = fromTimeIconView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        fromTimeIconView.tintColor = Styles.Colors.midnight1
        fromTimeView.addSubview(fromTimeIconView)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .LongStyle
        dateFormatter.timeStyle = .ShortStyle
        
        fromTimeViewLabel.text = dateFormatter.stringFromDate(transaction.startDateAndTime ?? NSDate())
        fromTimeViewLabel.textColor = Styles.Colors.midnight1
        fromTimeViewLabel.font = Styles.FontFaces.regular(16)
        fromTimeView.addSubview(fromTimeViewLabel)

        separator1.backgroundColor = Styles.Colors.transparentBlack
        contentView.addSubview(separator1)
        
        toTimeView.backgroundColor = Styles.Colors.cream1
        contentView.addSubview(toTimeView)
        
        toTimeIconView.image = toTimeIconView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        toTimeIconView.tintColor = Styles.Colors.midnight1
        toTimeView.addSubview(toTimeIconView)

        toTimeViewLabel.text = dateFormatter.stringFromDate(transaction.endDateAndTime ?? NSDate())
        toTimeViewLabel.textColor = Styles.Colors.midnight1
        toTimeViewLabel.font = Styles.FontFaces.regular(16)
        toTimeView.addSubview(toTimeViewLabel)

        separator2.backgroundColor = Styles.Colors.transparentBlack
        contentView.addSubview(separator2)
        
        barcodeView.backgroundColor = Styles.Colors.cream1
        contentView.addSubview(barcodeView)

        if let barcodeUrl = NSURL(string: transaction.barcodeUrlString) {
            barcodeImageView.sd_setImageWithURL(barcodeUrl)
        }
        barcodeView.addSubview(barcodeImageView)
        
        contentView.bringSubviewToFront(directionsButton)
    }
    
    func setupConstraints() {
        
        scrollView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.height.equalTo(self)
            make.width.equalTo(self)
        }
        
        contentView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(scrollView)
            make.top.equalTo(scrollView)
            make.size.equalTo(self)
        }
        
        topImageView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.contentView)
            make.left.equalTo(self.contentView)
            make.right.equalTo(self.contentView)
            make.height.equalTo(lot != nil ? streetViewHeight : 0)
        }
        
        topGradient.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.headerView.snp_top)
            make.left.equalTo(self.contentView)
            make.right.equalTo(self.contentView)
            make.height.equalTo(gradientHeight)
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
        
        barcodeView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(toTimeView.snp_bottom)
            make.left.equalTo(contentView)
            make.right.equalTo(contentView)
            make.height.equalTo(barcodeViewHeight)
        }

        barcodeImageView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(barcodeView)
        }

    }
    
    override func layoutSubviews() {

        super.layoutSubviews()
        
//        let contentSize = self.frame.size
//        scrollView.contentSize = CGSize(width: contentSize.width, height: contentSize.height)//po scrollView.contentSize
//        scrollView.frame.size = CGSize(width: contentSize.width, height: 250)//po scrollView.frame.size
        
    }
    
    //MARK: UIScrollViewDelegate functions
    
    //MARK: PPHeaderViewDelegate functions
    
    func tappedBackButton() {
        self.delegate?.tappedBackButton()
    }
    
    func tappedRightButton() {
        directionsButtonTapped(directionsButton)
    }
    
    //MARK: Helper methods
    
    func directionsButtonTapped(sender: UIButton) {
        if viewController != nil && coordinate != nil {
            DirectionsAction.perform(onViewController: viewController!, withCoordinate: coordinate!, shouldCallback: false)
        }
    }

    
}

protocol PPTransactionViewDelegate {
    func tappedBackButton()
}
