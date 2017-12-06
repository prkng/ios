//
//  HistoryTableViewCell.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 16/06/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

enum SettingsTableViewCellType: String {
    case Switch //switch on the left followed by 2 lines (title, subtitle)
    case Segmented //title followed by segmented switch
    case Service //title followed by rounded button
    case ServiceSwitch //switch followed by Service ^
    case PermitSwitch //switch with permit acessory view
    case TextEntry //cell that allows a text field with placeholder
    case DoubleTextEntry //like TextEntry but has two on one line
    case Basic //title, possibly red.
}

class SettingsCell: NSObject {
    
    var id: String {
        return self.cellType.rawValue + self.titleText + (self.rightSideText ?? "") + placeholderTexts.joined(separator: "")
    }

    var placeholderText: String {
        return placeholderTexts.first ?? ""
    }
    var titleText: String {
        return titleTexts.first ?? ""
    }
    
    var placeholderTexts: [String] = []
    var titleTexts: [String] = []
    var subtitleText: String = ""
    var segments: [String] = []
    var defaultSegment: Int = 0
    var signedIn: Bool? = nil
    var switchValue: Bool? = nil
    var selectorsTarget: AnyObject? = nil
    var callback: String? = nil
    var cellSelector: String? = nil
    var switchSelector: String? = nil
    var buttonSelector: String? = nil
    var rightSideText: String? = nil
    var cellType: SettingsTableViewCellType = .Basic
    var canSelect: Bool = false
    var canDelete: Bool = false
    var bold: Bool = false
    var redText: Bool = false
    var userInfo: [String: AnyObject] = [String: AnyObject]() //for custom cells not included in this file!
    
    //memberwise initializer (it's just easier to have ONE like this, and a few convenience inits)
    init(
        placeholderTexts: [String] = [],
        placeholderText: String? = nil,
        titleTexts: [String] = [],
        titleText: String? = nil,
        subtitleText: String = "",
        segments: [String] = [],
        defaultSegment: Int = 0,
        signedIn: Bool? = nil,
        switchValue: Bool? = nil,
        selectorsTarget: AnyObject? = nil,
        callback: String? = nil,
        cellSelector: String? = nil,
        switchSelector: String? = nil,
        buttonSelector: String? = nil,
        rightSideText: String? = nil,
        cellType: SettingsTableViewCellType = .Basic,
        canSelect: Bool = false,
        canDelete: Bool = false,
        bold: Bool = false,
        redText: Bool = false,
        userInfo: [String: AnyObject] = [String: AnyObject]()
        ) {
            self.placeholderTexts = placeholderTexts
            if let text = placeholderText { self.placeholderTexts.append(text) }
            self.titleTexts = titleTexts
            if let text = titleText { self.titleTexts.append(text) }
            self.subtitleText = subtitleText
            self.segments = segments
            self.defaultSegment = defaultSegment
            self.signedIn = signedIn
            self.switchValue = switchValue
            self.selectorsTarget = selectorsTarget
            self.callback = callback
            self.cellSelector = cellSelector
            self.switchSelector = switchSelector
            self.buttonSelector = buttonSelector
            self.rightSideText = rightSideText
            self.cellType = cellType
            self.canSelect = canSelect
            self.canDelete = canDelete
            self.bold = bold
            self.redText = redText
            self.userInfo = userInfo
    }
    
    //this init infers a Switch or PermitSwitch type
    convenience init(switchValue: Bool, titleText: String, subtitleText: String, selectorsTarget: AnyObject? = nil, switchSelector: String? = nil, buttonSelector: String? = nil, rightSideText: String? = nil) {
        self.init()
        self.cellType = buttonSelector == nil ? .Switch : .PermitSwitch
        self.switchValue = switchValue
        self.titleTexts = [titleText]
        self.subtitleText = subtitleText
        self.selectorsTarget = selectorsTarget
        self.switchSelector = switchSelector
        self.buttonSelector = buttonSelector
        self.rightSideText = rightSideText
    }

    //this init infers Switch type
    convenience init(titleText: String, switchValue: Bool) {
        self.init()
        self.cellType = .Switch
        self.titleTexts = [titleText]
        self.switchValue = switchValue
    }
    
    convenience init(placeholderText: String, titleText: String, cellType: SettingsTableViewCellType, selectorsTarget: AnyObject, callback: String, userInfo: [String: AnyObject]) {
        self.init()
        if let text = placeholderText { self.placeholderTexts.append(text) }
        if let text = titleText { self.titleTexts.append(text) }
        self.cellType = cellType
        self.selectorsTarget = selectorsTarget
        self.callback = callback
        self.userInfo = userInfo
    }
    
