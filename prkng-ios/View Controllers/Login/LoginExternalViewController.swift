//
//  LoginExternalViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 09/05/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class LoginExternalViewController: AbstractViewController {
    
    var user : User
    
    var scrollView : UIScrollView
    var scrollContentView : UIView
    
    var profileContainer : UIView
    var avatarButton : UIButton
    var editProfileLabel : UILabel
    var nameLabel : UILabel
    var emailLabel : UILabel
    
    var changeCityLabel : UILabel
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
    
    var loginButton : UIButton
    
    var delegate : LoginExternalViewControllerDelegate?
    
    var logintype : LoginType
    
    private var BOTTOM_VIEW_HEIGHT = Styles.Sizes.hugeButtonHeight + 60 + 84
    private var USABLE_VIEW_HEIGHT = UIScreen.mainScreen().bounds.size.height
    
    init(usr : User, loginType : LoginType) {
        
        user = usr
        
        logintype = loginType
        
        scrollView = UIScrollView()
        scrollContentView = UIView()
        
        profileContainer = UIView()
        avatarButton = UIButton()
        editProfileLabel = ViewFactory.formLabel()
        nameLabel = UILabel()
        emailLabel = UILabel()
        
        changeCityLabel = ViewFactory.formLabel()
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
        
        
    loginButton = ViewFactory.hugeButton()
        
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
        self.screenName = "Login - Enter FB/G Credentials"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.notificationSelection.selectOption(self.notificationSelection.buttons[0], animated: false)

    }
    
    
    func setupViews () {
        
        view.backgroundColor = Styles.Colors.midnight2
        
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        
        scrollContentView.addSubview(profileContainer)
        
        if (user.imageUrl != nil) {
            let url = NSURL(string: user.imageUrl!)
            avatarButton.sd_setImageWithURL(url, forState: UIControlState.Normal, placeholderImage: UIImage(named: "btn_upload_profile")!)
        }
        avatarButton.clipsToBounds = true
        avatarButton.layer.cornerRadius = 25.5
        profileContainer.addSubview(avatarButton)
        
        editProfileLabel.text = "edit_profile".localizedString.uppercaseString
        profileContainer.addSubview(editProfileLabel)
        
        nameLabel.font = Styles.Fonts.h1
        nameLabel.textColor = Styles.Colors.cream1
        nameLabel.textAlignment = NSTextAlignment.Center
        nameLabel.text = user.name
        profileContainer.addSubview(nameLabel)
        
        emailLabel.font = Styles.FontFaces.light(17)
        emailLabel.textColor = Styles.Colors.anthracite1
        emailLabel.textAlignment = NSTextAlignment.Center
        emailLabel.text = user.email
        profileContainer.addSubview(emailLabel)
        
        changeCityLabel.text = "change_my_city".localizedString.uppercaseString
        changeCityLabel.textAlignment = NSTextAlignment.Center
        scrollContentView.addSubview(changeCityLabel)
        
        cityContainer.backgroundColor = Styles.Colors.red2
        scrollContentView.addSubview(cityContainer)
        
        cityLabel.font = Styles.Fonts.h1
        cityLabel.textColor = Styles.Colors.cream1
        cityLabel.text = Settings.selectedCity().rawValue
        cityContainer.addSubview(cityLabel)
        
        prevCityButton.setImage(UIImage(named: "btn_left"), forState: UIControlState.Normal)
        prevCityButton.addTarget(self, action: "prevCityButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        cityContainer.addSubview(prevCityButton)
        
        nextCityButton.setImage(UIImage(named: "btn_right"), forState: UIControlState.Normal)
        nextCityButton.addTarget(self, action: "nextCityButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        cityContainer.addSubview(nextCityButton)
        
        notificationsContainer.backgroundColor = Styles.Colors.stone
        scrollContentView.addSubview(notificationsContainer)
        
        notificationsLabel.textColor = Styles.Colors.midnight2
        notificationsLabel.font = Styles.FontFaces.light(12)
        notificationsLabel.text = "notifications".localizedString.uppercaseString
        notificationsLabel.textAlignment = NSTextAlignment.Left
        notificationsContainer.addSubview(notificationsLabel)
        
        notificationSelection.buttonSize = CGSizeMake(90, 28)
        notificationSelection.addTarget(self, action: "notificationSelectionValueChanged", forControlEvents: UIControlEvents.ValueChanged)
        notificationSelection.fixedWidth = 20
        notificationsContainer.addSubview(notificationSelection)
        
        loginButton.setTitle("login".localizedString, forState: UIControlState.Normal)
        loginButton.addTarget(self, action: "loginButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        scrollContentView.addSubview(loginButton)
    
        separator1.backgroundColor = Styles.Colors.transparentBlack
        separator2.backgroundColor = Styles.Colors.transparentWhite
        separator3.backgroundColor = Styles.Colors.transparentBlack
        scrollContentView.addSubview(separator1)
        scrollContentView.addSubview(separator2)
        scrollContentView.addSubview(separator3)
    
    }
    
    func setupConstraints () {
        
        // step one
        scrollView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view)
            make.centerX.equalTo(self.view)
            make.size.equalTo(self.view)
        }
        
        scrollContentView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.scrollView)
            make.size.equalTo(CGSizeMake(UIScreen.mainScreen().bounds.width, self.USABLE_VIEW_HEIGHT))
        }
        
        
        profileContainer.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.scrollContentView)
            make.centerY.equalTo(self.scrollContentView).with.offset(-self.BOTTOM_VIEW_HEIGHT)
        }
        
        avatarButton.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.profileContainer)
            make.centerX.equalTo(self.profileContainer)
            make.size.equalTo(CGSizeMake(55, 55))
        }
        
        editProfileLabel.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.profileContainer)
            make.top.equalTo(self.avatarButton.snp_bottom).with.offset(16)
        }
        
        
        nameLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.editProfileLabel.snp_bottom).with.offset(9)
            make.left.equalTo(self.profileContainer).with.offset(10)
            make.right.equalTo(self.profileContainer).with.offset(-10)
        }
        
        
        emailLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.nameLabel.snp_bottom).with.offset(25)
            make.left.equalTo(self.profileContainer).with.offset(10)
            make.right.equalTo(self.profileContainer).with.offset(-10)
        }
        
        
        changeCityLabel.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.cityContainer.snp_top).with.offset(-5)
            make.left.equalTo(self.scrollContentView).with.offset(10)
            make.right.equalTo(self.scrollContentView).with.offset(-10)
        }
        
        cityContainer.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.notificationsContainer.snp_top)
            make.left.equalTo(self.scrollContentView)
            make.right.equalTo(self.scrollContentView)
            make.height.equalTo(60)
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
        
        
        notificationsContainer.snp_makeConstraints { (make) -> () in
            make.height.equalTo(60)
            make.left.equalTo(self.scrollContentView)
            make.right.equalTo(self.scrollContentView)
            make.bottom.equalTo(self.loginButton.snp_top)
        }
        
        notificationsLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.notificationsContainer).with.offset(30)
            make.centerY.equalTo(self.notificationsContainer)
        }
        
        notificationSelection.snp_makeConstraints { (make) -> () in
            make.width.greaterThanOrEqualTo(164) //42(15 min)+39(30 min)+23(off)+60(spacing is 3*20)
            make.right.equalTo(self.notificationsContainer).with.offset(-20).priorityHigh()
            make.top.equalTo(self.notificationsContainer)
            make.bottom.equalTo(self.notificationsContainer)
        }
        
        
        separator1.snp_makeConstraints { (make) -> () in
            make.height.equalTo(0.5)
            make.left.equalTo(self.scrollContentView)
            make.right.equalTo(self.scrollContentView)
            make.top.equalTo(self.notificationsContainer.snp_bottom)
        }
        
        separator2.snp_makeConstraints { (make) -> () in
            make.height.equalTo(0.5)
            make.left.equalTo(self.scrollContentView)
            make.right.equalTo(self.scrollContentView)
            make.top.equalTo(self.separator1.snp_bottom)
        }
        
        loginButton.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.scrollContentView)
            make.right.equalTo(self.scrollContentView)
            make.bottom.equalTo(self.scrollContentView)
            make.height.equalTo(Styles.Sizes.hugeButtonHeight)
        }
        
    }
    
    
    func loginButtonTapped () {
        
        Settings.setSelectedCity(Settings.City(rawValue: cityLabel.text!)!)
        
        if self.delegate != nil {
            delegate!.didLoginExternal(logintype)
        }
        
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
        
        cityLabel.text = Settings.selectedCity().rawValue
        
        
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
        
        cityLabel.text = Settings.selectedCity().rawValue
        
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
        
}


protocol LoginExternalViewControllerDelegate {
    func didLoginExternal(loginType : LoginType)
}