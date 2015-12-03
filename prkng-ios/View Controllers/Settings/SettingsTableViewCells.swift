//
//  HistoryTableViewCell.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 16/06/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

enum SettingsTableViewCellType {
    case Switch //switch on the left followed by 2 lines (title, subtitle)
    case Segmented //title followed by segmented switch
    case Service //title followed by rounded button
    case ServiceSwitch //switch followed by Service ^
    case PermitSwitch //switch with permit acessory view
    case Basic //title, possibly red.
}

class SettingsCell {
    var titleText: String = ""
    var subtitleText: String = ""
    var segments: [String] = []
    var defaultSegment: Int = 0
    var signedIn: Bool?
    var switchValue: Bool?
    var parentVC: UIViewController?
    var switchSelector: String?
    var buttonSelector: String?
    var rightSideText: String?
    var cellType: SettingsTableViewCellType = .Basic
    
    //this init infers a Switch or PermitSwitch type
    init(switchValue: Bool, titleText: String, subtitleText: String, parentVC: UIViewController? = nil, switchSelector: String? = nil, buttonSelector: String? = nil, rightSideText: String? = nil) {
        self.cellType = buttonSelector == nil ? .Switch : .PermitSwitch
        self.switchValue = switchValue
        self.titleText = titleText
        self.subtitleText = subtitleText
        self.parentVC = parentVC
        self.switchSelector = switchSelector
        self.buttonSelector = buttonSelector
        self.rightSideText = rightSideText
    }

    init(cellType: SettingsTableViewCellType, titleText: String, parentVC: UIViewController? = nil, switchSelector: String? = nil, buttonSelector: String? = nil) {
        self.cellType = cellType
        self.titleText = titleText
        self.parentVC = parentVC
        self.switchSelector = switchSelector
        self.buttonSelector = buttonSelector
    }

    //this init infers Service/ServiceSwitch types
    init(titleText: String, signedIn: Bool?, switchValue: Bool?, parentVC: UIViewController? = nil, switchSelector: String? = nil, buttonSelector: String? = nil) {
        self.cellType = switchValue != nil ? .ServiceSwitch : .Service
        self.titleText = titleText
        self.signedIn = signedIn
        self.switchValue = switchValue
        self.parentVC = parentVC
        self.switchSelector = switchSelector
        self.buttonSelector = buttonSelector
    }

    //this init infers Switch type
    init(titleText: String, switchValue: Bool) {
        self.cellType = .Switch
        self.titleText = titleText
        self.switchValue = switchValue
    }

    //this init infers Segmented type
    init(titleText: String, segments: [String], defaultSegment: Int, parentVC: UIViewController? = nil, switchSelector: String? = nil) {
        self.cellType = .Segmented
        self.titleText = titleText
        self.segments = segments
        self.defaultSegment = defaultSegment
        self.parentVC = parentVC
        self.switchSelector = switchSelector
    }

}

class SettingsBasicCell: UITableViewCell {

    private let title = UILabel()
    private var didLayoutSubviews: Bool = false
    
    var redText: Bool {
        get { return title.textColor == Styles.Colors.red2 }
        set(value) { title.textColor = value ? Styles.Colors.red2 : Styles.Colors.midnight2 }
    }
    
    var titleText: String {
        get { return self.title.text ?? "" }
        set(value) { self.title.text = value }
    }
    
    override func layoutSubviews() {

        if !didLayoutSubviews {
            self.backgroundColor = Styles.Colors.cream1
            
            title.font = Styles.FontFaces.regular(14)
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
        if (parentVC != nil && buttonSelector != nil) {
            parentVC!.performSelector(Selector(buttonSelector!))
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
    var parentVC: UIViewController?
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
        if (parentVC != nil && selector != nil) {
            enabledSwitch.addTarget(parentVC!, action: Selector(selector!), forControlEvents: .ValueChanged)
            enabledSwitch.addTarget(self, action: "enabledSwitchValueChanged", forControlEvents: .ValueChanged)
        }
        if (parentVC != nil && buttonSelector != nil) {
            addButton?.addTarget(parentVC!, action: Selector(buttonSelector!), forControlEvents: .TouchUpInside)
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
    
    init(segments: [String], reuseIdentifier: String?, parentVC: UIViewController?, selector: String?) {
        segmentedControl = DVSwitch(stringsArray: segments)
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        if (parentVC != nil && selector != nil) {
            self.segmentedControl.setPressedHandler { (index) -> Void in
                if Int(index) != self.lastIndex {
                    parentVC!.performSelector(Selector(selector!))
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
    
    var parentVC: UIViewController? {
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
        if (parentVC != nil && switchSelector != nil) {
            enabledSwitch.addTarget(parentVC!, action: Selector(switchSelector!), forControlEvents: .ValueChanged)
            enabledSwitch.addTarget(self, action: "enabledSwitchValueChanged", forControlEvents: .ValueChanged)
        }
        if (parentVC != nil && buttonSelector != nil) {
            button.addTarget(parentVC!, action: Selector(buttonSelector!), forControlEvents: .TouchUpInside)
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
