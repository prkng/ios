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
    fileprivate var ppUser: ParkingPandaUser
    fileprivate var creditCards: [ParkingPandaCreditCard]
    fileprivate var redCells = [String]()
    
    fileprivate let statusView = UIView()
    fileprivate let headerView = PPHeaderView()
    fileprivate let tableView = PRKCachedTableView()
    
    fileprivate var brand: String = Settings.getCarDescription()["brand"] ?? ""
    fileprivate var plate: String = Settings.getCarDescription()["plate"] ?? ""
    fileprivate var model: String = Settings.getCarDescription()["model"] ?? ""
    fileprivate var color: String = Settings.getCarDescription()["color"] ?? ""
    fileprivate var phone: String = Settings.getCarDescription()["phone"] ?? ""

    fileprivate(set) var BACKGROUND_COLOR = Styles.Colors.stone
    fileprivate(set) var BACKGROUND_TEXT_COLOR = Styles.Colors.anthracite1
    fileprivate(set) var BACKGROUND_TEXT_COLOR_EMPHASIZED = Styles.Colors.petrol2
    fileprivate(set) var FOREGROUND_COLOR = Styles.Colors.cream1
    fileprivate(set) var FOREGROUND_TEXT_COLOR = Styles.Colors.anthracite1
    fileprivate(set) var FOREGROUND_TEXT_COLOR_EMPHASIZED = Styles.Colors.red2
    
    fileprivate(set) var HEADER_HEIGHT = 80
    fileprivate(set) var HEADER_FONT = Styles.FontFaces.regular(12)
    fileprivate(set) var MIN_FOOTER_HEIGHT = 65
    fileprivate(set) var FOOTER_FONT = Styles.FontFaces.regular(12)
    
    fileprivate(set) var SMALL_CELL_HEIGHT: CGFloat = 48
    fileprivate(set) var BIG_CELL_HEIGHT: CGFloat = 61
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    
    func handleHeaderTap(_ tapRec: UITapGestureRecognizer) {
        dismiss()
    }
    
    func setupViews () {
        
        view.backgroundColor = BACKGROUND_COLOR

        statusView.backgroundColor = Styles.Colors.transparentBlack
        self.view.addSubview(statusView)
        
        headerView.delegate = self
        headerView.headerText = "pp_settings".localizedString.uppercased()
        headerView.showsRightButton = false
        view.addSubview(headerView)
        
        view.addSubview(tableView)
        tableView.tableFooterView = self.tableFooterView()
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
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
        
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        SVProgressHUD.show()
        
        ParkingPandaOperations.login(username: nil, password: nil, includeCreditCards: true) { (user, error) -> Void in
            
            if user != nil {
                
                self.ppUser = user!
                
                ParkingPandaOperations.getCreditCards(self.ppUser) { (creditCards, error) -> Void in
                    
                    self.creditCards = creditCards

                    DispatchQueue.main.async(execute: { () -> Void in
                        self.tableView.layer.addFadeAnimation()
                        self.tableView.reloadData()
                        SVProgressHUD.dismiss()
                    })
                }

            } else {
                self.dismiss()
            }
            
            DispatchQueue.main.async(execute: { () -> Void in
                SVProgressHUD.dismiss()
            })
            
        }

    }
    
    //MARK: Table Footer View

    func tableFooterView() -> UIView {
        
        let frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: CGFloat(self.MIN_FOOTER_HEIGHT))
        let tableFooterView = UIView(frame: frame)
        tableFooterView.backgroundColor = Styles.Colors.stone
        
        let tableFooterViewLabel = UILabel(frame: frame)
        tableFooterView.addSubview(tableFooterViewLabel)
        
        let line1Attributes = [NSFontAttributeName: self.FOOTER_FONT, NSForegroundColorAttributeName: self.BACKGROUND_TEXT_COLOR]
        let textLine1 = NSMutableAttributedString(string: "pp_disclaimer".localizedString, attributes: line1Attributes)
        
        let line2Attributes = [NSFontAttributeName: self.FOOTER_FONT, NSForegroundColorAttributeName: self.BACKGROUND_TEXT_COLOR, NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
        let textLine2 = NSAttributedString(string: "pp_learn_more".localizedString, attributes: line2Attributes)
        
        textLine1.append(NSAttributedString(string: "\n"))
        textLine1.append(textLine2)
        
        tableFooterViewLabel.numberOfLines = 0
        tableFooterViewLabel.textAlignment = .center
        tableFooterViewLabel.attributedText = textLine1
        
        let newHeight = tableFooterViewLabel.intrinsicContentSize.height > CGFloat(self.MIN_FOOTER_HEIGHT) ? tableFooterViewLabel.intrinsicContentSize.height + 40 : CGFloat(self.MIN_FOOTER_HEIGHT)
        
        tableFooterView.frame.size = CGSize(width: UIScreen.main.bounds.width, height: newHeight)
        
        tableFooterViewLabel.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(tableFooterView)
        }

        return tableFooterView
    }
    

    //MARK: UITableViewDataSource
    
    var tableSource: [(String, [SettingsCell])] {
        
        let firstSection = ("", [SettingsCell(cellType: .Segmented, titleText: "parking_lots_price".localizedString, segments: ["hourly".localizedString.uppercased() , "daily".localizedString.uppercased()], defaultSegment: (Settings.lotMainRateIsHourly() ? 0 : 1), selectorsTarget: self, switchSelector: "lotRateDisplayValueChanged")
            ])
        
        var paymentMethodSection = [SettingsCell]()
        let addPaymentMethodCell = SettingsCell(titleText: "add_payment_method".localizedString, selectorsTarget: self, cellSelector: "addPaymentMethod", canSelect: true)
        for creditCard in creditCards {
            let card = SettingsCell(userInfo: ["card_io_payment_type": creditCard.paymentType.rawValue, "token": creditCard.token, "isDefault": creditCard.isDefault, "parking_panda_credit_card": creditCard], titleText: creditCard.lastFour, canSelect: !creditCard.isDefault, canDelete: true)
            
            paymentMethodSection.append(card)
        }
        paymentMethodSection.append(addPaymentMethodCell)
        
        let vehicleDescBrandAndPlate = SettingsCell(placeholderTexts: ["brand".localizedString, "license_plate".localizedString], titleTexts: [brand, plate], cellType: .DoubleTextEntry, selectorsTarget: self, callback: "vehicleDescriptionCallback:",
            userInfo: [
                "textFieldTag": 5,
                "keyboardType": UIKeyboardType.default.rawValue,
                "returnKeyType": UIReturnKeyType.next.rawValue,
                "autocorrectionType": UITextAutocorrectionType.no.rawValue,
                "redTintOnOrderedCells": [redCells.contains("brand"), redCells.contains("plate")],
                "returnCallback": "cellReturnCallback:"])
        
        let vehicleDescModelAndColor = SettingsCell(placeholderTexts: ["model".localizedString, "color".localizedString], titleTexts: [model, color], cellType: .DoubleTextEntry, selectorsTarget: self, callback: "vehicleDescriptionCallback:",
            userInfo: [
                "textFieldTag": 7,
                "keyboardType": UIKeyboardType.default.rawValue,
                "returnKeyType": UIReturnKeyType.next.rawValue,
                "autocorrectionType": UITextAutocorrectionType.no.rawValue,
                "redTintOnOrderedCells": [redCells.contains("model"), redCells.contains("color")],
                "returnCallback": "cellReturnCallback:"])
        
        let vehicleDescPhone = SettingsCell(placeholderText: "phone_number".localizedString, titleText: phone, cellType: .TextEntry, selectorsTarget: self, callback: "vehicleDescriptionCallback:",
            userInfo: [
                "textFieldTag": 9,
                "keyboardType": UIKeyboardType.numberPad.rawValue,
                "returnKeyType": UIReturnKeyType.done.rawValue,
                "autocorrectionType": UITextAutocorrectionType.no.rawValue,
                "redTintOnOrderedCells": [redCells.contains("phone")],
                "returnCallback": "cellReturnCallback:"])

        let vehicleDescriptionSection = [vehicleDescBrandAndPlate, vehicleDescModelAndColor]

        let vehicleDescriptionSection2 = ("", [vehicleDescPhone])

        let signOutSection = ("", [
            SettingsCell(cellType: .Basic, titleText: "pp_sign_out".localizedString, selectorsTarget: self, cellSelector: "signOut", canSelect: true, redText: true)
            ])

        return [firstSection,
            ("payment_method".localizedString, paymentMethodSection),
            ("vehicle_description".localizedString, vehicleDescriptionSection),
            vehicleDescriptionSection2,
            signOutSection
        ]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableSource[section].1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let settingsCell = tableSource[indexPath.section].1[indexPath.row]

        let section = self.tableSource[indexPath.section]
        if section.0 == "payment_method".localizedString {
            
            //the last row in this section should be to add a credit card
            if indexPath.row == section.1.count - 1 {
                
                var addCreditCardCell = tableView.dequeueReusableCell(withIdentifier: "add_credit_card") as? PPAddCreditCardCell
                if addCreditCardCell == nil {
                    addCreditCardCell = PPAddCreditCardCell(reuseIdentifier: "add_credit_card")
                }
                self.tableView.cachedCells.append(addCreditCardCell!)
                return addCreditCardCell!

            } else {
                
                let rawCardIOCardType = settingsCell.userInfo["card_io_payment_type"] as? Int ?? 0
                let cardIOCardType = CardIOCreditCardType(rawValue: rawCardIOCardType) ?? .unrecognized
                let cardToken = settingsCell.userInfo["token"] as? String ?? ""
                let isDefault = settingsCell.userInfo["isDefault"] as? Bool ?? false
                
                let reuse = "cc_" + String(rawCardIOCardType) + "_" + cardToken + String(isDefault)
                
                var cell = tableView.dequeueReusableCell(withIdentifier: reuse) as? PPCreditCardCell
                if cell == nil {
                    cell = PPCreditCardCell(creditCardType: cardIOCardType, isDefault: isDefault, reuseIdentifier: reuse)
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch(editingStyle) {
        case .delete:
            let settingsCell = tableSource[indexPath.section].1[indexPath.row]
            SVProgressHUD.setBackgroundColor(UIColor.clear)
            SVProgressHUD.show()
            let cardToken = settingsCell.userInfo["token"] as? String ?? ""
            ParkingPandaOperations.deleteCreditCard(self.ppUser, token: cardToken, completion: { (error) -> Void in
                self.refresh()
                DispatchQueue.main.async(execute: { () -> Void in
                    SVProgressHUD.dismiss()
                })
            })
        case .insert, .none:
            break
        }
    }
    
    @available(iOS 8.0, *)
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let settingsCell = tableSource[indexPath.section].1[indexPath.row]
        if settingsCell.canDelete {
            let deleteClosure = { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
                SVProgressHUD.setBackgroundColor(UIColor.clear)
                SVProgressHUD.show()
                let cardToken = settingsCell.userInfo["token"] as? String ?? ""
                ParkingPandaOperations.deleteCreditCard(self.ppUser, token: cardToken, completion: { (error) -> Void in
                    self.refresh()
                    DispatchQueue.main.async(execute: { () -> Void in
                        SVProgressHUD.dismiss()
                    })
                })
            }
            let deleteAction = UITableViewRowAction(style: .destructive, title: "delete".localizedString, handler: deleteClosure)
            return [deleteAction]
        }
        return []
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        let settingsCell = tableSource[indexPath.section].1[indexPath.row]
        if settingsCell.canDelete {
            return UITableViewCellEditingStyle.delete
        }
        return UITableViewCellEditingStyle.none
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let settingsCell = tableSource[indexPath.section].1[indexPath.row]
        return settingsCell.canDelete
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let settingsCell = tableSource[indexPath.section].1[indexPath.row]
        return settingsCell.canSelect
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let settingsCell = tableSource[indexPath.section].1[indexPath.row]
        if settingsCell.selectorsTarget != nil && settingsCell.cellSelector != nil {
            settingsCell.selectorsTarget!.perform(Selector(settingsCell.cellSelector!))
        }
        if let creditCard = settingsCell.userInfo["parking_panda_credit_card"] as? ParkingPandaCreditCard {
            //then mark it as default
            DispatchQueue.main.async(execute: { () -> Void in
                SVProgressHUD.show()
                ParkingPandaOperations.updateCreditCard(self.ppUser, token: creditCard.token, isDefault: true, completion: { (creditCard, error) -> Void in
                    self.refresh()
                })
            })
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0: return BIG_CELL_HEIGHT
        default: return SMALL_CELL_HEIGHT
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 0 //the slider cell
        case 3: return 4 //second vehicle description cell
        case 4: return 30 //sign out cell
        default: return BIG_CELL_HEIGHT
        }

    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerText = tableSource[section].0
        return GeneralTableHelperViews.sectionHeaderView(headerText)
    }
    
    //MARK: selector functions
    
    func lotRateDisplayValueChanged() {
        let currentValue = Settings.lotMainRateIsHourly()
        Settings.setLotMainRateIsHourly(!currentValue)
    }
    
    func vehicleDescriptionCallback(_ sender: AnyObject?) {
        if let timer = sender as? Timer {
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
    
    func cellReturnCallback(_ sender: AnyObject?) {
        if let timer = sender as? Timer {
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
        paymentVC?.hideCardIOLogo = true
        paymentVC?.keepStatusBarStyle = true
        paymentVC?.guideColor = Styles.Colors.red2
        paymentVC?.navigationBarStyle = .black
        paymentVC?.navigationBar.isTranslucent = false
        //dark style:
        paymentVC?.navigationBarTintColor = Styles.Colors.midnight1
        paymentVC?.navigationBar.tintColor = Styles.Colors.stone
        
        paymentVC?.collectPostalCode = true
        
        if let navVC = self.navigationController {
            navVC.pushViewController(paymentVC!, animated: true)
        } else {
            self.present(paymentVC!, animated: true, completion: nil)
        }

    }
    
    func presentWithVC(_ vc: UIViewController?) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
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
                navVC.popViewController(animated: true)
            } else {
                self.dismissViewControllerFromLeft(0.3, completion: nil)
            }
        }
    }
    
    func passesValidation(shouldColorCells: Bool = true) -> Bool {
        let failedValidation = brand.isEmpty || plate.isEmpty || model.isEmpty || color.isEmpty || phone.isEmpty
        
        if failedValidation {
            GeneralHelper.warnUserWithErrorMessage("vehicle_description_warning".localizedString)
            
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
    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        SVProgressHUD.show()
        ParkingPandaOperations.addCreditCard(ppUser, cardInfo: cardInfo) { (creditCard, error) -> Void in
            switch (error!.errorType) {
            case .noError:
                paymentViewController.dismiss(animated: true, completion: nil)
                self.refresh()
            case .api, .internal, .network:
                break
            }
            DispatchQueue.main.async(execute: { () -> Void in
                SVProgressHUD.dismiss()
            })
        }
    }

}