    func tableViewCell(_ tableView: UITableView) -> UITableViewCell {
        
        if let ppSettingsCell = self as? PPSettingsCell {
            return ppSettingsCell.tableViewCell
        }
        
        switch self.cellType {
            
        case .Switch, .PermitSwitch:
            var cell = tableView.dequeueReusableCell(withIdentifier: self.id) as? SettingsSwitchCell
            if cell == nil {
                cell = SettingsSwitchCell(rightSideText: self.rightSideText, selectorsTarget: self.selectorsTarget, selector: self.switchSelector, buttonSelector: self.buttonSelector, reuseIdentifier: self.id)
            }
            cell!.titleText = self.titleText
            cell!.subtitleText = self.subtitleText
            cell!.switchOn = self.switchValue ?? false
            return cell!
            
        case .Segmented:
            var cell = tableView.dequeueReusableCell(withIdentifier: self.id) as? SettingsSegmentedCell
            if cell == nil {
                cell = SettingsSegmentedCell(segments: self.segments, reuseIdentifier: self.id, selectorsTarget: self.selectorsTarget, selector: self.switchSelector)
            }
            cell!.titleText = self.titleText
            cell!.selectedSegment = self.defaultSegment
            return cell!
            
        case .Service, .ServiceSwitch:
            var cell = tableView.dequeueReusableCell(withIdentifier: self.id) as? SettingsServiceSwitchCell
            if cell == nil {
                cell = SettingsServiceSwitchCell(style: .default, reuseIdentifier: self.id)
            }
            cell!.titleText = self.titleText
            cell!.signedIn = self.signedIn
            if let switchValue = self.switchValue {
                cell!.shouldShowSwitch = true
                cell!.switchValue = switchValue
                cell!.selectorsTarget = self.selectorsTarget
                cell!.switchSelector = self.switchSelector
                cell!.buttonSelector = self.buttonSelector
            } else {
                cell!.shouldShowSwitch = false
            }
            cell!.shouldShowSwitch = self.cellType == SettingsTableViewCellType.ServiceSwitch
            return cell!
            
        case .Basic:
            var cell = tableView.dequeueReusableCell(withIdentifier: self.id) as? SettingsBasicCell
            if cell == nil {
                cell = SettingsBasicCell(style: .default, reuseIdentifier: self.id)
            }
            cell!.titleText = self.titleText
            cell!.bold = self.bold
            cell!.redText = self.redText
            return cell!
            
        case .TextEntry:
            var cell = tableView.dequeueReusableCell(withIdentifier: self.id) as? SettingsTextEntryCell
            if cell == nil {
                cell = SettingsTextEntryCell(style: .default, reuseIdentifier: self.id)
            }
            cell!.placeholderText = self.placeholderText
            cell!.mainText = self.titleText
            cell!.selectorsTarget = self.selectorsTarget
            cell!.editCallback = self.callback
            cell!.returnCallback = self.userInfo["returnCallback"] as? String
            cell!.keyboardType = UIKeyboardType(rawValue: self.userInfo["keyboardType"] as? Int ?? 0) ?? .default
            cell!.returnKeyType = UIReturnKeyType(rawValue: self.userInfo["returnKeyType"] as? Int ?? 0) ?? .default
            cell!.autocorrectionType = UITextAutocorrectionType(rawValue: self.userInfo["autocorrectionType"] as? Int ?? 0) ?? .default
            cell!.secureTextEntry = self.userInfo["secureTextEntry"] as? Bool ?? false
            cell!.textFieldTag = self.userInfo["textFieldTag"] as? Int
            cell!.hasRedTint = (self.userInfo["redTintOnOrderedCells"] as? [Bool])?.first ?? false
            return cell!
            
        case .DoubleTextEntry:
            var cell = tableView.dequeueReusableCell(withIdentifier: self.id) as? SettingsDoubleTextEntryCell
            if cell == nil {
                cell = SettingsDoubleTextEntryCell(style: .default, reuseIdentifier: self.id)
            }
            cell!.placeholderTextLeft = self.placeholderTexts.first ?? ""
            cell!.mainTextLeft = self.titleTexts.first ?? ""
            cell!.placeholderTextRight = self.placeholderTexts.last ?? ""
            cell!.mainTextRight = self.titleTexts.last ?? ""
            cell!.selectorsTarget = self.selectorsTarget
            cell!.editCallback = self.callback
            cell!.returnCallback = self.userInfo["returnCallback"] as? String
            cell!.keyboardType = UIKeyboardType(rawValue: self.userInfo["keyboardType"] as? Int ?? 0) ?? .default
            cell!.returnKeyType = UIReturnKeyType(rawValue: self.userInfo["returnKeyType"] as? Int ?? 0) ?? .default
            cell!.autocorrectionType = UITextAutocorrectionType(rawValue: self.userInfo["autocorrectionType"] as? Int ?? 0) ?? .default
            cell!.secureTextEntry = self.userInfo["secureTextEntry"] as? Bool ?? false
            cell!.textFieldTag = self.userInfo["textFieldTag"] as? Int
            cell!.leftHasRedTint = (self.userInfo["redTintOnOrderedCells"] as? [Bool])?.first ?? false
            cell!.rightHasRedTint = (self.userInfo["redTintOnOrderedCells"] as? [Bool])?.last ?? false
            return cell!
            
        }
    }

}

