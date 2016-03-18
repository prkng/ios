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
    
    private var redCells = [String]()

    var delegate: PPSignInViewControllerDelegate?
    
    private var statusView = UIView()
    private var headerView = PPHeaderView()
    private let tableView = PRKCachedTableView()
    
    private var username: String = ""
    private var password: String = ""
    
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
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
        headerView.headerText = "pp_sign_in".localizedString.uppercaseString
        headerView.rightButtonText = "sign_in".localizedString.uppercaseString
        view.addSubview(headerView)
        
        view.addSubview(tableView)
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
    
    
    //MARK: UITableViewDataSource
    
    var tableSource: [(String, [SettingsCell])] {
        let emailCell = SettingsCell(placeholderText: "email".localizedString, titleText: username, cellType: .TextEntry, selectorsTarget: self, callback: "formCallback:",
            userInfo: [
                "textFieldTag": 1,
                "keyboardType": UIKeyboardType.EmailAddress.rawValue,
                "returnKeyType": UIReturnKeyType.Next.rawValue,
                "autocorrectionType": UITextAutocorrectionType.No.rawValue,
                "redTintOnOrderedCells": [redCells.contains("username")],
                "returnCallback": "cellReturnCallback:"])
        let passwordCell = SettingsCell(placeholderText: "password".localizedString, titleText: password, cellType: .TextEntry, selectorsTarget: self, callback: "formCallback:",
            userInfo: [
                "textFieldTag": 2,
                "keyboardType": UIKeyboardType.Default.rawValue,
                "returnKeyType": UIReturnKeyType.Done.rawValue,
                "autocorrectionType": UITextAutocorrectionType.No.rawValue,
                "redTintOnOrderedCells": [redCells.contains("password")],
                "secureTextEntry": true,
                "returnCallback": "cellReturnCallback:"])
        let formSection = [emailCell, passwordCell]
        
        return [("enter_your_information".localizedString, formSection)]
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableSource.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableSource[section].1.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let settingsCell = tableSource[indexPath.section].1[indexPath.row]
        let cell = settingsCell.tableViewCell(tableView)
        self.tableView.cachedCells.append(cell)
        return cell
    }
    
    
    //MARK: UITableViewDelegate
    
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
        return SMALL_CELL_HEIGHT
    }
    
    
    //MARK: selector functions
    
    func formCallback(sender: AnyObject?) {
        if let timer = sender as? NSTimer {
            if let dict = timer.userInfo as? [String: String] {
                username = dict["email".localizedString] ?? username
                password = dict["password".localizedString] ?? password
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
        
        if let navVC = self.navigationController {
            navVC.popViewControllerAnimated(true)
        } else {
            self.dismissViewControllerFromLeft(0.3, completion: nil)
        }
        
    }
    
    func passesValidation(shouldColorCells shouldColorCells: Bool = true) -> Bool {
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
            SVProgressHUD.setBackgroundColor(UIColor.clearColor())
            SVProgressHUD.show()
            ParkingPandaOperations.login(username: username, password: password, completion: { (user, error) -> Void in
                if user != nil {
                    //we have logged in!
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        //these two actions will basically happen at the same time, which, really, is what we want!
                        self.dismiss()
                        self.delegate?.didSignIn()
                        SVProgressHUD.dismiss()
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
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