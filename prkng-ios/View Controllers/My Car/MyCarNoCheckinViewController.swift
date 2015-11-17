//
//  MyCarNoCheckinViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 15/05/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class MyCarNoCheckinViewController: MyCarAbstractViewController {
    
    let backgroundImageView = UIImageView(image: UIImage(named:"bg_mycar"))

    var logoView : UIImageView
    var messageLabel : UILabel
    
    var reportButton : UIButton
    var mapButton : UIButton
    
    var delegate : MyCarNoCheckinViewControllerDelegate?
    
    let BOTTOM_BUTTON_HEIGHT: CGFloat = 36
    
    init() {
        
        logoView = UIImageView()
        messageLabel = ViewFactory.bigMessageLabel()
        mapButton = ViewFactory.redRoundedButtonWithHeight(BOTTOM_BUTTON_HEIGHT, font: Styles.FontFaces.regular(12), text: "show_the_map".localizedString.uppercaseString)
        reportButton = ViewFactory.roundedButtonWithHeight(BOTTOM_BUTTON_HEIGHT, backgroundColor: Styles.Colors.stone, font: Styles.FontFaces.regular(12), text: "report_an_error".localizedString.uppercaseString, textColor: Styles.Colors.petrol2, highlightedTextColor: Styles.Colors.petrol1)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func loadView() {
        self.view = UIView()
        setupViews()
        setupConstraints()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenName = "My Car - Not Checked in"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }

    func setupViews () {
        
        backgroundImageView.contentMode = .ScaleAspectFill
        view.addSubview(backgroundImageView)
        
        segmentedControl.setPressedHandler(segmentedControlTapped)
        self.view.addSubview(segmentedControl)
        
        logoView.image = UIImage(named: "icon_checkin")
        view.addSubview(logoView)
        
        messageLabel.text = "no_checkin_message".localizedString
        view.addSubview(messageLabel)
        
        reportButton.addTarget(self, action: "reportButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(reportButton)
        
        mapButton.addTarget(self, action: "mapButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(mapButton)
    }
    
    func setupConstraints () {
        
        backgroundImageView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }
        
        segmentedControl.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(CGSize(width: 120, height: 20))
            make.top.equalTo(self.snp_topLayoutGuideBottom).offset(30)
            make.centerX.equalTo(self.view)
        }
        
        logoView.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(68, 68))
            make.centerX.equalTo(self.view)
            make.top.equalTo(self.segmentedControl.snp_bottom).offset(40)
        }

        messageLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.view).offset(30)
            make.right.equalTo(self.view).offset(-30)
            make.centerY.equalTo(self.view).multipliedBy(0.8)
        }
        
        reportButton.snp_makeConstraints { (make) -> () in
            make.height.equalTo(BOTTOM_BUTTON_HEIGHT)
            make.bottom.equalTo(self.mapButton.snp_top).offset(-14)
            make.left.equalTo(self.view).offset(50)
            make.right.equalTo(self.view).offset(-50)

        }

        mapButton.snp_makeConstraints { (make) -> () in
            make.height.equalTo(BOTTOM_BUTTON_HEIGHT)
            make.bottom.equalTo(self.view).offset(-20)
            make.left.equalTo(self.view).offset(50)
            make.right.equalTo(self.view).offset(-50)
        }
        
    }
    
    func mapButtonTapped() {
        self.delegate?.loadHereTab()
    }
    
    func searchButtonTapped() {
        self.delegate?.loadSearchInHereTab()
    }
    
    func reportButtonTapped(sender: UIButton) {
        loadReportScreen(nil)
    }
    
}


protocol MyCarNoCheckinViewControllerDelegate {
    func loadHereTab()
    func loadSearchInHereTab()
}