class SettingsBasicCell: UITableViewCell {

    fileprivate let title = UILabel()
    fileprivate var didSetupSubviews: Bool = false
    fileprivate var didSetupConstraints: Bool = false
    
    var redText: Bool {
        get { return title.textColor == Styles.Colors.red2 }
        set(value) { title.textColor = value ? Styles.Colors.red2 : Styles.Colors.midnight2 }
    }

    var bold: Bool {
        get { return title.font == Styles.FontFaces.bold(14) }
        set(value) { self.setFont(bold: value) }
    }

    var titleText: String {
        get { return self.title.text ?? "" }
        set(value) { self.title.text = value }
    }
    
    fileprivate func setFont(bold: Bool) {
        if bold {
            title.font = Styles.FontFaces.bold(14)
        } else {
            title.font = Styles.FontFaces.regular(14)
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
        self.setNeedsUpdateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        
        self.backgroundColor = Styles.Colors.cream1
        
        self.setFont(bold: bold)
        title.textAlignment = .left
        contentView.addSubview(title)
        
        didSetupSubviews = true
    }
    
    func setupConstraints() {

        title.snp_remakeConstraints { (make) -> () in
            make.left.equalTo(self.contentView).offset(40)
            make.right.equalTo(self.contentView)
            make.centerY.equalTo(self.contentView)
        }
        
        didSetupConstraints = true
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            setupConstraints()
        }
        super.updateConstraints()
    }
}

class SettingsSwitchCell: UITableViewCell {
    
    fileprivate let enabledSwitch = SevenSwitch()
    fileprivate let title = UILabel()
    fileprivate let subtitle = UILabel()
    fileprivate var didSetupSubviews: Bool = false
    fileprivate var didSetupConstraints: Bool = false
    
    var titleText: String {
        get { return self.title.text ?? "" }
        set(value) { self.title.text = value }
    }

    var subtitleText: String {
        get { return self.subtitle.text ?? "" }
        set(value) { self.subtitle.text = value }
    }
    
    var switchOn: Bool = false {
        didSet {
            enabledSwitch.on = switchOn
            enabledSwitchValueChanged(animated: false)
        }
    }
    
    fileprivate var indicatorButton: UIButton?
    fileprivate var rightSideText: String?
    
    func indicatorButtonTapped() {
        if (selectorsTarget != nil && buttonSelector != nil) {
            selectorsTarget!.perform(Selector(buttonSelector!))
        }
    }

    fileprivate var buttonSelector: String?
    
    fileprivate var addButton: UIButton?
    fileprivate var selectorsTarget: AnyObject?
    fileprivate var selector: String?
    
    fileprivate var cellBackgroundColor: UIColor {
        return enabledSwitch.isOn() ? Styles.Colors.white : Styles.Colors.cream1
    }

    func enabledSwitchValueChanged() {
        enabledSwitchValueChanged(animated: true)
    }
    
