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

    var parkButton : UIButton
    var searchButton : UIButton
    
    var delegate : MyCarNoCheckinViewControllerDelegate?
    
    init() {
        logoView = UIImageView()
        messageLabel = ViewFactory.bigMessageLabel()
        parkButton = ViewFactory.hugeButton()
        searchButton = ViewFactory.hugeButton()
        reportButton = UIButton()
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
        
        view.addSubview(backgroundImageView)
        
        logoView.image = UIImage(named: "icon_checkin")
        view.addSubview(logoView)
        
        messageLabel.text = "no_checkin_message".localizedString
        view.addSubview(messageLabel)
        
        reportButton.clipsToBounds = true
        reportButton.layer.cornerRadius = 13
        reportButton.layer.borderWidth = 1
        reportButton.titleLabel?.font = Styles.FontFaces.light(12)
        reportButton.setTitle("report_an_error".localizedString.uppercaseString, forState: UIControlState.Normal)
        reportButton.setTitleColor(Styles.Colors.stone, forState: UIControlState.Normal)
        reportButton.layer.borderColor = Styles.Colors.red2.CGColor
        reportButton.backgroundColor = Styles.Colors.red2
        reportButton.addTarget(self, action: "reportButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(reportButton)
        
        searchButton.setTitle("search".localizedString.lowercaseString, forState: UIControlState.Normal)
        searchButton.addTarget(self, action: "searchButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        searchButton.setTitleColor(Styles.Colors.petrol2, forState: .Normal)
        view.addSubview(searchButton)
        
        parkButton.setTitle("park_now".localizedString.lowercaseString, forState: UIControlState.Normal)
        parkButton.addTarget(self, action: "parkButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(parkButton)
    }
    
    func setupConstraints () {
        
        backgroundImageView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }
        
        logoView.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(68, 68))
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.view).multipliedBy(0.4)
        }

        messageLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.view).offset(30)
            make.right.equalTo(self.view).offset(-30)
            make.centerY.equalTo(self.view).multipliedBy(0.8)
        }
        
        reportButton.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.parkButton.snp_top).offset(-20)
            make.size.equalTo(CGSizeMake(155, 26))
            make.centerX.equalTo(self.view)
        }

        parkButton.snp_makeConstraints { (make) -> () in
            make.height.equalTo(Styles.Sizes.hugeButtonHeight)
            make.bottom.equalTo(self.searchButton.snp_top)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        searchButton.snp_makeConstraints { (make) -> () in
            make.height.equalTo(Styles.Sizes.hugeButtonHeight)
            make.bottom.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
    }
    
    func parkButtonTapped() {
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
