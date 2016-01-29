//
//  PPSettingsCell.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2016-01-26.
//  Copyright © 2016 PRKNG. All rights reserved.
//

import UIKit
import MessageUI

class PPSettingsViewController: AbstractViewController, UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate {
    
    var statusView = UIView()
    var headerView = UIView()
    var backButtonImageView: UIButton
    var backButton = MKButton()
    var headerLabel = UILabel()
    
    let tableView = UITableView()
    
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
        backButtonImageView = ViewFactory.outlineBackButton(BACKGROUND_TEXT_COLOR_EMPHASIZED)
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
        self.screenName = "Parking Panda Settings View"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadSections(NSIndexSet(indexesInRange: NSMakeRange(0, self.tableView.numberOfSections)), withRowAnimation: .None)
    }
    
    func handleHeaderTap(tapRec: UITapGestureRecognizer) {
        if let navVC = self.navigationController {
            navVC.popViewControllerAnimated(true)
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func setupViews () {
        
        view.backgroundColor = BACKGROUND_COLOR

        statusView.backgroundColor = Styles.Colors.transparentBlack
        self.view.addSubview(statusView)
        
        backButton.rippleLayerColor = FOREGROUND_COLOR
        backButton.rippleAniDuration = 0.35
        backButton.cornerRadius = 0
        backButton.shadowAniEnabled = false
        
        backButton.layer.shadowColor = UIColor.blackColor().CGColor
        backButton.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        backButton.layer.shadowOpacity = 0.1
        backButton.layer.shadowRadius = 0.5
        
        headerLabel.text = "PARKING PANDA"
        headerLabel.font = HEADER_FONT
        headerLabel.textColor = BACKGROUND_TEXT_COLOR_EMPHASIZED
        headerLabel.textAlignment = .Center
        
        headerView.addSubview(headerLabel)
        headerView.addSubview(backButtonImageView)
        headerView.addSubview(backButton)
        view.addSubview(headerView)
        
        view.addSubview(tableView)
        tableView.tableFooterView = self.tableFooterView()
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = .None
        tableView.dataSource = self
        tableView.delegate = self
        tableView.clipsToBounds = true
        
        let tapRec = UITapGestureRecognizer(target: self, action: "handleHeaderTap:")
        tapRec.delegate = self
        backButton.addGestureRecognizer(tapRec)

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
        
        headerLabel.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(headerView)
        }
                
        backButtonImageView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.headerView).offset(25)
            make.centerY.equalTo(self.headerView)
        }
        
        backButton.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.headerView)
        }
        
        tableView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.headerView.snp_bottom)
            make.bottom.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
    }

    //MARK: Table Footer View

    func tableFooterView() -> UIView {
        
        let frame = CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: CGFloat(self.MIN_FOOTER_HEIGHT))
        let tableFooterView = UIView(frame: frame)
        tableFooterView.backgroundColor = Styles.Colors.stone

        let tableFooterViewLabel = UILabel(frame: frame)
        
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
        tableFooterView.addSubview(tableFooterViewLabel)
        
        tableFooterViewLabel.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(tableFooterView)
        }
        
        let newHeight = tableFooterViewLabel.intrinsicContentSize().height > CGFloat(self.MIN_FOOTER_HEIGHT) ? tableFooterViewLabel.intrinsicContentSize().height + 40 : CGFloat(self.MIN_FOOTER_HEIGHT)
        
        tableFooterView.frame.size = CGSize(width: UIScreen.mainScreen().bounds.width, height: newHeight)
        tableFooterViewLabel.frame.size = CGSize(width: UIScreen.mainScreen().bounds.width, height: newHeight)

        return tableFooterView
    }
    

    //MARK: UITableViewDataSource
    
    //TODO: All these strings need to be localized
    var tableSource: [(String, [SettingsCell])] {
        
        let firstSection = ("", [SettingsCell(cellType: .Segmented, titleText: "Parking lots price", segments: ["hourly".localizedString.uppercaseString , "daily".localizedString.uppercaseString], defaultSegment: (Settings.lotMainRateIsHourly() ? 0 : 1), selectorsTarget: self, switchSelector: "lotRateDisplayValueChanged")
            ])
        
        let paymentMethodSection = [SettingsCell]()
        
        let vehicleDescBrandAndPlate = SettingsCell(placeholderTexts: ["brand".localizedString, "license_plate".localizedString], cellType: .DoubleTextEntry, selectorsTarget: self, callback: "vehicleDescriptionCallback:")
        let vehicleDescModelAndColor = SettingsCell(placeholderTexts: ["model".localizedString, "color".localizedString], cellType: .DoubleTextEntry, selectorsTarget: self, callback: "vehicleDescriptionCallback:")
        let vehicleDescPhone = SettingsCell(placeholderText: "phone_number".localizedString, cellType: .TextEntry, cellSelector: "phoneUpdated", selectorsTarget: self, callback: "vehicleDescriptionCallback:")

        let vehicleDescriptionSection = [vehicleDescBrandAndPlate, vehicleDescModelAndColor]

        let vehicleDescriptionSection2 = ("", [vehicleDescPhone])

        let signOutSection = ("", [
            SettingsCell(cellType: .Basic, titleText: "Sign Out of Parking Panda", selectorsTarget: self, cellSelector: "signOut", canSelect: true, redText: true)
            ])

        return [firstSection,
            ("Payment method", paymentMethodSection),
            ("Vehicle description", vehicleDescriptionSection),
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
        return settingsCell.tableViewCell(tableView)
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
        switch indexPath.section {
        case 0: return BIG_CELL_HEIGHT
        default: return SMALL_CELL_HEIGHT
        }
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 0
        case 3: return 4
        case 4: return 30
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
    
    //MARK: selector functions
    
    func lotRateDisplayValueChanged() {
        let currentValue = Settings.lotMainRateIsHourly()
        Settings.setLotMainRateIsHourly(!currentValue)
    }
    
    //TODO: save the bottom values to somewhere in settings
    func vehicleDescriptionCallback(sender: AnyObject?) {
        if let timer = sender as? NSTimer {
            if let dict = timer.userInfo as? [String: String] {
                let brand = dict["brand".localizedString]
                let plate = dict["license_plate".localizedString]
                let model = dict["model".localizedString]
                let color = dict["color".localizedString]
                let phone = dict["phone_number".localizedString]
            }
            timer.invalidate()
        }
    }

    //TODO: proper sign out once sign in is complete!
    func signOut() {
        print("SIGN OUTTTTT")
    }
    
}