    func enabledSwitchValueChanged(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.2 : 0, animations: { () -> Void in
            self.backgroundColor = self.cellBackgroundColor
        }) 
    }
    
    func resetSelector() {
        enabledSwitch.removeTarget(nil, action: nil, for: .allEvents)
        if (selectorsTarget != nil && selector != nil) {
            enabledSwitch.addTarget(selectorsTarget!, action: Selector(selector!), for: .valueChanged)
            enabledSwitch.addTarget(self, action: #selector(SettingsSwitchCell.enabledSwitchValueChanged as (SettingsSwitchCell) -> () -> ()), for: .valueChanged)
        }
        if (selectorsTarget != nil && buttonSelector != nil) {
            addButton?.addTarget(selectorsTarget!, action: Selector(buttonSelector!), for: .touchUpInside)
        }
    }

    init(rightSideText: String?, selectorsTarget: AnyObject?, selector: String?, buttonSelector: String?, reuseIdentifier: String?) {
        self.rightSideText = rightSideText
        self.selectorsTarget = selectorsTarget
        self.selector = selector
        self.buttonSelector = buttonSelector
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupSubviews()
        self.setNeedsUpdateConstraints()
    }

//    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupSubviews()
//        self.setNeedsUpdateConstraints()
//    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        
        self.backgroundColor = cellBackgroundColor
        
        enabledSwitch.tintColor = Styles.Colors.stone
        enabledSwitch.onTintColor = Styles.Colors.cream1
        enabledSwitch.onTintColor = Styles.Colors.red2
        resetSelector()
        contentView.addSubview(enabledSwitch)
        
        title.font = Styles.FontFaces.regular(14)
        title.textColor = Styles.Colors.red2
        title.textAlignment = .left
        contentView.addSubview(title)
        
        subtitle.font = Styles.FontFaces.light(12)
        subtitle.textColor = Styles.Colors.anthracite1
        subtitle.textAlignment = .left
        contentView.addSubview(subtitle)
        
        if buttonSelector != nil {
            addButton = ViewFactory.smallAccessoryPlusButton()
            resetSelector()
        }
        
        if rightSideText != nil {
            
            //first of all, make the add button into an x instead of a +
            addButton = nil//ViewFactory.smallAccessoryCloseButton()
            
            //create the indicator button
            indicatorButton = ViewFactory.redRoundedButtonWithHeight(22, font: Styles.FontFaces.regular(14), text: "")
            let attrs = [NSFontAttributeName: indicatorButton!.titleLabel!.font]
            let maximumLabelSize = CGSize(width: 200, height: 22)
            let labelRect = (rightSideText! as NSString).boundingRect(with: maximumLabelSize, options: NSStringDrawingOptions(), attributes: attrs, context: nil)
            
            //add the close icon --> if we ever wish to re-add this, just add (5+closeImageView.frame.width) to the width of indicatorButton.frame
            let closeImageView = UIImageView(image: UIImage(named:"icon_close"))
            closeImageView.contentMode = .scaleAspectFit
            closeImageView.frame = CGRect(x: 10+labelRect.width+5, y: 6, width: 11, height: 11)
            indicatorButton!.addSubview(closeImageView)
            
            //add the label
            let label = UILabel(frame: CGRect(x: 10, y: 2.5, width: labelRect.width, height: labelRect.height))
            label.text = rightSideText!
            label.font = indicatorButton!.titleLabel!.font
            label.textColor = Styles.Colors.beige1
            indicatorButton!.addSubview(label)
            
            indicatorButton!.frame = rightSideText! == "" ? CGRect.zero : CGRect(x: 0, y: 0, width: 10+labelRect.width+10 + 5+closeImageView.frame.width, height: 22)
            indicatorButton!.addTarget(self, action: #selector(SettingsSwitchCell.indicatorButtonTapped), for: UIControlEvents.touchUpInside)
        }
        
        if addButton != nil {
            contentView.addSubview(addButton!)
        }
        
        if indicatorButton != nil {
            contentView.addSubview(indicatorButton!)
        }
        
        didSetupSubviews = true
    }
    
    func setupConstraints() {
        
        enabledSwitch.snp_remakeConstraints { (make) -> () in
            make.left.equalTo(self.contentView).offset(20)
            make.centerY.equalTo(self.contentView)
            make.size.equalTo(CGSize(width: 50, height: 30))
        }

        let rightSideWidth = (indicatorButton != nil ? 10 + indicatorButton!.frame.width : 0) + 10 + (addButton != nil ? 22 + 20 : 0)
        let indicatorButtonRightOffset = 10 + (self.addButton != nil ? (22 + 20) : 10)
        
        addButton?.snp_remakeConstraints(closure: { (make) -> Void in
            make.size.equalTo(CGSize(width: 22, height: 22))
            make.right.equalTo(self.contentView).offset(-20)
            make.centerY.equalTo(self.contentView)
        })
        
        indicatorButton?.snp_makeConstraints(closure: { (make) -> Void in
            make.size.equalTo(self.indicatorButton!.frame.size)
            make.right.equalTo(self.contentView).offset(-indicatorButtonRightOffset)
            make.centerY.equalTo(self.contentView)
        })

        title.snp_remakeConstraints { (make) -> () in
            make.left.equalTo(self.enabledSwitch.snp_right).offset(16)
            make.right.equalTo(self.contentView).offset(-rightSideWidth)
            make.top.equalTo(self.enabledSwitch)
        }

        subtitle.snp_remakeConstraints { (make) -> () in
            make.left.equalTo(self.enabledSwitch.snp_right).offset(16)
            make.right.equalTo(self.contentView).offset(-rightSideWidth)
            make.bottom.equalTo(self.enabledSwitch)
        }

        didSetupConstraints = true
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            setupConstraints()
        }
        super.updateConstraints()
    }
    
}

