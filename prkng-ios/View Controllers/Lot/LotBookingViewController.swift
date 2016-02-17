//
//  LotViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-09-02.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

//TODO: This is a complete mess. It makes no sense. But it can be the basis of the booking controller.
class LotBookingViewController: PRKModalDelegatedViewController, ModalHeaderViewDelegate {
    
//    var delegate : PRKModalViewControllerDelegate?
    var lot : Lot
    var parentView: UIView
    
    override var topParallaxView: UIView? { get {
        return topImageView
        }
    }
    
    private var topImageView = GMSPanoramaView(frame: CGRectZero)
    private var topGradient = UIImageView()
    private var topLabel = UILabel()
    private var headerView: ModalHeaderView
    private var dateContainer = UIView()
    private var timeContainer = UIView()
    private var timeIconView = UIImageView(image: UIImage(named: "icon_time_thin"))
    private var timeContentView = UIView()
    private var payButton = UIButton()

    private static let HEADER_HEIGHT: CGFloat = 70
    private static let DATE_VIEW_HEIGHT = 60
    private static let SLIDER_VIEW_HEIGHT = 120
    private static let BOTTOM_VIEW_HEIGHT = 140
    
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
        super.init(nibName: nil, bundle: nil)

        self.TOP_PARALLAX_HEIGHT = UIScreen.mainScreen().bounds.height - (LotBookingViewController.HEADER_HEIGHT + 30 + 50 + 52) - CGFloat(Styles.Sizes.tabbarHeight)
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
        
        view.addSubview(headerView)
        headerView.rightImageViewWithLabel.image = UIImage(named: "btn_info_styled")
        headerView.rightImageViewLabel.text = "info".localizedString
        headerView.showsRightButton = false
        headerView.delegate = self
        headerView.clipsToBounds = true
        
        timeIconView.image = timeIconView.image!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        timeIconView.tintColor = Styles.Colors.midnight1
        
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
//
//        timeIconView.snp_makeConstraints { (make) -> () in
//            make.left.equalTo(self.headerView).offset(34)
//            make.centerY.equalTo(self.headerView)
//        }
        
    }
    
    //MARK: Helper methods
    
    
    //MARK: ModalHeaderViewDelegate
    
    func tappedBackButton() {
        self.delegate?.hideModalView()
    }
    
    func tappedRightButton() {
        tappedBackButton()
    }
    
}
