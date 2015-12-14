//
//  SettingsViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 19/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: AbstractViewController, MFMailComposeViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
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
    
    let tableView = UITableView()

    var sendLogButton : UIButton
    
    var delegate: SettingsViewControllerDelegate?
    
    private(set) var CITY_CONTAINER_HEIGHT = 48
    private(set) var SMALL_CELL_HEIGHT: CGFloat = 48
    private(set) var BIG_CELL_HEIGHT: CGFloat = 61
    
    init() {
        
        topContainer = UIView()
        
        profileButton = UIButton()
        profileContainer = UIView()
        profileImageView = UIImageView()
        profileTitleLabel = ViewFactory.formLabel()
        profileNameLabel = UILabel()
        
        cityContainer = TouchForwardingView()
        prevCityButton = UIButton()
        nextCityButton = UIButton()
        cityLabel = UILabel()
        
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
        
        if (AuthUtility.loginType() == .Facebook){
            profileTitleLabel.text = "login_edit_message_facebook".localizedString.uppercaseString
        } else if (AuthUtility.loginType() == .Google){
            profileTitleLabel.text = "login_edit_message_google".localizedString.uppercaseString
        } else {
            profileTitleLabel.text = "edit_profile".localizedString.uppercaseString
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.cityLabel.text = Settings.selectedCity().displayName
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let debugFeaturesOn = NSUserDefaults.standardUserDefaults().boolForKey("enable_debug_features")
        sendLogButton.hidden = !debugFeaturesOn
        
        if let user = AuthUtility.getUser() {
            self.profileNameLabel.text = user.name
            if let imageUrl = user.imageUrl {
                self.profileImageView.sd_setImageWithURL(NSURL(string: imageUrl))
            }
            
        }
        
        self.tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, self.tableView.numberOfSections)), withRowAnimation: .None)
    }
    
    func setupViews () {
        
        backgroundImageView.contentMode = .ScaleAspectFill
        view.addSubview(backgroundImageView)
//        view.backgroundColor = Styles.Colors.midnight1
        
        view.addSubview(tableView)
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: CGFloat(self.CITY_CONTAINER_HEIGHT + 120)))
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = .None
        tableView.dataSource = self
        tableView.delegate = self
        tableView.clipsToBounds = true

        topContainer.backgroundColor = Styles.Colors.midnight1
        view.addSubview(topContainer)
        
        topContainer.addSubview(profileContainer)
        
        profileImageView.layer.cornerRadius = 18
        profileImageView.clipsToBounds = true
        profileContainer.addSubview(profileImageView)
        
        profileTitleLabel.font = Styles.FontFaces.regular(10)
        profileTitleLabel.textColor = Styles.Colors.anthracite1
        profileTitleLabel.textAlignment = .Left
        profileContainer.addSubview(profileTitleLabel)
        
        profileNameLabel.font = Styles.Fonts.h3
        profileNameLabel.textColor = Styles.Colors.cream1
        profileNameLabel.textAlignment = .Left
        profileContainer.addSubview(profileNameLabel)
        
        profileButton.addTarget(self, action: "profileButtonTapped:", forControlEvents: .TouchUpInside)
        topContainer.addSubview(profileButton)
        
        cityContainer.backgroundColor = Styles.Colors.red2
        topContainer.addSubview(cityContainer)
        
        cityLabel.font = Styles.Fonts.h3
        cityLabel.textColor = Styles.Colors.cream1
        cityContainer.addSubview(cityLabel)
        
        prevCityButton.setImage(UIImage(named: "btn_left"), forState: UIControlState.Normal)
        prevCityButton.addTarget(self, action: "prevCityButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        cityContainer.addSubview(prevCityButton)
        
        nextCityButton.setImage(UIImage(named: "btn_right"), forState: UIControlState.Normal)
        nextCityButton.addTarget(self, action: "nextCityButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        cityContainer.addSubview(nextCityButton)
        
        sendLogButton.addTarget(self, action: "sendLogButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(sendLogButton)
        
    }
    
    func setupConstraints () {
        
        backgroundImageView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }
        
        cityContainer.snp_makeConstraints { (make) -> () in
            make.height.equalTo(self.CITY_CONTAINER_HEIGHT)
            make.left.equalTo(self.topContainer)
            make.right.equalTo(self.topContainer)
            make.top.equalTo(self.profileContainer.snp_bottom)
        }
        
        topContainer.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.snp_topLayoutGuideBottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(120+self.CITY_CONTAINER_HEIGHT)
        }
        
        profileContainer.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.topContainer)
            make.height.equalTo(120)
            make.left.equalTo(self.topContainer)
            make.right.equalTo(self.topContainer)
        }
        
        profileImageView.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.view).offset(34)
            make.centerY.equalTo(self.profileContainer)
            make.size.equalTo(CGSizeMake(36, 36))
        }
        
        profileTitleLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.profileImageView.snp_right).offset(20)
            make.bottom.equalTo(self.profileImageView).offset(1)
            make.right.equalTo(self.profileContainer)
        }
        
        profileNameLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.profileImageView.snp_right).offset(20)
            make.top.equalTo(self.profileImageView).offset(-2)
            make.right.equalTo(self.profileContainer)
        }
        
        profileButton.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(profileContainer)
        }
        
        cityLabel.snp_makeConstraints { (make) -> () in
            make.center.equalTo(self.cityContainer)
        }
        
        prevCityButton.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSize(width: 30, height: 30))
            make.left.equalTo(self.cityContainer).offset(5)
            make.centerY.equalTo(self.cityContainer)
        }
        
        nextCityButton.snp_makeConstraints { (make) -> () in
            make.size.equalTo(CGSize(width: 30, height: 30))
            make.right.equalTo(self.cityContainer).offset(-5)
            make.centerY.equalTo(self.cityContainer)
        }
        
        tableView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.snp_topLayoutGuideBottom)
            make.bottom.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
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
    
    func showSupport() {
        if MFMailComposeViewController.canSendMail() {
            let mailVC = MFMailComposeViewController()
            mailVC.mailComposeDelegate = self
            mailVC.setSubject("Support")
            mailVC.setToRecipients(["support@prk.ng"])
            self.presentViewController(mailVC, animated: true, completion: nil)
        } else {
            let alert = UIAlertView()
            alert.title = "no_mail_accounts_title".localizedString
            alert.message = "no_mail_accounts_body".localizedString
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }
    
    func showAbout() {
        self.navigationController?.pushViewController(AboutViewController(), animated: true)
    }
    
    func showGettingStarted() {
        let tutorialVC = TutorialViewController()
        self.presentViewController(tutorialVC, animated: true, completion: nil)
    }
    
    func sendToAppStore() {
        UIApplication.sharedApplication().openURL(NSURL(string: "itms-apps://itunes.apple.com/app/id999834216")!)
    }
    
    func showFaq() {
        let webViewController = PRKWebViewController(englishUrl: "https://prk.ng/faq/", frenchUrl: "https://prk.ng/fr/faq/")
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    func showTerms() {
        let webViewController = PRKWebViewController(englishUrl: "https://prk.ng/terms/", frenchUrl: "https://prk.ng/fr/conditions/")
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    func showPrivacy() {
        let webViewController = PRKWebViewController(englishUrl: "https://prk.ng/privacy", frenchUrl: "https://prk.ng/fr/privacy")
        self.navigationController?.pushViewController(webViewController, animated: true)
    }
    
    func showShareSheet() {
        
        let text = "prkng_share_copy".localizedString
        let url = NSURL(string:"https://prk.ng/")!
        
        let activityViewController = UIActivityViewController( activityItems: [text, url], applicationActivities: nil)
        self.navigationController?.presentViewController(activityViewController, animated: true, completion: nil)
    }

    func signOut() {
        SVProgressHUD.show()
        Settings.logout()
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
        
        self.tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, self.tableView.numberOfSections)), withRowAnimation: .Fade)

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
        
        self.tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, self.tableView.numberOfSections)), withRowAnimation: .Fade)

    }
    
    func notificationSelectionValueChanged() {
        if Settings.notificationTime() == 0 {
            Settings.setNotificationTime(30)
        } else {
            Settings.setNotificationTime(0)
        }
    }

    func commercialPermitFilterValueChanged() {
        let currentValue = Settings.shouldFilterForCommercialPermit()
        Settings.setShouldFilterForCommercialPermit(!currentValue)
    }

    func residentialPermitFilterValueChanged() {
        let currentValue = Settings.shouldFilterForResidentialPermit()
        Settings.setShouldFilterForResidentialPermit(!currentValue)
    }
    
    func residentialPermitFilterValueNeedsAddition() {
        if Settings.residentialPermits().isEmpty {
            //bring up the rolly thingy
            CityOperations.getSupportedResidentialPermits(Settings.selectedCity()) { (completed, permits) -> Void in
                if completed {
                    let pickerVC = UIPickerViewController(pickerValues: permits, completion: { (selectedValue) -> Void in
                        Settings.setResidentialPermit(selectedValue)
                        Settings.setShouldFilterForResidentialPermit(selectedValue != nil)
                        self.tableView.reloadData()
                    })
                    self.presentAsModalWithTransparency(pickerVC, completion: nil)
                }
            }
        } else {
            Settings.setResidentialPermit(nil)
            Settings.setShouldFilterForResidentialPermit(false)
            self.tableView.reloadData()
        }
    }

    func snowRemovalFilterValueChanged() {
        let currentValue = Settings.shouldFilterForSnowRemoval()
        Settings.setShouldFilterForSnowRemoval(!currentValue)
    }

    func hideCar2GoValueChanged() {
        let currentValue = Settings.hideCar2Go()
        Settings.setHideCar2Go(!currentValue)
    }

    func hideAutomobileValueChanged() {
        let currentValue = Settings.hideAutomobile()
        Settings.setHideAutomobile(!currentValue)
    }

    func hideCommunautoValueChanged() {
        let currentValue = Settings.hideCommunauto()
        Settings.setHideCommunauto(!currentValue)
    }
    
    func hideZipcarValueChanged() {
        let currentValue = Settings.hideZipcar()
        Settings.setHideZipcar(!currentValue)
    }
    
    func lotRateDisplayValueChanged() {
        let currentValue = Settings.lotMainRateIsHourly()
        Settings.setLotMainRateIsHourly(!currentValue)
    }
    
    func profileButtonTapped(sender: UIButton) {
        if AuthUtility.loginType()! == LoginType.Email {
            self.navigationController?.pushViewController(EditProfileViewController(), animated: true)
        }
    }
    
    func handleCommunautoSignInButtonTap() {
        
        CarSharingOperations.CommunautoAutomobile.getAndSaveCommunautoCustomerID { (id) -> Void in
            if id == nil {
                //we need to ask the user to log in
                let vc = CarSharingOperations.CommunautoAutomobile.loginVC
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                //we have a value, so perform a log out
                //calling getAndSaveCommunautoCustomerID already logged us out, so just update the cell
                CarSharingOperations.CommunautoAutomobile.deleteCommunautoCustomerID()
                self.tableView.reloadData()
            }
            
        }
        
    }

    func handleCar2GoSignInButtonTap() {
        CarSharingOperations.Car2Go.isLoggedInAsynchronous(shouldValidateToken: true, completion: { (loggedIn) -> Void in
            if loggedIn {
                CarSharingOperations.Car2Go.logout()
                self.tableView.reloadData()
            } else {
                CarSharingOperations.Car2Go.getAndSaveCar2GoToken({ (token, tokenSecret) -> Void in
                })
            }
        })
    }

    //MARK: UITableViewDataSource
        
    var tableSource: [(String, [SettingsCell])] {
        
        var firstSection = [SettingsCell]()
        var carSharingSection = [SettingsCell]()
        
        let alertCell = SettingsCell(switchValue: Settings.notificationTime() != 0, titleText: "settings_alert".localizedString, subtitleText: "settings_alert_text".localizedString, parentVC: self, switchSelector: "notificationSelectionValueChanged")
        let commercialPermitCell = SettingsCell(switchValue: Settings.shouldFilterForCommercialPermit(), titleText: "settings_commercial_permit".localizedString, subtitleText: "settings_commercial_permit_text".localizedString, parentVC: self, switchSelector: "commercialPermitFilterValueChanged")
        let snowRemovalCell = SettingsCell(switchValue: Settings.shouldFilterForSnowRemoval(), titleText: "settings_snow_removal".localizedString, subtitleText: "settings_snow_removal_text".localizedString, parentVC: self, switchSelector: "snowRemovalFilterValueChanged")
        let residentialPermitCell = SettingsCell(switchValue: Settings.shouldFilterForResidentialPermit(), titleText: "settings_residential_permit".localizedString, subtitleText: "settings_residential_permit_text".localizedString, parentVC: self, switchSelector: "residentialPermitFilterValueChanged", buttonSelector: "residentialPermitFilterValueNeedsAddition", rightSideText: Settings.residentialPermit())
        
//        let secondRow = ("garages".localizedString, [SettingsCell(titleText: "Parking lots price", segments: ["hourly".localizedString.uppercaseString , "daily".localizedString.uppercaseString], defaultSegment: (Settings.lotMainRateIsHourly() ? 0 : 1), parentVC: self, selector: "lotRateDisplayValueChanged"),
//            SettingsCell(cellType: .Service, titleText: "ParkingPanda")])

        let car2goCell = SettingsCell(titleText: "Car2Go", signedIn: CarSharingOperations.Car2Go.isLoggedInSynchronous(shouldValidateToken: false), switchValue: !Settings.hideCar2Go(), parentVC: self, switchSelector: "hideCar2GoValueChanged", buttonSelector: "handleCar2GoSignInButtonTap")
        let automobileCell = SettingsCell(titleText: "Automobile", signedIn: Settings.communautoCustomerID() != nil, switchValue: !Settings.hideAutomobile(), parentVC: self, switchSelector: "hideAutomobileValueChanged", buttonSelector: "handleCommunautoSignInButtonTap")
        let communautoCell = SettingsCell(titleText: "Communauto", signedIn: Settings.communautoCustomerID() != nil, switchValue: !Settings.hideCommunauto(), parentVC: self, switchSelector: "hideCommunautoValueChanged", buttonSelector: "handleCommunautoSignInButtonTap")
        let zipcarCell = SettingsCell(titleText: "Zipcar", signedIn: nil, switchValue: !Settings.hideZipcar(), parentVC: self, switchSelector: "hideZipcarValueChanged")
        
        firstSection = [alertCell]
        
        if Settings.selectedCity().name == "montreal" {
            firstSection = [alertCell, residentialPermitCell, snowRemovalCell]
            carSharingSection = [car2goCell, automobileCell, communautoCell]
        } else if Settings.selectedCity().name == "quebec" {
            firstSection = [alertCell, residentialPermitCell]
            carSharingSection = [automobileCell, communautoCell]
        } else if Settings.selectedCity().name == "seattle" {
            carSharingSection = [car2goCell, zipcarCell]
        } else if Settings.selectedCity().name == "newyork" {
            firstSection.append(commercialPermitCell)
            carSharingSection = [car2goCell, zipcarCell]
        }
        
        let generalSection = [SettingsCell(cellType: .Basic, titleText: "support".localizedString, parentVC: self, switchSelector: "showSupport"),
            SettingsCell(cellType: .Basic, titleText: "getting_started_tour".localizedString, parentVC: self, switchSelector: "showGettingStarted"),
            SettingsCell(cellType: .Basic, titleText: "share".localizedString, parentVC: self, switchSelector: "showShareSheet"),
            SettingsCell(cellType: .Basic, titleText: "rate_us_message".localizedString, parentVC: self, switchSelector: "sendToAppStore"),
            SettingsCell(cellType: .Basic, titleText: "faq".localizedString, parentVC: self, switchSelector: "showFaq"),
            SettingsCell(cellType: .Basic, titleText: "terms_conditions".localizedString, parentVC: self, switchSelector: "showTerms"),
            SettingsCell(cellType: .Basic, titleText: "sign_out".localizedString, parentVC: self, switchSelector: "signOut")]
        
        return [("", firstSection),
            ("car_sharing".localizedString, carSharingSection),
            ("general".localizedString, generalSection)
        ]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableSource.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableSource[section].1.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let settingsCell = tableSource[indexPath.section].1[indexPath.row]
        switch settingsCell.cellType {
            
        case .Switch, .PermitSwitch:
            var cell = tableView.dequeueReusableCellWithIdentifier("switch" + settingsCell.titleText + (settingsCell.rightSideText ?? "")) as? SettingsSwitchCell
            if cell == nil {
                cell = SettingsSwitchCell(style: .Default, reuseIdentifier: "switch" + settingsCell.titleText + (settingsCell.rightSideText ?? ""))
            }
            cell!.titleText = settingsCell.titleText
            cell!.subtitleText = settingsCell.subtitleText
            cell!.switchOn = settingsCell.switchValue ?? false
            cell!.parentVC = settingsCell.parentVC
            cell!.selector = settingsCell.switchSelector
            cell!.buttonSelector = settingsCell.buttonSelector
            cell!.rightSideText = settingsCell.rightSideText
            return cell!
            
        case .Segmented:
            var cell = tableView.dequeueReusableCellWithIdentifier("segmented" + settingsCell.titleText) as? SettingsSegmentedCell
            if cell == nil {
                cell = SettingsSegmentedCell(segments: settingsCell.segments, reuseIdentifier: "segmented" + settingsCell.titleText, parentVC: settingsCell.parentVC, selector: settingsCell.switchSelector)
            }
            cell!.titleText = settingsCell.titleText
            cell!.selectedSegment = settingsCell.defaultSegment
            return cell!
            
        case .Service, .ServiceSwitch:
            var cell = tableView.dequeueReusableCellWithIdentifier("service" + settingsCell.titleText) as? SettingsServiceSwitchCell
            if cell == nil {
                cell = SettingsServiceSwitchCell(style: .Default, reuseIdentifier: "service" + settingsCell.titleText)
            }
            cell!.titleText = settingsCell.titleText
            cell!.signedIn = settingsCell.signedIn
            if let switchValue = settingsCell.switchValue {
                cell!.shouldShowSwitch = true
                cell!.switchValue = switchValue
                cell!.parentVC = settingsCell.parentVC
                cell!.switchSelector = settingsCell.switchSelector
                cell!.buttonSelector = settingsCell.buttonSelector
            } else {
                cell!.shouldShowSwitch = false
            }
            cell!.shouldShowSwitch = settingsCell.cellType == SettingsTableViewCellType.ServiceSwitch

            return cell!
            
        case .Basic:
            var cell = tableView.dequeueReusableCellWithIdentifier("basic" + settingsCell.titleText) as? SettingsBasicCell
            if cell == nil {
                cell = SettingsBasicCell(style: .Default, reuseIdentifier: "basic" + settingsCell.titleText)
            }
            cell!.titleText = settingsCell.titleText
            cell!.redText = (tableSource[indexPath.section].0 == "general".localizedString) && indexPath.row == 3
            return cell!
        }
    }
    
    
    //MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return tableSource[indexPath.section].0 == "general".localizedString
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let settingsCell = tableSource[indexPath.section].1[indexPath.row]
        if settingsCell.parentVC != nil && settingsCell.switchSelector != nil {
            settingsCell.parentVC!.performSelector(Selector(settingsCell.switchSelector!))
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return BIG_CELL_HEIGHT
//        case 1:
//            switch indexPath.row {
//            case 0: return BIG_CELL_HEIGHT
//            case 1: return SMALL_CELL_HEIGHT
//            default: return 0
//            }
        case 1: return SMALL_CELL_HEIGHT
        case 2: return SMALL_CELL_HEIGHT
        default: return 0
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 0
        default: return BIG_CELL_HEIGHT
        }

    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerText = tableSource[section].0

        if headerText == "" {
            return nil
        }
        
        let sectionHeader = UIView()
        sectionHeader.backgroundColor = Styles.Colors.stone
        let headerTitle = UILabel()
        headerTitle.font = Styles.FontFaces.bold(12)
        headerTitle.textColor = Styles.Colors.petrol2
        headerTitle.text = headerText
        sectionHeader.addSubview(headerTitle)
        headerTitle.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(sectionHeader).offset(20)
            make.right.equalTo(sectionHeader).offset(-20)
            make.bottom.equalTo(sectionHeader).offset(-10)
        }
        return sectionHeader

    }
    
    //MARK: scroll view delegate for the tableview
    func scrollViewDidScroll(scrollView: UIScrollView) {
//        NSLog("scroll view content offset is (%f,%f)", scrollView.contentOffset.x, scrollView.contentOffset.y)
        let yOffset = scrollView.contentOffset.y
        topContainer.snp_remakeConstraints { (make) -> () in
            make.top.equalTo(self.snp_topLayoutGuideBottom).offset(-yOffset)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(120+self.CITY_CONTAINER_HEIGHT)
        }

    }
    
}

protocol SettingsViewControllerDelegate {
    func goToCoordinate(coordinate: CLLocationCoordinate2D, named name: String, showing: Bool)
    func cityDidChange(fromCity fromCity: City, toCity: City)
}