class SettingsSegmentedCell: UITableViewCell {
    
    init(segments: [String], reuseIdentifier: String?, selectorsTarget: AnyObject?, selector: String?) {
        segmentedControl = DVSwitch(stringsArray: segments)
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        if (selectorsTarget != nil && selector != nil) {
            self.segmentedControl.setPressedHandler { (index) -> Void in
                if Int(index) != self.lastIndex {
                    selectorsTarget!.perform(Selector(selector!))
                    self.lastIndex =  Int(index)
                }
            }
        }
        setupSubviews()
        self.setNeedsUpdateConstraints()
    }
    
    fileprivate let title = UILabel()
    fileprivate var segmentedControl: DVSwitch
    fileprivate var lastIndex: Int = 0
    fileprivate var didSetupSubviews: Bool = false
    fileprivate var didSetupConstraints: Bool = false
    
    var titleText: String {
        get { return self.title.text ?? "" }
        set(value) { self.title.text = value }
    }
    
    var selectedSegment: Int = 0 {
        didSet {
            segmentedControl.select(selectedSegment, animated: false)
            lastIndex = selectedSegment
        }
    }
    
//    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        setupSubviews()
//        self.setNeedsUpdateConstraints()
//    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        
        self.backgroundColor = Styles.Colors.cream1
        
        segmentedControl.backgroundView.layer.borderWidth = 0.8
        segmentedControl.backgroundView.layer.borderColor = Styles.Colors.anthracite1.cgColor
        segmentedControl.sliderColor = Styles.Colors.red2
        segmentedControl.backgroundColor = Styles.Colors.cream1
        segmentedControl.labelTextColorInsideSlider = Styles.Colors.cream1
        segmentedControl.labelTextColorOutsideSlider = Styles.Colors.anthracite1
        segmentedControl.font = Styles.FontFaces.regular(12)
        segmentedControl.cornerRadius = 15
        contentView.addSubview(segmentedControl)
        
        title.font = Styles.FontFaces.regular(14)
        title.textColor = Styles.Colors.midnight2
        title.textAlignment = .left
        contentView.addSubview(title)
        
        didSetupSubviews = true
    }
    
    func setupConstraints() {

        title.snp_remakeConstraints { (make) -> () in
            make.left.equalTo(self.contentView).offset(44)
            make.right.equalTo(self.segmentedControl.snp_left)
            make.centerY.equalTo(self.contentView)
        }

        segmentedControl.snp_remakeConstraints { (make) -> () in
            make.right.equalTo(self.contentView).offset(-20)
            make.centerY.equalTo(self.contentView)
//            make.height.equalTo(30)
            make.size.equalTo(CGSize(width: 144, height: 30))
        }

        didSetupConstraints = true
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            setupConstraints()
        }
        super.updateConstraints()
    }
    
}

class SettingsServiceSwitchCell: UITableViewCell {
    
    fileprivate let enabledSwitch = SevenSwitch()
    fileprivate let title = UILabel()
    fileprivate let button = ViewFactory.transparentRoundedButton()
    fileprivate var didSetupSubviews: Bool = false
    fileprivate var didSetupConstraints: Bool = false
    
    var selectorsTarget: AnyObject? {
        didSet {
            resetSelector()
        }
    }
    var switchSelector: String? {
        didSet {
            resetSelector()
        }
    }

    var buttonSelector: String? {
        didSet {
            resetSelector()
        }
    }

    var shouldShowSwitch: Bool = false {
        didSet {
            enabledSwitch.isHidden = !shouldShowSwitch
        }
    }
    
    var titleText: String {
        get { return self.title.text ?? "" }
        set(value) { self.title.text = value }
    }

