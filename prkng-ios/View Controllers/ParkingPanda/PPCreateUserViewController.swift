//
//  PPCreateUserViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2016-02-04.
//  Copyright © 2016 PRKNG. All rights reserved.
//

import UIKit
import MessageUI

class PPCreateUserViewController: AbstractViewController, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate, PPHeaderViewDelegate, CardIOPaymentViewControllerDelegate {
    
    var delegate: PPCreateUserViewControllerDelegate?
    
    fileprivate enum PPCreateUserStep: Int {
        case personalInformation = 0
        case creditCard
        case vehicleDescription
    }
    
    fileprivate var step: PPCreateUserStep = .personalInformation
    
    fileprivate var statusView = UIView()
    fileprivate var headerView = PPHeaderView()
    fileprivate let tableView = PRKCachedTableView()
    
    fileprivate var firstName: String = ""
    fileprivate var lastName: String = ""
    fileprivate var email: String = ""
    fileprivate var password: String = ""
    
    fileprivate var creditCards = [CardIOCreditCardInfo]()
    fileprivate var redCells = [String]()

    fileprivate var brand: String = Settings.getCarDescription()["brand"] ?? ""
    fileprivate var plate: String = Settings.getCarDescription()["plate"] ?? ""
    fileprivate var model: String = Settings.getCarDescription()["model"] ?? ""
    fileprivate var color: String = Settings.getCarDescription()["color"] ?? ""
    fileprivate var phone: String = Settings.getCarDescription()["phone"] ?? ""
    
    var onlyShowVehicleDescription: Bool = false {
        didSet {
            step = .vehicleDescription
            headerView.showsLeftButton = false
        }
    }
    
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
    
    init() {
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
        self.screenName = "Parking Panda Create User View"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let nextTextField = tableView.viewWithTag(1) as? UITextField {
            nextTextField.becomeFirstResponder()
        }
    }
    
