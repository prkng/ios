//
//  PPSettingsCell.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2016-01-26.
//  Copyright © 2016 PRKNG. All rights reserved.
//

import UIKit
import MessageUI

class PPSettingsViewController: AbstractViewController, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate, CardIOPaymentViewControllerDelegate, PPHeaderViewDelegate {
    
    //user must have credit cards populated
    private var ppUser: ParkingPandaUser
    private var creditCards: [ParkingPandaCreditCard]
    private var redCells = [String]()
    
    private let statusView = UIView()
    private let headerView = PPHeaderView()
    private let tableView = PRKCachedTableView()
    
    private var brand: String = Settings.getCarDescription()["brand"] ?? ""
    private var plate: String = Settings.getCarDescription()["plate"] ?? ""
    private var model: String = Settings.getCarDescription()["model"] ?? ""
    private var color: String = Settings.getCarDescription()["color"] ?? ""
    private var phone: String = Settings.getCarDescription()["phone"] ?? ""

    private(set) var BACKGROUND_COLOR = Styles.Colors.stone
    private(set) var BACKGROUND_TEXT_COLOR = Styles.Colors.anthracite1
    private(set) var BACKGROUND_TEXT_COLOR_EMPHASIZED = Styles.Colors.petrol2
    private(set) var FOREGROUND_COLOR = Styles.Colors.cream1
    private(set) var FOREGROUND_TEXT_COLOR = Styles.Colors.anthracite1
    private(set) var FOREGROUND_TEXT_COLOR_EMPHASIZED = Styles.Colors.red2
    
    private(set) var HEADER_HEIGHT = 80
    private(set) var HEADER_FONT = Styles.FontFaces.regular(12)
    private(set) var MIN_FOOTER_HEIGHT = 65
    private(set) var FOOTER_FONT = Styles.FontFaces.regular(12)
    
    private(set) var SMALL_CELL_HEIGHT: CGFloat = 48
    private(set) var BIG_CELL_HEIGHT: CGFloat = 61
    