    var signedIn: Bool? {
        didSet {
            if signedIn == nil {
                button.isHidden = true
            } else {
                button.isHidden = false
                if signedIn! {
                    button.setTitleColor(Styles.Colors.anthracite1, for: UIControlState())
                    button.layer.borderColor = Styles.Colors.anthracite1.cgColor
                    button.setTitle("sign_out".localizedString.uppercased(), for: UIControlState())
                } else {
                    button.setTitleColor(Styles.Colors.red2, for: UIControlState())
                    button.layer.borderColor = Styles.Colors.red2.cgColor
                    button.setTitle("sign_in".localizedString.uppercased(), for: UIControlState())
                }
            }
        }
    }

    var switchValue: Bool = false {
        didSet {
            enabledSwitch.on = switchValue
            enabledSwitchValueChanged(animated: false)
        }
    }

    fileprivate var titleTextColor: UIColor {
        return enabledSwitch.isOn() ? Styles.Colors.red2 : Styles.Colors.midnight2
    }
    
    fileprivate var cellBackgroundColor: UIColor {
        return enabledSwitch.isOn() ? Styles.Colors.white : Styles.Colors.cream1
    }
    
    func enabledSwitchValueChanged() {
        enabledSwitchValueChanged(animated: true)
    }
    
    func enabledSwitchValueChanged(animated: Bool) {
        UIView.animate(withDuration: animated ? 0.2 : 0, animations: { () -> Void in
            self.backgroundColor = self.cellBackgroundColor
        }) 
        UIView.transition(with: self.title, duration: (animated ? 0.2 : 0), options: UIViewAnimationOptions.transitionCrossDissolve, animations: { () -> Void in
            self.title.textColor = self.titleTextColor
            }, completion: nil)
    }
    
    func resetSelector() {
        enabledSwitch.removeTarget(nil, action: nil, for: .allEvents)
        if (selectorsTarget != nil && switchSelector != nil) {
            enabledSwitch.addTarget(selectorsTarget!, action: Selector(switchSelector!), for: .valueChanged)
            enabledSwitch.addTarget(self, action: #selector(SettingsSwitchCell.enabledSwitchValueChanged as (SettingsSwitchCell) -> () -> ()), for: .valueChanged)
        }
        if (selectorsTarget != nil && buttonSelector != nil) {
            button.addTarget(selectorsTarget!, action: Selector(buttonSelector!), for: .touchUpInside)
        }

    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
        self.setNeedsUpdateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        
        self.backgroundColor = cellBackgroundColor
        
        enabledSwitch.tintColor = Styles.Colors.stone
        enabledSwitch.onTintColor = Styles.Colors.cream1
        enabledSwitch.onTintColor = Styles.Colors.red2
        contentView.addSubview(enabledSwitch)
        
        resetSelector()
        
        button.layer.cornerRadius = 10
        button.titleLabel?.font = Styles.FontFaces.regular(10)
        contentView.addSubview(button)
        
        title.font = Styles.FontFaces.regular(14)
        title.textColor = titleTextColor
        title.textAlignment = .left
        contentView.addSubview(title)
        
        didSetupSubviews = true
    }
    
    func setupConstraints() {
        
        if shouldShowSwitch {
            enabledSwitch.snp_remakeConstraints { (make) -> () in
                make.left.equalTo(self.contentView).offset(20)
                make.centerY.equalTo(self.contentView)
                make.size.equalTo(CGSize(width: 50, height: 30))
            }
            
            title.snp_remakeConstraints { (make) -> () in
                make.left.equalTo(self.enabledSwitch.snp_right).offset(16)
                make.right.equalTo(self.button.snp_left)
                make.centerY.equalTo(self.contentView)
            }
        } else {
            title.snp_remakeConstraints { (make) -> () in
                make.left.equalTo(self.contentView).offset(44)
                make.right.equalTo(self.button.snp_left)
                make.centerY.equalTo(self.contentView)
            }
        }
        
        button.snp_remakeConstraints { (make) -> () in
            make.right.equalTo(self.contentView).offset(-20)
            make.centerY.equalTo(self.contentView)
            make.size.equalTo(CGSize(width: 74, height: 20))
        }

        didSetupConstraints = true
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            setupConstraints()
        }
        super.updateConstraints()
    }
}

class SettingsTextEntryCell: UITableViewCell, UITextFieldDelegate {
    
    fileprivate let textField = UITextField()
    fileprivate var didSetupSubviews: Bool = false
    fileprivate var didSetupConstraints: Bool = false
    
    var INDENT = 25
    var BACKGROUND_COLOR = Styles.Colors.cream1
    var PLACEHOLDER_TEXT_COLOR = Styles.Colors.petrol2
    var TEXT_COLOR = Styles.Colors.anthracite1
    var TEXT_COLOR_RED = Styles.Colors.red2
    
