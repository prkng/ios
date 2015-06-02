//
//  SelectionControl.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 30/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class SelectionControl: UIControl {
    
    var didSetupSubviews: Bool
    var didSetupConstraints: Bool
    
    var titles : Array<String>
    
    var buttonContainers : Array<UIView>
    var buttons : Array<SelectionButton>
    
    var selectedIndex : Int
    
    var buttonSize : CGSize
    var borderColor : UIColor?
    var selectedBorderColor : UIColor?
    var textColor : UIColor?
    var selectedTextColor : UIColor?
    var buttonBackgroundColor : UIColor?
    var selectedButtonBackgroundColor : UIColor?
    var font : UIFont?
    
    convenience init(titles : Array<String>) {
        self.init(frame:CGRectZero)
        self.titles = titles
        
        var i : Int = 0
        for title in titles {
            buttons.append(SelectionButton(title:title, index : i++))
        }
        
    }
    
    override init(frame: CGRect) {
        titles = []
        buttons = []
        buttonContainers = []
        didSetupSubviews = false
        didSetupConstraints = true
        buttonSize = CGSizeMake(110, 26) // Default
        selectedIndex = 0
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    
    override func layoutSubviews() {
        
        if(!didSetupSubviews) {
            setupSubviews()
            didSetupConstraints = false
            self.setNeedsUpdateConstraints()
        }
        
        selectOption(self.buttons[selectedIndex])
        
        super.layoutSubviews()
    }
    
    override func updateConstraints() {
        
        if(!didSetupConstraints) {
            setupConstraints()
        }
        super.updateConstraints()
    }
    
    func setupSubviews() {
        
        var index : Int = 0
        
        for title in titles {
            
            let buttonContainer = UIView()
            addSubview(buttonContainer)
            buttonContainers.append(buttonContainer)
            
            let button = buttons[index]
            
            if borderColor != nil {
                button.borderColor = borderColor!
            }
            
            if selectedBorderColor != nil {
                button.selectedBorderColor = selectedBorderColor!
            }
            
            if textColor != nil  {
                button.textColor = textColor!
            }
            
            if selectedTextColor != nil {
                button.selectedTextColor = selectedTextColor!
            }
            
            if buttonBackgroundColor != nil {
                button.buttonBackgroundColor = buttonBackgroundColor!
            }
            
            if selectedButtonBackgroundColor != nil {
                button.selectedButtonBackgroundColor = selectedButtonBackgroundColor!
            }
            
            if font != nil {
                button.font = font!
            }
            
            button.layer.cornerRadius =  self.buttonSize.height / 2.0
            button.addTarget(self, action: "selectOption:", forControlEvents: UIControlEvents.TouchUpInside)
            button.selected = (selectedIndex == index)
            buttonContainer.addSubview(button)
            
            index++
        }        
        
        didSetupSubviews = true
    }
    
    func setupConstraints() {
        
        if(buttons.count == 1) {
            
            buttons[0].snp_makeConstraints({ (make) -> () in
                make.center.equalTo(self)
                make.size.equalTo(self.buttonSize)
            })
            
        } else if (buttons.count > 1) {
            
            
            for index in 0...buttons.count-1 {
                
                let multiplier : Float = 2.0 * Float(index + 1) / (Float(buttons.count + 1) )  // MAGIC =)
                NSLog("multiplier : %f", multiplier)
                
                buttonContainers[index].snp_makeConstraints({ (make) -> () in
                    make.width.equalTo(self).multipliedBy(1.0 / Float(self.buttons.count))
                    make.height.equalTo(self)
                    make.centerX.equalTo(self).multipliedBy(multiplier)
                    make.top.equalTo(self)
                    make.bottom.equalTo(self)
                })

                
                buttons[index].snp_makeConstraints({ (make) -> () in
                    make.center.equalTo(self.buttonContainers[index])
                    make.size.equalTo(self.buttonSize)
                })
                
            }
            
            
            
            
        }
        
        didSetupConstraints = true
    }
    
    private func deselectAll () {
        
        for button in buttons {
            button.selected = false
        }
        
    }
    
    
    func selectOption (sender : SelectionButton) {
        
        let valueChanged = selectedIndex != sender.index
        
        deselectAll()
        selectedIndex = sender.index
        sender.selected = true
        
        
        if valueChanged {
            sendActionsForControlEvents(UIControlEvents.ValueChanged)
        }
        
    }
    
    
}


class SelectionButton: UIControl {
    
    var titleLabel : UILabel
    var title : String?
    
    var index : Int
    
    var didSetupSubviews: Bool
    var didSetupConstraints: Bool
    
    var font : UIFont
    var borderColor : UIColor
    var selectedBorderColor : UIColor
    var textColor : UIColor
    var selectedTextColor : UIColor
    var buttonBackgroundColor : UIColor
    var selectedButtonBackgroundColor : UIColor
    
    
    convenience init (title : String, index: Int) {
        self.init(frame:CGRectZero)
        self.title = title
        self.index = index
    }
    
    override init(frame: CGRect) {
        
        // defaults
        font = Styles.FontFaces.light(12)
        textColor = Styles.Colors.stone
        selectedTextColor = Styles.Colors.stone
        borderColor = Styles.Colors.stone
        selectedBorderColor =  Styles.Colors.red2
        buttonBackgroundColor = UIColor.clearColor()
        selectedButtonBackgroundColor = Styles.Colors.red2
        
        titleLabel = UILabel()
        index = -1
        
        didSetupSubviews = false
        didSetupConstraints = true
        
        
        super.init(frame: frame)
    }
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    
    override func layoutSubviews() {
        
        if(!didSetupSubviews) {
            setupSubviews()
            didSetupConstraints = false
            self.setNeedsUpdateConstraints()
        }
        
        super.layoutSubviews()
    }
    
    override func updateConstraints() {
        
        if(!self.didSetupConstraints) {
            setupConstraints()
        }
        super.updateConstraints()
    }
    
    func setupSubviews() {
        
        backgroundColor = UIColor.clearColor()
        layer.borderWidth = 1
        layer.borderColor = borderColor.CGColor
        
        titleLabel.text = title
        titleLabel.font = font
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.textColor = textColor
        addSubview(titleLabel)
        
        didSetupSubviews = true
    }
    
    func setupConstraints() {
        
        self.titleLabel.snp_makeConstraints { (make) -> () in
            make.center.equalTo(self)
        }
        
        didSetupConstraints = true
    }
    
    
    
    override var selected: Bool {
        
        didSet {
            
            if(selected) {
                backgroundColor = selectedButtonBackgroundColor
                layer.borderColor = selectedBorderColor.CGColor
                titleLabel.textColor = selectedTextColor
            } else {
                backgroundColor = buttonBackgroundColor
                layer.borderColor = borderColor.CGColor
                titleLabel.textColor = textColor
            }
            
        }
    }
    
}