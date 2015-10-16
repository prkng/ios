//
//  SettingsViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 19/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: AbstractViewController, MFMailComposeViewControllerDelegate {
    
    let backgroundImageView = UIImageView(image: UIImage(named:"bg_settings"))
    
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

    var separator1: UIView
    var separator2: UIView
    var separator3: UIView

    var historyButton : UIButton
    var aboutButton : UIButton

    var sendLogButton : UIButton
    
    var delegate: SettingsViewControllerDelegate?
    
    private(set) var CITY_CONTAINER_HEIGHT = UIScreen.mainScreen().bounds.height == 480 ? 54 : 60
    
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

        separator1 = UIView()
        separator2 = UIView()
        separator3 = UIView()
        
        aboutButton = ViewFactory.hugeCreamButton()
        sendLogButton = ViewFactory.exclamationButton()
        
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
        self.screenName = "Settings View"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.cityLabel.text = Settings.selectedCity().displayName
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let debugFeaturesOn = NSUserDefaults.standardUserDefaults().boolForKey("enable_debug_features")
        sendLogButton.hidden = !debugFeaturesOn
        
        // TODO find a better way
        var i : Int = 2 // OFF
        if (Settings.notificationTime() == 15) {
            i = 0
        } else if (Settings.notificationTime() == 30) {
            i = 1
        }
        self.notificationSelection.selectOption(self.notificationSelection.buttons[i], animated: false)
        
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
        
        cityLabel.font = Styles.Fonts.h1
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
        notificationsLabel.textAlignment = NSTextAlignment.Left
        notificationsContainer.addSubview(notificationsLabel)
        
        notificationSelection.buttonSize = CGSizeMake(90, 28)
        notificationSelection.addTarget(self, action: "notificationSelectionValueChanged", forControlEvents: UIControlEvents.ValueChanged)
        notificationSelection.fixedWidth = 20
        notificationsContainer.addSubview(notificationSelection)
        
        aboutButton.setTitle("about".localizedString, forState: UIControlState.Normal)
        aboutButton.addTarget(self, action: "aboutButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(aboutButton)
        
        sendLogButton.addTarget(self, action: "sendLogButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(sendLogButton)
        
        separator1.backgroundColor = Styles.Colors.transparentBlack
        separator2.backgroundColor = Styles.Colors.transparentWhite
        separator3.backgroundColor = Styles.Colors.transparentBlack
        view.addSubview(separator1)
        view.addSubview(separator2)
        view.addSubview(separator3)
        
    }
    
    func setupConstraints () {
        
        backgroundImageView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }
        
        aboutButton.snp_makeConstraints { (make) -> () in
            make.height.equalTo(Styles.Sizes.hugeButtonHeight)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        
        
        notificationsContainer.snp_makeConstraints { (make) -> () in
            make.height.equalTo(60)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.aboutButton.snp_top)
        }
        
        notificationsLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.notificationsContainer).offset(30)
            make.centerY.equalTo(self.notificationsContainer)
        }
        
        notificationSelection.snp_makeConstraints { (make) -> () in
            make.width.equalTo(self.notificationSelection.calculatedWidth())
            make.right.equalTo(self.notificationsContainer).offset(-20).priorityHigh()
            make.top.equalTo(self.notificationsContainer)
            make.bottom.equalTo(self.notificationsContainer)
        }

        
        separator1.snp_makeConstraints { (make) -> () in
            make.height.equalTo(0.5)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(self.notificationsContainer.snp_bottom)
        }
        
        separator2.snp_makeConstraints { (make) -> () in
            make.height.equalTo(0.5)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(self.separator1.snp_bottom)
        }
        
        cityContainer.snp_makeConstraints { (make) -> () in
            make.height.equalTo(self.CITY_CONTAINER_HEIGHT)
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
            make.left.equalTo(self.topContainer).offset(20)
            make.right.equalTo(self.topContainer).offset(-20)
        }
        
        profileImageView.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.view).multipliedBy(0.3)
            make.size.equalTo(CGSizeMake(68, 68))
        }
        
        profileTitleLabel.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.profileNameLabel.snp_top).offset(-3)
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
            make.left.equalTo(self.cityContainer).offset(32)
            make.centerY.equalTo(self.cityContainer)
        }
        
        nextCityButton.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(30, 30))
            make.right.equalTo(self.cityContainer).offset(-32)
            make.centerY.equalTo(self.cityContainer)
        }
        
        historyButton.snp_makeConstraints { (make) -> () in
            make.top.greaterThanOrEqualTo(self.profileContainer.snp_bottom).offset(5).priorityHigh()
            make.bottom.equalTo(self.topContainer).offset(-15)
            make.centerX.equalTo(self.topContainer)
            make.size.equalTo(CGSizeMake(125, 26))
        }
        
        sendLogButton.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSizeMake(24, 24))
            make.top.equalTo(self.view).offset(14+20)
            make.right.equalTo(self.view).offset(-20)
        }

    }
    
    func sendLogButtonTapped(sender: UIButton) {
        let mailVC = MFMailComposeViewController()
        mailVC.mailComposeDelegate = self
        let udid = NSUUID().UUIDString
        mailVC.setSubject("Support Ticket - " + udid)
        mailVC.setToRecipients(["ant@prk.ng"])
        if let filePath = Settings.logFilePath() {
            if let fileData = NSData(contentsOfFile: filePath) {
                mailVC.addAttachmentData(fileData, mimeType: "text", fileName: udid + ".log")
                self.presentViewController(mailVC, animated: true, completion: nil)
            }
        }
    }
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

    func historyButtonTapped() {
        let historyViewController = HistoryViewController()
        historyViewController.settingsDelegate = self.delegate
        self.navigationController?.pushViewController(historyViewController, animated: true)
    }
    
    func aboutButtonTapped() {
        self.navigationController?.pushViewController(AboutViewController(), animated: true)
    }
    
    
    func prevCityButtonTapped() {
        
        
        var index : Int = 0
        for city in CityOperations.sharedInstance.availableCities {
            
            if (Settings.selectedCity().name == city.name) {
                break; //found
            }
            index++
        }
        
        index -= 1 // previous
        
        if index < 0 {
            index = CityOperations.sharedInstance.availableCities.count - 1
        }
        
        let previousCity = Settings.selectedCity()
        
        Settings.setSelectedCity(CityOperations.sharedInstance.availableCities[index])
        
        cityLabel.text = Settings.selectedCity().displayName
        
        delegate!.cityDidChange(fromCity: previousCity, toCity: CityOperations.sharedInstance.availableCities[index])
    }
    
    func nextCityButtonTapped () {
        
        var index : Int = 0
        for city in CityOperations.sharedInstance.availableCities {
            
            if (Settings.selectedCity().name == city.name) {
                break; //found
            }
            index++
        }
        
        index++ // get next
        
        if (index > CityOperations.sharedInstance.availableCities.count - 1) {
            index = 0
        }
        
        let previousCity = Settings.selectedCity()

        Settings.setSelectedCity(CityOperations.sharedInstance.availableCities[index])
        
        cityLabel.text = Settings.selectedCity().displayName
        
        delegate!.cityDidChange(fromCity: previousCity, toCity: CityOperations.sharedInstance.availableCities[index])
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
        self.navigationController?.pushViewController(EditProfileViewController(), animated: true)
    }
    
}

protocol SettingsViewControllerDelegate {
    func goToCoordinate(coordinate: CLLocationCoordinate2D, named name: String)
    func cityDidChange(fromCity fromCity: City, toCity: City)
}
