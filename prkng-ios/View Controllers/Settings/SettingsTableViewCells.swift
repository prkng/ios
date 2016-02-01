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
        return self.cellType.rawValue + self.titleText + (self.rightSideText ?? "") + placeholderTexts.joinWithSeparator("")
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
    var bold: Bool = false
    var redText: Bool = false
    var userInfo: AnyObject? = nil //for custom cells not included in this file!
    
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
        bold: Bool = false,
        redText: Bool = false,
        userInfo: AnyObject? = nil
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

    func tableViewCell(tableView: UITableView) -> UITableViewCell {
        
        if let ppSettingsCell = self as? PPSettingsCell {
            return ppSettingsCell.tableViewCell
        }
        
        switch self.cellType {
            
        case .Switch, .PermitSwitch:
            var cell = tableView.dequeueReusableCellWithIdentifier(self.id) as? SettingsSwitchCell
            if cell == nil {
                cell = SettingsSwitchCell(style: .Default, reuseIdentifier: self.id)
            }
            cell!.titleText = self.titleText
            cell!.subtitleText = self.subtitleText
            cell!.switchOn = self.switchValue ?? false
            cell!.selectorsTarget = self.selectorsTarget
            cell!.selector = self.switchSelector
            cell!.buttonSelector = self.buttonSelector
            cell!.rightSideText = self.rightSideText
            return cell!
            
        case .Segmented:
            var cell = tableView.dequeueReusableCellWithIdentifier(self.id) as? SettingsSegmentedCell
            if cell == nil {
                cell = SettingsSegmentedCell(segments: self.segments, reuseIdentifier: self.id, selectorsTarget: self.selectorsTarget, selector: self.switchSelector)
            }
            cell!.titleText = self.titleText
            cell!.selectedSegment = self.defaultSegment
            return cell!
            
        case .Service, .ServiceSwitch:
            var cell = tableView.dequeueReusableCellWithIdentifier(self.id) as? SettingsServiceSwitchCell
            if cell == nil {
                cell = SettingsServiceSwitchCell(style: .Default, reuseIdentifier: self.id)
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
            var cell = tableView.dequeueReusableCellWithIdentifier(self.id) as? SettingsBasicCell
            if cell == nil {
                cell = SettingsBasicCell(style: .Default, reuseIdentifier: self.id)
            }
            cell!.titleText = self.titleText
            cell!.bold = self.bold
            cell!.redText = self.redText
            return cell!
            
        case .TextEntry:
            var cell = tableView.dequeueReusableCellWithIdentifier(self.id) as? SettingsTextEntryCell
            if cell == nil {
                cell = SettingsTextEntryCell(style: .Default, reuseIdentifier: self.id)
            }
            cell!.placeholderText = self.placeholderText
            cell!.mainText = self.titleText
            cell!.selectorsTarget = self.selectorsTarget
            cell!.callback = self.callback
            return cell!
            
        case .DoubleTextEntry:
            var cell = tableView.dequeueReusableCellWithIdentifier(self.id) as? SettingsDoubleTextEntryCell
            if cell == nil {
                cell = SettingsDoubleTextEntryCell(style: .Default, reuseIdentifier: self.id)
            }
            cell!.placeholderTextLeft = self.placeholderTexts.first ?? ""
            cell!.mainTextLeft = self.titleTexts.first ?? ""
            cell!.placeholderTextRight = self.placeholderTexts.last ?? ""
            cell!.mainTextRight = self.titleTexts.last ?? ""
            cell!.selectorsTarget = self.selectorsTarget
            cell!.callback = self.callback
            return cell!
            
        }
    }

}

class SettingsBasicCell: UITableViewCell {

    private let title = UILabel()
    private var didLayoutSubviews: Bool = false
    
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
    
    private func setFont(bold bold: Bool) {
        if bold {
            title.font = Styles.FontFaces.bold(14)
        } else {
            title.font = Styles.FontFaces.regular(14)
        }
    }
    