    func setupViews () {
        
        view.backgroundColor = BACKGROUND_COLOR
        
        statusView.backgroundColor = Styles.Colors.transparentBlack
        self.view.addSubview(statusView)
        
        headerView.delegate = self
        headerView.headerText = "create_pp_account".localizedString.uppercased()
        view.addSubview(headerView)
        
        view.addSubview(tableView)
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
    
    
    //MARK: UITableViewDataSource
    
    var tableSource: [(String, [SettingsCell])] {
        
        //first up: information section
        let firstNameCell = SettingsCell(placeholderText: "first_name".localizedString, titleText: firstName, cellType: .TextEntry, selectorsTarget: self, callback: "formCallback:",
            userInfo: [
                "textFieldTag": 1,
                "keyboardType": UIKeyboardType.namePhonePad.rawValue,
                "returnKeyType": UIReturnKeyType.next.rawValue,
                "autocorrectionType": UITextAutocorrectionType.no.rawValue,
                "redTintOnOrderedCells": [redCells.contains("firstName")],
                "returnCallback": "cellReturnCallback:"])
        let lastNameCell = SettingsCell(placeholderText: "last_name".localizedString, titleText: lastName, cellType: .TextEntry, selectorsTarget: self, callback: "formCallback:",
            userInfo: [
                "textFieldTag": 2,
                "keyboardType": UIKeyboardType.namePhonePad.rawValue,
                "returnKeyType": UIReturnKeyType.next.rawValue,
                "autocorrectionType": UITextAutocorrectionType.no.rawValue,
                "redTintOnOrderedCells": [redCells.contains("lastName")],
                "returnCallback": "cellReturnCallback:"])
        let emailCell = SettingsCell(placeholderText: "email".localizedString, titleText: email, cellType: .TextEntry, selectorsTarget: self, callback: "formCallback:",
            userInfo: [
                "textFieldTag": 3,
                "keyboardType": UIKeyboardType.emailAddress.rawValue,
                "returnKeyType": UIReturnKeyType.next.rawValue,
                "autocorrectionType": UITextAutocorrectionType.no.rawValue,
                "redTintOnOrderedCells": [redCells.contains("email")],
                "returnCallback": "cellReturnCallback:"])
        let passwordCell = SettingsCell(placeholderText: "password".localizedString, titleText: password, cellType: .TextEntry, selectorsTarget: self, callback: "formCallback:",
            userInfo: [
                "textFieldTag": 4,
                "keyboardType": UIKeyboardType.default.rawValue,
                "returnKeyType": UIReturnKeyType.done.rawValue,
                "autocorrectionType": UITextAutocorrectionType.no.rawValue,
                "redTintOnOrderedCells": [redCells.contains("password")],
                "secureTextEntry": true,
                "returnCallback": "cellReturnCallback:"])
        let formSection = [firstNameCell, lastNameCell, emailCell, passwordCell]
        
        
        //next: payment info
        var paymentMethodSection = [SettingsCell]()
        let addPaymentMethodCell = SettingsCell(titleText: "add_payment_method".localizedString, selectorsTarget: self, cellSelector: "addPaymentMethod", canSelect: true)
        for creditCard in creditCards {
            let card = SettingsCell(userInfo: ["card_io_payment_type": creditCard.cardType.rawValue, "token": creditCard.cardNumber, "card_io_credit_card_info": creditCard], titleText: creditCard.cardNumber, canSelect: false, canDelete: true)
            
            paymentMethodSection.append(card)
        }
        paymentMethodSection.append(addPaymentMethodCell)

        //finally, vehicle information:
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

        switch(step) {
        case .personalInformation: return [("enter_your_information".localizedString, formSection)]
        case .creditCard: return [("payment_method".localizedString, paymentMethodSection)]
        case .vehicleDescription: return [("vehicle_description".localizedString, vehicleDescriptionSection),vehicleDescriptionSection2]
        }
        
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
                
                let reuse = "cc_" + String(rawCardIOCardType) + "_" + cardToken
                
                var cell = tableView.dequeueReusableCell(withIdentifier: reuse) as? PPCreditCardCell
                if cell == nil {
                    cell = PPCreditCardCell(creditCardType: cardIOCardType, isDefault: false, reuseIdentifier: reuse)
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
            let settingsCell = self.tableSource[indexPath.section].1[indexPath.row]
            if let cardInfo = settingsCell.userInfo["card_io_credit_card_info"] as? CardIOCreditCardInfo {
                self.creditCards.remove(cardInfo)
                self.tableView.reloadData()
            }
        case .insert, .none:
            break
        }
    }
    
    @available(iOS 8.0, *)
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let settingsCell = tableSource[indexPath.section].1[indexPath.row]
        if settingsCell.canDelete {
            let deleteAction = UITableViewRowAction(style: .destructive, title: "delete".localizedString, handler: { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
                let settingsCell = self.tableSource[indexPath.section].1[indexPath.row]
                if let cardInfo = settingsCell.userInfo["card_io_credit_card_info"] as? CardIOCreditCardInfo {
                    self.creditCards.remove(cardInfo)
                    self.tableView.reloadData()
                }
            })
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
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return SMALL_CELL_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if step == .vehicleDescription && section == 1 {
            return 4 //second vehicle description cell
        }
        return BIG_CELL_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
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
    
    
    //MARK: selector functions
    
    func formCallback(_ sender: AnyObject?) {
        if let timer = sender as? Timer {
            if let dict = timer.userInfo as? [String: String] {
                firstName = dict["first_name".localizedString] ?? firstName
                lastName = dict["last_name".localizedString] ?? lastName
                email = dict["email".localizedString] ?? email
                password = dict["password".localizedString] ?? password
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
        
        if let navVC = self.navigationController {
            navVC.popViewController(animated: true)
        } else {
            self.dismissViewControllerFromLeft(0.3, completion: nil)
        }
        
    }
    
    func passesValidation(shouldColorCells: Bool = true) -> Bool {
        
        switch step {
        case .personalInformation:
            let failedValidation = firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty
            
            if failedValidation {
                GeneralHelper.warnUserWithErrorMessage("info_warning".localizedString)
                
                if shouldColorCells {
                    redCells = []
                    if firstName.isEmpty { redCells.append("firstName") }
                    if lastName.isEmpty { redCells.append("lastName") }
                    if email.isEmpty { redCells.append("email") }
                    if password.isEmpty { redCells.append("password") }
                    tableView.reloadDataAnimated()
                }
                
                return false
            }
        case .creditCard:
            let failedValidation = creditCards.count < 1
            
            if failedValidation {
                GeneralHelper.warnUserWithErrorMessage("cc_warning".localizedString)
                return false
            }
        case .vehicleDescription:
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
        }

        return true
    }
    
    //MARK: CardIOPaymentViewControllerDelegate functions
    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        creditCards.append(cardInfo)
        self.tableView.reloadData()
        paymentViewController.dismiss(animated: true, completion: nil)
    }

    //MARK: PPHeaderViewDelegate
    func tappedBackButton() {

        headerView.rightButtonText = "next".localizedString.uppercased()

        switch step {
        case .personalInformation:
            dismiss()
        case .creditCard, .vehicleDescription:
            if onlyShowVehicleDescription {
                //then the purpose of this was to just show the vehicle description, so just dismiss this (since we know we've passed validation)
                return
            }
            step = PPCreateUserStep(rawValue: step.rawValue - 1) ?? .personalInformation
            self.tableView.reloadDataAnimated()
        }

    }
    
    func tappedNextButton() {
        
        switch step {
        case .personalInformation:
            if passesValidation() {
                step = PPCreateUserStep(rawValue: step.rawValue + 1) ?? .personalInformation
                headerView.rightButtonText = "next".localizedString.uppercased()
            }
            self.tableView.reloadDataAnimated()
        case .creditCard:
            if passesValidation() {
                step = PPCreateUserStep(rawValue: step.rawValue + 1) ?? .personalInformation
                headerView.rightButtonText = "done".localizedString.uppercased()
            }
            self.tableView.reloadDataAnimated()
        case .vehicleDescription:
            if passesValidation() {
                let description = [
                    "brand" : brand ?? "",
                    "plate" : plate ?? "",
                    "model" : model ?? "",
                    "color" : color ?? "",
                    "phone" : phone ?? "",
                ]
                Settings.setCarDescription(description)

                if onlyShowVehicleDescription {
                    //then the purpose of this was to just show the vehicle description, so just dismiss this (since we know we've passed validation)
                    self.dismiss()
                    return
                }
                SVProgressHUD.setBackgroundColor(UIColor.clear)
                SVProgressHUD.show()
                ParkingPandaOperations.createUser(email ?? "", password: password ?? "", firstName: firstName ?? "", lastName: lastName ?? "", phone: phone ?? "", completion: { (user, error) -> Void in
                    if user != nil {
                        //we have created a user and are logged in!
                        for cardInfo in self.creditCards {
                            ParkingPandaOperations.addCreditCard(user!, cardInfo: cardInfo) { (creditCard, error) -> Void in
                                if cardInfo == self.creditCards.last {
                                    DispatchQueue.main.async(execute: { () -> Void in
                                        //these two actions will basically happen at the same time, which, really, is what we want!
                                        self.dismiss()
                                        self.delegate?.didCreateAccount()
                                        SVProgressHUD.dismiss()
                                        if creditCard != nil {
                                            GeneralHelper.warnUserWithSucceedMessage("pp_registration_complete".localizedString)
                                        } else {
                                            GeneralHelper.warnUserWithSucceedMessage("pp_registration_complete_cc_warning".localizedString)
                                        }
                                    })
                                }
                            }
                        }
                    } else {
                        DispatchQueue.main.async(execute: { () -> Void in
                            SVProgressHUD.dismiss()
                        })
                    }
                })
            }
        }
        
    }
    
}


protocol PPCreateUserViewControllerDelegate {
    func didCreateAccount()
}


