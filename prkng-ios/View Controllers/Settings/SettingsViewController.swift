//
//  SettingsViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 19/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class SettingsViewController: AbstractViewController {
   
    var topContainer : UIView
    
    var cityContainer : UIView
    var prevCityButton : UIButton
    var nextCityButton : UIButton
    var cityLabel : UILabel
    
    var notificationContainer : UIView
    
    var aboutButton : UIButton
    
    init() {
        
        topContainer = UIView()
        
        cityContainer = UIView()
        prevCityButton = UIButton()
        nextCityButton = UIButton()
        cityLabel = UILabel()
        
        notificationContainer = UIView()
        aboutButton = ViewFactory.bigButton()
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func loadView() {
        self.view = TouchForwardingView()
        setupViews()
        setupConstraints()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.cityLabel.text = Settings.selectedCity()
    }
    
    
    
    func setupViews () {
        
        topContainer.backgroundColor = Styles.Colors.petrol2
        view.addSubview(topContainer)
        
        cityContainer.backgroundColor = Styles.Colors.red2
        view.addSubview(cityContainer)
        
        cityLabel.font = Styles.FontFaces.light(31)
        cityLabel.textColor = Styles.Colors.cream1
        cityContainer.addSubview(cityLabel)
        
        prevCityButton.setImage(UIImage(named: "btn_left"), forState: UIControlState.Normal)
        prevCityButton.addTarget(self, action: "prevCityButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        cityContainer.addSubview(prevCityButton)
        
        nextCityButton.setImage(UIImage(named: "btn_right"), forState: UIControlState.Normal)
        nextCityButton.addTarget(self, action: "nextCityButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        cityContainer.addSubview(nextCityButton)
        
        notificationContainer.backgroundColor = Styles.Colors.stone
        view.addSubview(notificationContainer)
        
        aboutButton.setTitle(NSLocalizedString("about", comment : ""), forState: UIControlState.Normal)
        aboutButton.addTarget(self, action: "aboutButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(aboutButton)
        
    }
    
    func setupConstraints () {
        
        aboutButton.snp_makeConstraints { (make) -> () in
            make.height.equalTo(Styles.Sizes.bigButtonHeight)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        
        notificationContainer.snp_makeConstraints { (make) -> () in
            make.height.equalTo(84)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.aboutButton.snp_top)
        }
        
        cityContainer.snp_makeConstraints { (make) -> () in
            make.height.equalTo(60)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.notificationContainer.snp_top)
        }
        
        topContainer.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.cityContainer.snp_top)
        }
        
        
        cityLabel.snp_makeConstraints { (make) -> () in
            make.center.equalTo(self.cityContainer)
        }
        
        prevCityButton.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(30, 30))
            make.left.equalTo(self.cityContainer).with.offset(32)
            make.centerY.equalTo(self.cityContainer)
        }
        
        nextCityButton.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(30, 30))
            make.right.equalTo(self.cityContainer).with.offset(-32)
            make.centerY.equalTo(self.cityContainer)
        }
        
    }
    
    func aboutButtonTapped() {
    
        NSUserDefaults.standardUserDefaults().removeObjectForKey(AuthUtility.USER_KEY)
        NSUserDefaults.standardUserDefaults().removeObjectForKey(AuthUtility.AUTH_TOKEN_KEY)
        
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    
    func prevCityButtonTapped() {
        
        
        var index : Int = 0
        for city in Settings.availableCities {
            
            if (Settings.selectedCity() == city) {
                break; //found
            }
            index++
        }
        
        index -= 1 // previous
        
        if index < 0 {
            index = Settings.availableCities.count - 1
        }
        
        Settings.setSelectedCity(Settings.availableCities[index])
        
        cityLabel.text = Settings.selectedCity()
        
        
    }
    
    func nextCityButtonTapped () {
        
        var index : Int = 0
        for city in Settings.availableCities {
            
            if (Settings.selectedCity() == city) {
                break; //found
            }
            index++
        }
        
        index++ // get next
        
        if (index > Settings.availableCities.count - 1) {
            index = 0
        }
        
        Settings.setSelectedCity(Settings.availableCities[index])
        
        cityLabel.text = Settings.selectedCity()
        
    }    
    
}