    var selectorsTarget: AnyObject?
    var editCallback: String?
    var returnCallback: String?

    var textFieldTag: Int? {
        didSet {
            textField.tag = textFieldTag ?? 0
        }
    }

    var keyboardType: UIKeyboardType = .default {
        didSet {
            textField.keyboardType = keyboardType
        }
    }
    
    var returnKeyType: UIReturnKeyType = .default {
        didSet {
            textField.returnKeyType = returnKeyType
        }
    }
    
    var autocorrectionType: UITextAutocorrectionType = .default {
        didSet {
            textField.autocorrectionType = autocorrectionType
        }
    }

    var secureTextEntry: Bool = false {
        didSet {
            textField.isSecureTextEntry = secureTextEntry
        }
    }

    var placeholderText: String = "" {
        didSet {
            setPlaceholderText()
        }
    }
    
    var mainText: String {
        get { return self.textField.text ?? "" }
        set(value) { self.textField.text = value }
    }
    
    var hasRedTint: Bool = false {
        didSet {
            setPlaceholderText()
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
        self.setNeedsUpdateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        
        self.backgroundColor = BACKGROUND_COLOR
        
        textField.addTarget(self, action: #selector(SettingsTextEntryCell.textFieldUpdated), for: .editingChanged)
        textField.delegate = self
        textField.clearButtonMode = UITextFieldViewMode.whileEditing
        textField.font = Styles.FontFaces.light(12)
        setPlaceholderText()
        textField.textAlignment = NSTextAlignment.natural
        contentView.addSubview(textField)
        
        didSetupSubviews = true
    }
    
    func setupConstraints() {
        
        textField.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.contentView).offset(INDENT)
            make.right.equalTo(self.contentView).offset(-INDENT)
            make.centerY.equalTo(self.contentView)
        }
        
        didSetupConstraints = true
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            setupConstraints()
        }
        super.updateConstraints()
    }
    
    fileprivate func setPlaceholderText() {
        let attributes = [NSFontAttributeName: Styles.FontFaces.regular(12), NSForegroundColorAttributeName: hasRedTint ? TEXT_COLOR_RED : PLACEHOLDER_TEXT_COLOR]
        self.textField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: attributes)
    }

    func textFieldUpdated() {
        if selectorsTarget != nil && editCallback != nil {
            let userInfo = [self.placeholderText : self.mainText]
            Timer.scheduledTimer(timeInterval: 0, target: selectorsTarget!, selector: Selector(editCallback!), userInfo: userInfo, repeats: false)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if selectorsTarget != nil && returnCallback != nil {
            let userInfo = ["textFieldTag" : textField.tag]
            Timer.scheduledTimer(timeInterval: 0, target: selectorsTarget!, selector: Selector(returnCallback!), userInfo: userInfo, repeats: false)
        }
        textField.resignFirstResponder()
        return true
    }

}

class SettingsDoubleTextEntryCell: UITableViewCell, UITextFieldDelegate {
    
    fileprivate let separator = UIView()
    fileprivate let textFieldLeft = UITextField()
    fileprivate let textFieldRight = UITextField()
    fileprivate var didSetupSubviews: Bool = false
    fileprivate var didSetupConstraints: Bool = false
    
    var INDENT = 25
    var BACKGROUND_COLOR = Styles.Colors.cream1
    var SEPARATOR_COLOR = Styles.Colors.stone
    var PLACEHOLDER_TEXT_COLOR = Styles.Colors.petrol2
    var TEXT_COLOR = Styles.Colors.anthracite1
    var TEXT_COLOR_RED = Styles.Colors.red2
    
    var selectorsTarget: AnyObject?
    var editCallback: String?
    var returnCallback: String?
    
    var textFieldTag: Int? {
        didSet {
            textFieldLeft.tag = textFieldTag ?? 0
            textFieldRight.tag = (textFieldTag ?? 0) + 1
        }
    }
    
    var keyboardType: UIKeyboardType = .default {
        didSet {
            textFieldLeft.keyboardType = keyboardType
            textFieldRight.keyboardType = keyboardType
        }
    }
    
    var returnKeyType: UIReturnKeyType = .default {
        didSet {
            textFieldLeft.returnKeyType = returnKeyType
            textFieldRight.returnKeyType = returnKeyType
        }
    }
    
    var autocorrectionType: UITextAutocorrectionType = .default {
        didSet {
            textFieldLeft.autocorrectionType = autocorrectionType
            textFieldRight.autocorrectionType = autocorrectionType
        }
    }
    