    override func layoutSubviews() {

        if !didLayoutSubviews {
            self.backgroundColor = Styles.Colors.cream1
            
            self.setFont(bold: bold)
            title.textAlignment = .Left
            contentView.addSubview(title)
            
            didLayoutSubviews = true
            setNeedsUpdateConstraints()
        }
        super.layoutSubviews()
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        title.snp_remakeConstraints { (make) -> () in
            make.left.equalTo(self.contentView).offset(40)
            make.right.equalTo(self.contentView)
            make.centerY.equalTo(self.contentView)
        }

    }
}

class SettingsSwitchCell: UITableViewCell {
    
    private let enabledSwitch = SevenSwitch()
    private let title = UILabel()
    private let subtitle = UILabel()
    private var didLayoutSubviews: Bool = false
    
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
    
    private var indicatorButton: UIButton?
    var rightSideText: String? {
        didSet {
            
            if rightSideText != nil {
                
                //first of all, make the add button into an x instead of a +
                addButton = nil//ViewFactory.smallAccessoryCloseButton()
                
                //create the indicator button
                indicatorButton = ViewFactory.redRoundedButtonWithHeight(22, font: Styles.FontFaces.regular(14), text: "")
                let attrs = [NSFontAttributeName: indicatorButton!.titleLabel!.font]
                let maximumLabelSize = CGSize(width: 200, height: 22)
                let labelRect = (rightSideText! as NSString).boundingRectWithSize(maximumLabelSize, options: NSStringDrawingOptions(), attributes: attrs, context: nil)
                
                //add the close icon --> if we ever wish to re-add this, just add (5+closeImageView.frame.width) to the width of indicatorButton.frame
                let closeImageView = UIImageView(image: UIImage(named:"icon_close"))
                closeImageView.contentMode = .ScaleAspectFit
                closeImageView.frame = CGRect(x: 10+labelRect.width+5, y: 6, width: 11, height: 11)
                indicatorButton!.addSubview(closeImageView)
                
                //add the label
                let label = UILabel(frame: CGRect(x: 10, y: 2.5, width: labelRect.width, height: labelRect.height))
                label.text = rightSideText!
                label.font = indicatorButton!.titleLabel!.font
                label.textColor = Styles.Colors.beige1
                indicatorButton!.addSubview(label)
                
                indicatorButton!.frame = rightSideText! == "" ? CGRectZero : CGRect(x: 0, y: 0, width: 10+labelRect.width+10 + 5+closeImageView.frame.width, height: 22)
                indicatorButton!.addTarget(self, action: "indicatorButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
            }
        }
    }
    
    func indicatorButtonTapped() {
        if (selectorsTarget != nil && buttonSelector != nil) {
            selectorsTarget!.performSelector(Selector(buttonSelector!))
        }
    }

    var buttonSelector: String? {
        didSet {
            if buttonSelector != nil {
                addButton = ViewFactory.smallAccessoryPlusButton()
                resetSelector()
            }
        }
    }
    
    private var addButton: UIButton?
    var selectorsTarget: AnyObject?
    var selector: String?
    
    private var cellBackgroundColor: UIColor {
        return enabledSwitch.isOn() ? Styles.Colors.white : Styles.Colors.cream1
    }

    func enabledSwitchValueChanged() {
        enabledSwitchValueChanged(animated: true)
    }
    
    func enabledSwitchValueChanged(animated animated: Bool) {
        UIView.animateWithDuration(animated ? 0.2 : 0) { () -> Void in
            self.backgroundColor = self.cellBackgroundColor
        }
    }
    
    func resetSelector() {
        enabledSwitch.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
        if (selectorsTarget != nil && selector != nil) {
            enabledSwitch.addTarget(selectorsTarget!, action: Selector(selector!), forControlEvents: .ValueChanged)
            enabledSwitch.addTarget(self, action: "enabledSwitchValueChanged", forControlEvents: .ValueChanged)
        }
        if (selectorsTarget != nil && buttonSelector != nil) {
            addButton?.addTarget(selectorsTarget!, action: Selector(buttonSelector!), forControlEvents: .TouchUpInside)
        }
    }

    override func layoutSubviews() {
        
        if !didLayoutSubviews {
            self.backgroundColor = cellBackgroundColor
            
            enabledSwitch.tintColor = Styles.Colors.stone
            enabledSwitch.onTintColor = Styles.Colors.cream1
            enabledSwitch.onTintColor = Styles.Colors.red2
            resetSelector()
            contentView.addSubview(enabledSwitch)
            
            title.font = Styles.FontFaces.regular(14)
            title.textColor = Styles.Colors.red2
            title.textAlignment = .Left
            contentView.addSubview(title)

            subtitle.font = Styles.FontFaces.light(12)
            subtitle.textColor = Styles.Colors.anthracite1
            subtitle.textAlignment = .Left
            contentView.addSubview(subtitle)
            
            if addButton != nil {
                contentView.addSubview(addButton!)
            }
            
            if indicatorButton != nil {
                contentView.addSubview(indicatorButton!)
            }

            didLayoutSubviews = true
            setNeedsUpdateConstraints()
        }
        super.layoutSubviews()
    }
    
    override func updateConstraints() {
        
        super.updateConstraints()
        
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

    }
    
}

class SettingsSegmentedCell: UITableViewCell {
    
