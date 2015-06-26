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
        searchButton = ViewFactory.bigButton()
        reportButton = ViewFactory.reportButton()
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func loadView() {
        self.view = UIView()
        setupViews()
        setupConstraints()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
        
        reportButton.addTarget(self, action: "reportButtonTapped:", forControlEvents: .TouchUpInside)
        view.addSubview(reportButton)
        
        searchButton.setTitle("search".localizedString.lowercaseString, forState: UIControlState.Normal)
        searchButton.layer.shadowColor = UIColor.blackColor().CGColor
        searchButton.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        searchButton.layer.shadowOpacity = 0.2
        searchButton.layer.shadowRadius = 0.5
        searchButton.addTarget(self, action: "searchButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(searchButton)
        
        parkButton.setTitle("park_now".localizedString.lowercaseString, forState: UIControlState.Normal)
        parkButton.layer.shadowColor = UIColor.blackColor().CGColor
        parkButton.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        parkButton.layer.shadowOpacity = 0.2
        parkButton.layer.shadowRadius = 0.5
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
            make.left.equalTo(self.view).with.offset(30)
            make.right.equalTo(self.view).with.offset(-30)
            make.centerY.equalTo(self.view).multipliedBy(0.8)
        }
        
        reportButton.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(24, 24))
            make.bottom.equalTo(self.parkButton.snp_top).with.offset(-20)
            make.centerX.equalTo(self.view).multipliedBy(1.66)
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