    var secureTextEntry: Bool = false {
        didSet {
            textFieldLeft.isSecureTextEntry = secureTextEntry
            textFieldRight.isSecureTextEntry = secureTextEntry
        }
    }

    var placeholderTextLeft: String = "" {
        didSet {
            setPlaceholderText()
        }
    }
    
    var placeholderTextRight: String = "" {
        didSet {
            setPlaceholderText()
        }
    }
    
    var mainTextLeft: String {
        get { return self.textFieldLeft.text ?? "" }
        set(value) { self.textFieldLeft.text = value }
    }

    var mainTextRight: String {
        get { return self.textFieldRight.text ?? "" }
        set(value) { self.textFieldRight.text = value }
    }
    
    var leftHasRedTint: Bool = false {
        didSet {
            setPlaceholderText()
        }
    }
    
    var rightHasRedTint: Bool = false {
        didSet {
            setPlaceholderText()
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
        self.setNeedsUpdateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupSubviews() {
        
        self.backgroundColor = BACKGROUND_COLOR
        
        textFieldLeft.addTarget(self, action: #selector(SettingsTextEntryCell.textFieldUpdated), for: .editingChanged)
        textFieldLeft.delegate = self
        textFieldLeft.clearButtonMode = UITextFieldViewMode.whileEditing
        textFieldLeft.font = Styles.FontFaces.light(12)
        textFieldLeft.textAlignment = NSTextAlignment.natural
        contentView.addSubview(textFieldLeft)
        
        textFieldRight.addTarget(self, action: #selector(SettingsTextEntryCell.textFieldUpdated), for: .editingChanged)
        textFieldRight.delegate = self
        textFieldRight.clearButtonMode = textFieldLeft.clearButtonMode
        textFieldRight.font = textFieldLeft.font
        textFieldRight.textAlignment = textFieldLeft.textAlignment
        contentView.addSubview(textFieldRight)
        
        setPlaceholderText()
        
        separator.isUserInteractionEnabled = false
        separator.backgroundColor = SEPARATOR_COLOR
        contentView.addSubview(separator)
        
        didSetupSubviews = true
    }
    
    func setupConstraints() {
        
        textFieldLeft.snp_remakeConstraints { (make) -> () in
            make.left.equalTo(self.contentView).offset(INDENT)
            make.right.equalTo(self.contentView.snp_centerX)
            make.centerY.equalTo(self.contentView)
        }

        textFieldRight.snp_remakeConstraints { (make) -> () in
            make.left.equalTo(self.contentView.snp_centerX).offset(INDENT)
            make.right.equalTo(self.contentView).offset(-INDENT)
            make.centerY.equalTo(self.contentView)
        }

        separator.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView)
            make.width.equalTo(2)
            make.centerX.equalTo(self.contentView)
        }
        didSetupConstraints = true
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            setupConstraints()
        }
        super.updateConstraints()
    }
    
    fileprivate func setPlaceholderText() {
        
        let leftAttributes = [NSFontAttributeName: Styles.FontFaces.regular(12), NSForegroundColorAttributeName: leftHasRedTint ? TEXT_COLOR_RED : PLACEHOLDER_TEXT_COLOR]
        self.textFieldLeft.attributedPlaceholder = NSAttributedString(string: placeholderTextLeft, attributes: leftAttributes)
        
        let rightAttributes = [NSFontAttributeName: Styles.FontFaces.regular(12), NSForegroundColorAttributeName: rightHasRedTint ? TEXT_COLOR_RED : PLACEHOLDER_TEXT_COLOR]
        self.textFieldRight.attributedPlaceholder = NSAttributedString(string: placeholderTextRight, attributes: rightAttributes)
    }

    func textFieldUpdated() {
        if selectorsTarget != nil && editCallback != nil {
            let userInfo = [self.placeholderTextLeft : self.mainTextLeft,
                self.placeholderTextRight : self.mainTextRight]
            Timer.scheduledTimer(timeInterval: 0, target: selectorsTarget!, selector: Selector(editCallback!), userInfo: userInfo, repeats: false)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == textFieldLeft {
            textFieldRight.becomeFirstResponder()
        } else {
            if selectorsTarget != nil && returnCallback != nil {
                let userInfo = ["textFieldTag" : textField.tag]
                Timer.scheduledTimer(timeInterval: 0, target: selectorsTarget!, selector: Selector(returnCallback!), userInfo: userInfo, repeats: false)
            }
        }
        textField.resignFirstResponder()
        return true
    }

}