    init(user: ParkingPandaUser, creditCards: [ParkingPandaCreditCard]) {
        self.ppUser = user
        self.creditCards = creditCards
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = UIView()
        setupViews()
        setupConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenName = "Parking Panda Settings View"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    func handleHeaderTap(tapRec: UITapGestureRecognizer) {
        dismiss()
    }
    
    func setupViews () {
        
        view.backgroundColor = BACKGROUND_COLOR

        statusView.backgroundColor = Styles.Colors.transparentBlack
        self.view.addSubview(statusView)
        
        //TODO: Localize me
        headerView.delegate = self
        headerView.headerText = "PARKING PANDA SETTINGS"
        headerView.showsRightButton = false
        view.addSubview(headerView)
        
        view.addSubview(tableView)
        tableView.tableFooterView = self.tableFooterView()
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = .None
        tableView.dataSource = self
        tableView.delegate = self
        tableView.clipsToBounds = true
    }
    
    func setupConstraints () {
        
        statusView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.view)
            make.bottom.equalTo(self.snp_topLayoutGuideBottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        headerView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.snp_topLayoutGuideBottom)
            make.height.equalTo(HEADER_HEIGHT)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        tableView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.headerView.snp_bottom)
            make.bottom.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
    }

    //MARK: Refresh this view with an API call and a table refresh
    func refresh() {
        
        SVProgressHUD.setBackgroundColor(UIColor.clearColor())
        SVProgressHUD.show()
        
        ParkingPandaOperations.login(username: nil, password: nil, includeCreditCards: true) { (user, error) -> Void in
            
            if user != nil {
                
                self.ppUser = user!
                
                ParkingPandaOperations.getCreditCards(self.ppUser) { (creditCards, error) -> Void in
                    
                    self.creditCards = creditCards

                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.tableView.layer.addFadeAnimation()
                        self.tableView.reloadData()
                        SVProgressHUD.dismiss()
                    })
                }

            } else {
                self.dismiss()
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                SVProgressHUD.dismiss()
            })
            
        }

    }
    
    //MARK: Table Footer View

    func tableFooterView() -> UIView {
        
        let frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: CGFloat(self.MIN_FOOTER_HEIGHT))
        let tableFooterView = UIView(frame: frame)
        tableFooterView.backgroundColor = Styles.Colors.stone
        
        let tableFooterViewLabel = UILabel(frame: frame)
        tableFooterView.addSubview(tableFooterViewLabel)
        
        //TODO: TEXT NEEDS TO BE LOCALIZED
        let line1Attributes = [NSFontAttributeName: self.FOOTER_FONT, NSForegroundColorAttributeName: self.BACKGROUND_TEXT_COLOR]
        let textLine1 = NSMutableAttributedString(string: "Information used and collected solely by Parking Panda.", attributes: line1Attributes)
        
        let line2Attributes = [NSFontAttributeName: self.FOOTER_FONT, NSForegroundColorAttributeName: self.BACKGROUND_TEXT_COLOR, NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
        let textLine2 = NSAttributedString(string: "Learn more about Parking Panda", attributes: line2Attributes)
        
        textLine1.appendAttributedString(NSAttributedString(string: "\n"))
        textLine1.appendAttributedString(textLine2)
        
        tableFooterViewLabel.numberOfLines = 0
        tableFooterViewLabel.textAlignment = .Center
        tableFooterViewLabel.attributedText = textLine1
        
        let newHeight = tableFooterViewLabel.intrinsicContentSize().height > CGFloat(self.MIN_FOOTER_HEIGHT) ? tableFooterViewLabel.intrinsicContentSize().height + 40 : CGFloat(self.MIN_FOOTER_HEIGHT)
        
        tableFooterView.frame.size = CGSize(width: UIScreen.mainScreen().bounds.width, height: newHeight)
        
        tableFooterViewLabel.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(tableFooterView)
        }

        return tableFooterView
    }
    

    //MARK: UITableViewDataSource
    
    //TODO: All these strings need to be localized
    var tableSource: [(String, [SettingsCell])] {
        
        let firstSection = ("", [SettingsCell(cellType: .Segmented, titleText: "Parking lots price", segments: ["hourly".localizedString.uppercaseString , "daily".localizedString.uppercaseString], defaultSegment: (Settings.lotMainRateIsHourly() ? 0 : 1), selectorsTarget: self, switchSelector: "lotRateDisplayValueChanged")
            ])
        
        var paymentMethodSection = [SettingsCell]()
        let addPaymentMethodCell = SettingsCell(titleText: "add_payment_method".localizedString, selectorsTarget: self, cellSelector: "addPaymentMethod", canSelect: true)
        for creditCard in creditCards {
            let card = SettingsCell(userInfo: ["card_io_payment_type": creditCard.paymentType.rawValue, "token": creditCard.token], titleText: creditCard.lastFour, canSelect: false, canDelete: true)
            
            paymentMethodSection.append(card)
        }
        paymentMethodSection.append(addPaymentMethodCell)
        
        let vehicleDescBrandAndPlate = SettingsCell(placeholderTexts: ["brand".localizedString, "license_plate".localizedString], titleTexts: [brand, plate], cellType: .DoubleTextEntry, selectorsTarget: self, callback: "vehicleDescriptionCallback:",
            userInfo: [
                "textFieldTag": 5,
                "keyboardType": UIKeyboardType.Default.rawValue,
                "returnKeyType": UIReturnKeyType.Next.rawValue,
                "autocorrectionType": UITextAutocorrectionType.No.rawValue,
                "redTintOnOrderedCells": [redCells.contains("brand"), redCells.contains("plate")],
                "returnCallback": "cellReturnCallback:"])
        
        let vehicleDescModelAndColor = SettingsCell(placeholderTexts: ["model".localizedString, "color".localizedString], titleTexts: [model, color], cellType: .DoubleTextEntry, selectorsTarget: self, callback: "vehicleDescriptionCallback:",
            userInfo: [
                "textFieldTag": 7,
                "keyboardType": UIKeyboardType.Default.rawValue,
                "returnKeyType": UIReturnKeyType.Next.rawValue,
                "autocorrectionType": UITextAutocorrectionType.No.rawValue,
                "redTintOnOrderedCells": [redCells.contains("model"), redCells.contains("color")],
                "returnCallback": "cellReturnCallback:"])
        
        let vehicleDescPhone = SettingsCell(placeholderText: "phone_number".localizedString, titleText: phone, cellType: .TextEntry, selectorsTarget: self, callback: "vehicleDescriptionCallback:",
            userInfo: [
                "textFieldTag": 9,
                "keyboardType": UIKeyboardType.NumberPad.rawValue,
                "returnKeyType": UIReturnKeyType.Done.rawValue,
                "autocorrectionType": UITextAutocorrectionType.No.rawValue,
                "redTintOnOrderedCells": [redCells.contains("phone")],
                "returnCallback": "cellReturnCallback:"])

        let vehicleDescriptionSection = [vehicleDescBrandAndPlate, vehicleDescModelAndColor]

        let vehicleDescriptionSection2 = ("", [vehicleDescPhone])

        let signOutSection = ("", [
            SettingsCell(cellType: .Basic, titleText: "Sign Out of Parking Panda", selectorsTarget: self, cellSelector: "signOut", canSelect: true, redText: true)
            ])

        return [firstSection,
            ("payment_method", paymentMethodSection),
            ("vehicle_description", vehicleDescriptionSection),
            vehicleDescriptionSection2,
            signOutSection
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

        let section = self.tableSource[indexPath.section]
        if section.0 == "payment_method" {
            
            //the last row in this section should be to add a credit card
            if indexPath.row == section.1.count - 1 {
                
                var addCreditCardCell = tableView.dequeueReusableCellWithIdentifier("add_credit_card") as? PPAddCreditCardCell
                if addCreditCardCell == nil {
                    addCreditCardCell = PPAddCreditCardCell(reuseIdentifier: "add_credit_card")
                }
                self.tableView.cachedCells.append(addCreditCardCell!)
                return addCreditCardCell!

            } else {
                
                let rawCardIOCardType = settingsCell.userInfo["card_io_payment_type"] as? Int ?? 0
                let cardIOCardType = CardIOCreditCardType(rawValue: rawCardIOCardType) ?? .Unrecognized
                let cardToken = settingsCell.userInfo["token"] as? String ?? ""
                
                let reuse = "cc_" + String(rawCardIOCardType) + "_" + cardToken
                
                var cell = tableView.dequeueReusableCellWithIdentifier(reuse) as? PPCreditCardCell
                if cell == nil {
                    cell = PPCreditCardCell(creditCardType: cardIOCardType, reuseIdentifier: reuse)
                }
                cell?.creditCardNumber = settingsCell.titleText
                self.tableView.cachedCells.append(cell!)
                return cell!

            }
        }
        
        let cell = settingsCell.tableViewCell(tableView)
        self.tableView.cachedCells.append(cell)
        return cell
    }
    
    
    //MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch(editingStyle) {
        case .Delete:
            let settingsCell = tableSource[indexPath.section].1[indexPath.row]
            SVProgressHUD.setBackgroundColor(UIColor.clearColor())
            SVProgressHUD.show()
            let cardToken = settingsCell.userInfo["token"] as? String ?? ""
            ParkingPandaOperations.deleteCreditCard(self.ppUser, token: cardToken, completion: { (error) -> Void in
                self.refresh()
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    SVProgressHUD.dismiss()
                })
            })
        case .Insert, .None:
            break
        }
    }
    
    @available(iOS 8.0, *)
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let settingsCell = tableSource[indexPath.section].1[indexPath.row]
        if settingsCell.canDelete {
            let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "delete".localizedString, handler: { (action: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
                SVProgressHUD.setBackgroundColor(UIColor.clearColor())
                SVProgressHUD.show()
                let cardToken = settingsCell.userInfo["token"] as? String ?? ""
                ParkingPandaOperations.deleteCreditCard(self.ppUser, token: cardToken, completion: { (error) -> Void in
                    self.refresh()
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        SVProgressHUD.dismiss()
                    })
                })
            })
            return [deleteAction]
        }
        return []
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        let settingsCell = tableSource[indexPath.section].1[indexPath.row]
        if settingsCell.canDelete {
            return UITableViewCellEditingStyle.Delete
        }
        return UITableViewCellEditingStyle.None
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let settingsCell = tableSource[indexPath.section].1[indexPath.row]
        return settingsCell.canDelete
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let settingsCell = tableSource[indexPath.section].1[indexPath.row]
        return settingsCell.canSelect
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let settingsCell = tableSource[indexPath.section].1[indexPath.row]
        if settingsCell.selectorsTarget != nil && settingsCell.cellSelector != nil {
            settingsCell.selectorsTarget!.performSelector(Selector(settingsCell.cellSelector!))
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return BIG_CELL_HEIGHT
        default: return SMALL_CELL_HEIGHT
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 0 //the slider cell
        case 3: return 4 //second vehicle description cell
        case 4: return 30 //sign out cell
        default: return BIG_CELL_HEIGHT
        }

    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerText = tableSource[section].0
        return GeneralTableHelperViews.sectionHeaderView(headerText)
    }
    
    //MARK: selector functions
    
    func lotRateDisplayValueChanged() {
        let currentValue = Settings.lotMainRateIsHourly()
        Settings.setLotMainRateIsHourly(!currentValue)
    }
    
    func vehicleDescriptionCallback(sender: AnyObject?) {
        if let timer = sender as? NSTimer {
            if let dict = timer.userInfo as? [String: String] {
                brand = dict["brand".localizedString] ?? brand
                plate = dict["license_plate".localizedString] ?? plate
                model = dict["model".localizedString] ?? model
                color = dict["color".localizedString] ?? color
                phone = dict["phone_number".localizedString] ?? phone
            }
            timer.invalidate()
        }
    }
    
    func cellReturnCallback(sender: AnyObject?) {
        if let timer = sender as? NSTimer {
            if let dict = timer.userInfo as? [String: Int] {
                let nextTag = (dict["textFieldTag"] ?? 0) + 1
                if let nextTextField = tableView.viewWithTag(nextTag) as? UITextField {
                    nextTextField.becomeFirstResponder()
                } else {
                    tappedNextButton()
                }
            }
            timer.invalidate()
        }
    }

    func signOut() {
        ParkingPandaOperations.logout()
        dismiss()
    }
    
    func addPaymentMethod() {
        let paymentVC = CardIOPaymentViewController(paymentDelegate: self)
        paymentVC.hideCardIOLogo = true
        paymentVC.keepStatusBarStyle = true
        paymentVC.guideColor = Styles.Colors.red2
        paymentVC.navigationBarStyle = .Black
        paymentVC.navigationBar.translucent = false
        //dark style:
        paymentVC.navigationBarTintColor = Styles.Colors.midnight1
        paymentVC.navigationBar.tintColor = Styles.Colors.stone
        
        paymentVC.collectPostalCode = true
        
        if let navVC = self.navigationController {
            navVC.pushViewController(paymentVC, animated: true)
        } else {
            self.presentViewController(paymentVC, animated: true, completion: nil)
        }

    }
    
    func presentWithVC(vc: UIViewController?) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if let rootVC = vc ?? appDelegate.window?.rootViewController {
            if let navVC = rootVC.navigationController {
                navVC.pushViewController(self, animated: true)
            } else {
                rootVC.presentViewControllerFromRight(0.3, viewController: self, completion: nil)
            }
        }

    }
    
    func dismiss() {
        
        if passesValidation() {
            //save the description and dismiss
            let description = [
                "brand" : brand ?? "",
                "plate" : plate ?? "",
                "model" : model ?? "",
                "color" : color ?? "",
                "phone" : phone ?? "",
            ]
            Settings.setCarDescription(description)
            
            if let navVC = self.navigationController {
                navVC.popViewControllerAnimated(true)
            } else {
                self.dismissViewControllerFromLeft(0.3, completion: nil)
            }
        }
    }
    
    func passesValidation(shouldColorCells shouldColorCells: Bool = true) -> Bool {
        let failedValidation = brand.isEmpty || plate.isEmpty || model.isEmpty || color.isEmpty || phone.isEmpty
        
        if failedValidation {
            //TODO: Localize these strings
            GeneralHelper.warnUserWithErrorMessage("Please make sure you have filled out the vehicle description.")
            
            if shouldColorCells {
                redCells = []
                if brand.isEmpty { redCells.append("brand") }
                if plate.isEmpty { redCells.append("plate") }
                if model.isEmpty { redCells.append("model") }
                if color.isEmpty { redCells.append("color") }
                if phone.isEmpty { redCells.append("phone") }
                tableView.reloadDataAnimated()
            }
            
            return false
        }
        
        return true
    }
    
    //MARK: PPHeaderViewDelegate
    func tappedBackButton() {
        dismiss()
    }
    
    func tappedNextButton() {
        tappedBackButton()
    }
    
    //MARK: CardIOPaymentViewControllerDelegate functions
    func userDidCancelPaymentViewController(paymentViewController: CardIOPaymentViewController!) {
        paymentViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func userDidProvideCreditCardInfo(cardInfo: CardIOCreditCardInfo!, inPaymentViewController paymentViewController: CardIOPaymentViewController!) {
        SVProgressHUD.setBackgroundColor(UIColor.clearColor())
        SVProgressHUD.show()
        ParkingPandaOperations.addCreditCard(ppUser, cardInfo: cardInfo) { (creditCard, error) -> Void in
            switch (error!.errorType) {
            case .NoError:
                paymentViewController.dismissViewControllerAnimated(true, completion: nil)
                self.refresh()
            case .API, .Internal, .Network:
                break
            }
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                SVProgressHUD.dismiss()
            })
        }
    }

}

