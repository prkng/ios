//
//  PPSignInViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2016-02-04.
//  Copyright © 2016 PRKNG. All rights reserved.
//

import UIKit
import MessageUI

class PPSignInViewController: AbstractViewController, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate, PPHeaderViewDelegate {
    
    fileprivate var redCells = [String]()

    var delegate: PPSignInViewControllerDelegate?
    
    fileprivate var statusView = UIView()
    fileprivate var headerView = PPHeaderView()
    fileprivate let tableView = PRKCachedTableView()
    
    fileprivate var username: String = ""
    fileprivate var password: String = ""
    
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
        self.screenName = "Parking Panda Sign In View"
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
        headerView.headerText = "pp_sign_in".localizedString.uppercased()
        headerView.rightButtonText = "sign_in".localizedString.uppercased()
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
        let emailCell = SettingsCell(placeholderText: "email".localizedString, titleText: username, cellType: .TextEntry, selectorsTarget: self, callback: "formCallback:",
            userInfo: [
                "textFieldTag": 1,
                "keyboardType": UIKeyboardType.emailAddress.rawValue,
                "returnKeyType": UIReturnKeyType.next.rawValue,
                "autocorrectionType": UITextAutocorrectionType.no.rawValue,
                "redTintOnOrderedCells": [redCells.contains("username")],
                "returnCallback": "cellReturnCallback:"])
        let passwordCell = SettingsCell(placeholderText: "password".localizedString, titleText: password, cellType: .TextEntry, selectorsTarget: self, callback: "formCallback:",
            userInfo: [
                "textFieldTag": 2,
                "keyboardType": UIKeyboardType.default.rawValue,
                "returnKeyType": UIReturnKeyType.done.rawValue,
                "autocorrectionType": UITextAutocorrectionType.no.rawValue,
                "redTintOnOrderedCells": [redCells.contains("password")],
                "secureTextEntry": true,
                "returnCallback": "cellReturnCallback:"])
        let formSection = [emailCell, passwordCell]
        
        return [("enter_your_information".localizedString, formSection)]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableSource[section].1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let settingsCell = tableSource[indexPath.section].1[indexPath.row]
        let cell = settingsCell.tableViewCell(tableView)
        self.tableView.cachedCells.append(cell)
        return cell
    }
    
    
    //MARK: UITableViewDelegate
    
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
    
    
    //MARK: selector functions
    
    func formCallback(_ sender: AnyObject?) {
        if let timer = sender as? Timer {
            if let dict = timer.userInfo as? [String: String] {
                username = dict["email".localizedString] ?? username
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
        let failedValidation = username.isEmpty || password.isEmpty
        
        if failedValidation {
            GeneralHelper.warnUserWithErrorMessage("pp_credentials_error".localizedString)
            
            if shouldColorCells {
                redCells = []
                if username.isEmpty { redCells.append("username") }
                if password.isEmpty { redCells.append("password") }
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
        
        if passesValidation() {
            SVProgressHUD.setBackgroundColor(UIColor.clear)
            SVProgressHUD.show()
            ParkingPandaOperations.login(username: username, password: password, completion: { (user, error) -> Void in
                if user != nil {
                    //we have logged in!
                    DispatchQueue.main.async(execute: { () -> Void in
                        //these two actions will basically happen at the same time, which, really, is what we want!
                        self.dismiss()
                        self.delegate?.didSignIn()
                        SVProgressHUD.dismiss()
                    })
                } else {
                    DispatchQueue.main.async(execute: { () -> Void in
                        SVProgressHUD.dismiss()
                    })
                }
            })
        }

    }
    
}


protocol PPSignInViewControllerDelegate {
    func didSignIn()
}
