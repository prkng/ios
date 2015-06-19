//
//  SettingsViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 19/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class SettingsViewController: AbstractViewController {
    
    let backgroundImageView = UIImageView(image: UIImage(named:"bg_blue_gradient"))
    
    var topContainer : UIView
    
    var profileButton : UIButton
    var profileContainer : UIView
    var profileImageView : UIImageView
    var profileTitleLabel : UILabel
    var profileNameLabel : UILabel
    
    var cityContainer : UIView
    var prevCityButton : UIButton
    var nextCityButton : UIButton
    var cityLabel : UILabel
    
    var notificationsContainer : UIView
    var notificationsLabel : UILabel
    var notificationSelection : SelectionControl
    
    var historyButton : UIButton
    
    var aboutButton : UIButton
    
    var delegate: SettingsViewControllerDelegate?
    
    init() {
        
        topContainer = UIView()
        
        profileButton = UIButton()
        profileContainer = UIView()
        profileImageView = UIImageView()
        profileTitleLabel = ViewFactory.formLabel()
        profileNameLabel = UILabel()
        
        historyButton = ViewFactory.transparentRoundedButton()
        
        cityContainer = UIView()
        prevCityButton = UIButton()
        nextCityButton = UIButton()
        cityLabel = UILabel()
        
        notificationsContainer = UIView()
        notificationsLabel = UILabel()
        notificationSelection = SelectionControl(titles: ["15 " + "minutes_short".localizedString.uppercaseString,
            "30 " + "minutes_short".localizedString.uppercaseString,
            "off".localizedString.uppercaseString])
        
        aboutButton = ViewFactory.hugeButton()
        
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
        
        self.cityLabel.text = Settings.selectedCity()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        // TODO find a better way
        var i : Int = 2 // OFF
        if (Settings.notificationTime() == 15) {
            i = 0
        } else if (Settings.notificationTime() == 30) {
            i = 1
        }
        self.notificationSelection.selectOption(self.notificationSelection.buttons[i])
        
        if let user = AuthUtility.getUser() {
            self.profileNameLabel.text = user.name
            if let imageUrl = user.imageUrl {
                self.profileImageView.sd_setImageWithURL(NSURL(string: imageUrl))
            }
            
        }
    }
    
    func setupViews () {
        
        backgroundImageView.contentMode = .ScaleAspectFill
        view.addSubview(backgroundImageView)
        
        view.addSubview(topContainer)
        
        topContainer.addSubview(profileContainer)
        
        profileImageView.layer.cornerRadius = 34
        profileImageView.clipsToBounds = true
        profileContainer.addSubview(profileImageView)
        
        profileTitleLabel.text = "my_profile".localizedString.uppercaseString
        profileContainer.addSubview(profileTitleLabel)
        
        profileNameLabel.font = Styles.Fonts.h1
        profileNameLabel.textColor = Styles.Colors.cream1
        profileNameLabel.textAlignment = NSTextAlignment.Center
        profileContainer.addSubview(profileNameLabel)
        
        profileButton.addTarget(self, action: "profileButtonTapped:", forControlEvents: .TouchUpInside)
        topContainer.addSubview(profileButton)
        
        historyButton.setTitle("my_history".localizedString.uppercaseString, forState: .Normal)
        historyButton.addTarget(self, action: "historyButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        topContainer.addSubview(historyButton)
        
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
        
        notificationsContainer.backgroundColor = Styles.Colors.stone
        view.addSubview(notificationsContainer)
        
        notificationsLabel.textColor = Styles.Colors.midnight2
        notificationsLabel.font = Styles.FontFaces.light(12)
        notificationsLabel.text = "notifications".localizedString.uppercaseString
        notificationsLabel.textAlignment = NSTextAlignment.Center
        notificationsContainer.addSubview(notificationsLabel)
        
        notificationSelection.buttonSize = CGSizeMake(90, 28)
        notificationSelection.font = Styles.FontFaces.light(17)
        notificationSelection.textColor = Styles.Colors.anthracite1
        notificationSelection.selectedTextColor = Styles.Colors.cream1
        notificationSelection.borderColor = UIColor.clearColor()
        notificationSelection.selectedBorderColor = UIColor.clearColor()
        notificationSelection.buttonBackgroundColor = UIColor.clearColor()
        notificationSelection.selectedButtonBackgroundColor = Styles.Colors.red2
        notificationSelection.addTarget(self, action: "notificationSelectionValueChanged", forControlEvents: UIControlEvents.ValueChanged)
        notificationsContainer.addSubview(notificationSelection)
        
        aboutButton.setTitle("about".localizedString, forState: UIControlState.Normal)
        aboutButton.addTarget(self, action: "aboutButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(aboutButton)
        
    }
    
    func setupConstraints () {
        
        backgroundImageView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }
        
        aboutButton.snp_makeConstraints { (make) -> () in
            make.height.equalTo(Styles.Sizes.bigButtonHeight)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        
        notificationsContainer.snp_makeConstraints { (make) -> () in
            make.height.equalTo(84)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.aboutButton.snp_top)
        }
        
        notificationsLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.notificationsContainer).with.offset(10)
            make.left.equalTo(self.notificationsContainer)
            make.right.equalTo(self.notificationsContainer)
        }
        
        notificationSelection.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.notificationsLabel.snp_bottom).with.offset(5)
            make.bottom.equalTo(self.notificationsContainer)
            make.left.equalTo(self.notificationsContainer).with.offset(-10)
            make.right.equalTo(self.notificationsContainer).with.offset(10)
        }
        
        cityContainer.snp_makeConstraints { (make) -> () in
            make.height.equalTo(60)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.notificationsContainer.snp_top)
        }
        
        topContainer.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.cityContainer.snp_top)
        }
        
        profileContainer.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.topContainer)
            make.centerY.equalTo(self.topContainer).multipliedBy(0.8).priorityLow()
            make.height.equalTo(150)
            make.left.equalTo(self.topContainer).with.offset(20)
            make.right.equalTo(self.topContainer).with.offset(-20)
        }
        
        profileImageView.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.profileContainer)
            make.top.equalTo(self.profileContainer)
            make.size.equalTo(CGSizeMake(68, 68))
        }
        
        profileTitleLabel.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.profileNameLabel.snp_top).with.offset(-3)
            make.left.equalTo(self.profileContainer)
            make.right.equalTo(self.profileContainer)
        }
        
        profileNameLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.profileContainer)
            make.right.equalTo(self.profileContainer)
            make.bottom.equalTo(self.profileContainer)
        }
        
        profileButton.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(profileContainer)
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
        
        historyButton.snp_makeConstraints { (make) -> () in
            make.top.greaterThanOrEqualTo(self.profileContainer.snp_bottom).with.offset(5).priorityHigh()
            make.bottom.equalTo(self.topContainer).with.offset(-15)
            make.centerX.equalTo(self.topContainer)
            make.size.equalTo(CGSizeMake(125, 26))
        }
        
    }
    
    
    func historyButtonTapped() {
        var historyViewController = HistoryViewController()
        historyViewController.settingsDelegate = self.delegate
        self.navigationController?.pushViewController(historyViewController, animated: true)
    }
    
    func aboutButtonTapped() {
        self.navigationController?.pushViewController(AboutViewController(), animated: true)
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
    
    func notificationSelectionValueChanged() {
        switch(notificationSelection.selectedIndex) {
        case 0:
            Settings.setNotificationTime(15)
            break
        case 1:
            Settings.setNotificationTime(30)
            break
        case 2 :
            Settings.setNotificationTime(0)
            break
        default:break
        }
    }
    
    func profileButtonTapped(sender: UIButton) {
        
        if (!AuthUtility.isExternalLogin()) {
            self.navigationController?.pushViewController(EditProfileViewController(), animated: true)
        }
    }
    
}

protocol SettingsViewControllerDelegate {
    func goToPreviousCheckin(checkin: Checkin)
}