    init(segments: [String], reuseIdentifier: String?, selectorsTarget: AnyObject?, selector: String?) {
        segmentedControl = DVSwitch(stringsArray: segments)
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        if (selectorsTarget != nil && selector != nil) {
            self.segmentedControl.setPressedHandler { (index) -> Void in
                if Int(index) != self.lastIndex {
                    selectorsTarget!.performSelector(Selector(selector!))
                    self.lastIndex =  Int(index)
                }
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let title = UILabel()
    private var segmentedControl: DVSwitch
    private var lastIndex: Int = 0
    private var didLayoutSubviews: Bool = false
    
    var titleText: String {
        get { return self.title.text ?? "" }
        set(value) { self.title.text = value }
    }
    
    var selectedSegment: Int = 0 {
        didSet {
            segmentedControl.selectIndex(selectedSegment, animated: false)
            lastIndex = selectedSegment
        }
    }
    
    override func layoutSubviews() {
        
        if !didLayoutSubviews {
            self.backgroundColor = Styles.Colors.cream1
            
            segmentedControl.backgroundView.layer.borderWidth = 0.8
            segmentedControl.backgroundView.layer.borderColor = Styles.Colors.anthracite1.CGColor
            segmentedControl.sliderColor = Styles.Colors.red2
            segmentedControl.backgroundColor = Styles.Colors.cream1
            segmentedControl.labelTextColorInsideSlider = Styles.Colors.cream1
            segmentedControl.labelTextColorOutsideSlider = Styles.Colors.anthracite1
            segmentedControl.font = Styles.FontFaces.regular(12)
            segmentedControl.cornerRadius = 15
            contentView.addSubview(segmentedControl)
            
            title.font = Styles.FontFaces.regular(14)
            title.textColor = Styles.Colors.midnight2
            title.textAlignment = .Left
            contentView.addSubview(title)

            didLayoutSubviews = true
            setNeedsUpdateConstraints()
        }
        super.layoutSubviews()
    }
    
    override func updateConstraints() {
        
        super.updateConstraints()

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

    }
    
}

class SettingsServiceSwitchCell: UITableViewCell {
    
    private let enabledSwitch = SevenSwitch()
    private let title = UILabel()
    private let button = ViewFactory.transparentRoundedButton()
    private var didLayoutSubviews: Bool = false
    
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
            enabledSwitch.hidden = !shouldShowSwitch
        }
    }
    
    var titleText: String {
        get { return self.title.text ?? "" }
        set(value) { self.title.text = value }
    }

    var signedIn: Bool? {
        didSet {
            if signedIn == nil {
                button.hidden = true
            } else {
                button.hidden = false
                if signedIn! {
                    button.setTitleColor(Styles.Colors.anthracite1, forState: UIControlState.Normal)
                    button.layer.borderColor = Styles.Colors.anthracite1.CGColor
                    button.setTitle("sign_out".localizedString.uppercaseString, forState: .Normal)
                } else {
                    button.setTitleColor(Styles.Colors.red2, forState: UIControlState.Normal)
                    button.layer.borderColor = Styles.Colors.red2.CGColor
                    button.setTitle("sign_in".localizedString.uppercaseString, forState: .Normal)
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

    private var titleTextColor: UIColor {
        return enabledSwitch.isOn() ? Styles.Colors.red2 : Styles.Colors.midnight2
    }
    
    private var cellBackgroundColor: UIColor {
        return enabledSwitch.isOn() ? Styles.Colors.white : Styles.Colors.cream1
    }
    
    func enabledSwitchValueChanged() {
        enabledSwitchValueChanged(animated: true)
    }
    
    func enabledSwitchValueChanged(animated animated: Bool) {
        UIView.animateWithDuration(animated ? 0.2 : 0) { () -> Void in
            self.backgroundColor = self.cellBackgroundColor
        }
        UIView.transitionWithView(self.title, duration: (animated ? 0.2 : 0), options: UIViewAnimationOptions.TransitionCrossDissolve, animations: { () -> Void in
            self.title.textColor = self.titleTextColor
            }, completion: nil)
    }
    
    func resetSelector() {
        enabledSwitch.removeTarget(nil, action: nil, forControlEvents: .AllEvents)
        if (selectorsTarget != nil && switchSelector != nil) {
            enabledSwitch.addTarget(selectorsTarget!, action: Selector(switchSelector!), forControlEvents: .ValueChanged)
            enabledSwitch.addTarget(self, action: "enabledSwitchValueChanged", forControlEvents: .ValueChanged)
        }
        if (selectorsTarget != nil && buttonSelector != nil) {
            button.addTarget(selectorsTarget!, action: Selector(buttonSelector!), forControlEvents: .TouchUpInside)
        }

    }

    override func layoutSubviews() {
        
        if !didLayoutSubviews {
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
            title.textAlignment = .Left
            contentView.addSubview(title)

            didLayoutSubviews = true
            setNeedsUpdateConstraints()
        }
        super.layoutSubviews()
    }
    
    override func updateConstraints() {
        
        super.updateConstraints()
        
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

    }
}

class SettingsTextEntryCell: UITableViewCell {
    
    private let textField = UITextField()
    private var didLayoutSubviews: Bool = false
    
    var LEFT_INDENT = 25
    var BACKGROUND_COLOR = Styles.Colors.cream1
    var TEXT_COLOR = Styles.Colors.anthracite1
    
    var selectorsTarget: AnyObject?
    var callback: String?

    var placeholderText: String {
        get { return self.textField.placeholder ?? "" }
        set(value) {
            let attributes = [NSFontAttributeName: Styles.FontFaces.regular(12), NSForegroundColorAttributeName: Styles.Colors.petrol2]
            self.textField.attributedPlaceholder = NSAttributedString(string: value, attributes: attributes)
        }
    }
    
    var mainText: String {
        get { return self.textField.text ?? "" }
        set(value) { self.textField.text = value }
    }
    
    override func layoutSubviews() {
        
        if !didLayoutSubviews {
            self.backgroundColor = BACKGROUND_COLOR
            
            textField.addTarget(self, action: "textFieldUpdated", forControlEvents: .EditingChanged)
            textField.clearButtonMode = UITextFieldViewMode.WhileEditing
            textField.font = Styles.FontFaces.light(12)
            textField.textColor = TEXT_COLOR
            textField.textAlignment = NSTextAlignment.Natural
            contentView.addSubview(textField)
            
            didLayoutSubviews = true
            setNeedsUpdateConstraints()
        }
        super.layoutSubviews()
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        textField.snp_remakeConstraints { (make) -> () in
            make.left.equalTo(self.contentView).offset(LEFT_INDENT)
            make.right.equalTo(self.contentView)
            make.centerY.equalTo(self.contentView)
        }
    }

    func textFieldUpdated() {
        if selectorsTarget != nil && callback != nil {
            let userInfo = [self.placeholderText : self.mainText]
            NSTimer.scheduledTimerWithTimeInterval(0, target: selectorsTarget!, selector: Selector(callback!), userInfo: userInfo, repeats: false)
        }
    }

}

class SettingsDoubleTextEntryCell: UITableViewCell {
    
    private let separator = UIView()
    private let textFieldLeft = UITextField()
    private let textFieldRight = UITextField()
    private var didLayoutSubviews: Bool = false
    
    var LEFT_INDENT = 25
    var BACKGROUND_COLOR = Styles.Colors.cream1
    var SEPARATOR_COLOR = Styles.Colors.stone
    var TEXT_COLOR = Styles.Colors.anthracite1
    
    var selectorsTarget: AnyObject?
    var callback: String?
    
    var placeholderTextLeft: String {
        get { return self.textFieldLeft.placeholder ?? "" }
        set(value) {
            let attributes = [NSFontAttributeName: Styles.FontFaces.regular(12), NSForegroundColorAttributeName: Styles.Colors.petrol2]
            self.textFieldLeft.attributedPlaceholder = NSAttributedString(string: value, attributes: attributes)
        }
    }
    
    var placeholderTextRight: String {
        get { return self.textFieldRight.placeholder ?? "" }
        set(value) {
            let attributes = [NSFontAttributeName: Styles.FontFaces.regular(12), NSForegroundColorAttributeName: Styles.Colors.petrol2]
            self.textFieldRight.attributedPlaceholder = NSAttributedString(string: value, attributes: attributes)
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
    
    override func layoutSubviews() {
        
        if !didLayoutSubviews {
            self.backgroundColor = BACKGROUND_COLOR
            
            textFieldLeft.addTarget(self, action: "textFieldUpdated", forControlEvents: .EditingChanged)
            textFieldLeft.clearButtonMode = UITextFieldViewMode.WhileEditing
            textFieldLeft.font = Styles.FontFaces.light(12)
            textFieldLeft.textColor = TEXT_COLOR
            textFieldLeft.textAlignment = NSTextAlignment.Natural
            contentView.addSubview(textFieldLeft)

            textFieldRight.addTarget(self, action: "textFieldUpdated", forControlEvents: .EditingChanged)
            textFieldRight.clearButtonMode = textFieldLeft.clearButtonMode
            textFieldRight.font = textFieldLeft.font
            textFieldRight.textColor = textFieldLeft.textColor
            textFieldRight.textAlignment = textFieldLeft.textAlignment
            contentView.addSubview(textFieldRight)

            separator.userInteractionEnabled = false
            separator.backgroundColor = SEPARATOR_COLOR
            contentView.addSubview(separator)
            
            didLayoutSubviews = true
            setNeedsUpdateConstraints()
        }
        super.layoutSubviews()
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        textFieldLeft.snp_remakeConstraints { (make) -> () in
            make.left.equalTo(self.contentView).offset(LEFT_INDENT)
            make.right.equalTo(self.contentView.snp_centerX)
            make.centerY.equalTo(self.contentView)
        }

        textFieldRight.snp_remakeConstraints { (make) -> () in
            make.left.equalTo(self.contentView.snp_centerX).offset(LEFT_INDENT)
            make.right.equalTo(self.contentView)
            make.centerY.equalTo(self.contentView)
        }

        separator.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView)
            make.width.equalTo(2)
            make.centerX.equalTo(self.contentView)
        }
        
    }
    
    func textFieldUpdated() {
        if selectorsTarget != nil && callback != nil {
            let userInfo = [self.placeholderTextLeft : self.mainTextLeft,
                self.placeholderTextRight : self.mainTextRight]
            NSTimer.scheduledTimerWithTimeInterval(0, target: selectorsTarget!, selector: Selector(callback!), userInfo: userInfo, repeats: false)
        }
    }

}