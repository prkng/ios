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
    var selectionIndicator : UIView
    
    var selectedIndex : Int
    
    var buttonSize : CGSize
    var selectionIndicatorSize : CGSize
    var borderColor : UIColor?
    var selectedBorderColor : UIColor?
    var textColor : UIColor?
    var selectedTextColor : UIColor?
    var buttonBackgroundColor : UIColor?
    var selectedButtonBackgroundColor : UIColor?
    var font : UIFont = Styles.FontFaces.regular(12)
    var fixedWidth : Int = 0
    
    convenience init(titles : Array<String>) {
        self.init(frame:CGRect.zero)
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
        buttonSize = CGSize(width: 110, height: 26) // Default
        selectionIndicatorSize = CGSize(width: 5, height: 5)
        selectedIndex = 0
        selectionIndicator = UIView()
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    
    override func layoutSubviews() {
        
        if(!didSetupSubviews) {
            setupSubviews()
            didSetupConstraints = false
            self.setNeedsUpdateConstraints()
        }
        
        selectOption(self.buttons[selectedIndex], animated: true)
        
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
        
        selectionIndicator.backgroundColor = self.selectedTextColor ?? Styles.Colors.red2
        selectionIndicator.layer.cornerRadius =  self.selectionIndicatorSize.height / 2.0
        addSubview(selectionIndicator)
        
        for _ in titles {
            
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
                button.selectedButtonBackgroundColor = UIColor.clear //selectedButtonBackgroundColor!
            }
            
            button.font = font
            
            button.layer.cornerRadius =  self.buttonSize.height / 2.0
            button.addTarget(self, action: #selector(SelectionControl.selectOption(_:)), for: UIControlEvents.touchUpInside)
            button.isSelected = (selectedIndex == index)
            buttonContainer.addSubview(button)
            
            index += 1
        }
        
        didSetupSubviews = true
    }
    
    func setupConstraints() {
        
        if(buttons.count == 1) {
            
            buttons[0].snp_makeConstraints(closure: { (make) -> () in
                make.center.equalTo(self)
                make.size.equalTo(self.buttonSize)
            })
            
        } else if (buttons.count > 1) {
            
            if fixedWidth > 0 {
                
                var rightConstraint = self.snp_left
                
                for index in 0...buttons.count-1 {
                    
                    buttonContainers[index].snp_makeConstraints(closure: { (make) -> () in
                        make.left.equalTo(rightConstraint).offset(self.fixedWidth)
                        make.top.equalTo(self)
                        make.bottom.equalTo(self)
                    })
                    
                    buttons[index].snp_makeConstraints(closure: { (make) -> () in
                        make.edges.equalTo(self.buttonContainers[index])
                        
                    })

                    rightConstraint = buttons[index].snp_right
                    
                }
            } else {
                
                for index in 0...buttons.count-1 {
                    
                    let multiplier : Float = 2.0 * Float(index + 1) / (Float(buttons.count + 1) )  // MAGIC =)
                    NSLog("multiplier : %f", multiplier)
                    
                    buttonContainers[index].snp_makeConstraints(closure: { (make) -> () in
                        make.width.equalTo(self).multipliedBy(1.0 / Float(self.buttons.count))
                        make.height.equalTo(self)
                        make.centerX.equalTo(self).multipliedBy(multiplier)
                        make.top.equalTo(self)
                        make.bottom.equalTo(self)
                    })
                    
                    
                    buttons[index].snp_makeConstraints(closure: { (make) -> () in
                        make.center.equalTo(self.buttonContainers[index])
                        make.size.equalTo(self.buttonSize)
                        
                    })
                }
            }
            
            
            
            
            
            
        }
        
        selectionIndicator.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.buttons[self.selectedIndex])
            make.centerY.equalTo(self.buttons[self.selectedIndex]).offset(12)
            make.size.equalTo(self.selectionIndicatorSize)
        }
        
        didSetupConstraints = true
    }
    
    //only works for fixed width...
    func calculatedWidth() -> CGFloat {
        var width: CGFloat = 0
        for title in titles {
            width += CGFloat(fixedWidth)
            
            let attrs = [NSFontAttributeName: font]
            let maximumLabelSize = CGSize(width: 310, height: 9999);
            let rect = (title as NSString).boundingRect(with: maximumLabelSize, options: NSStringDrawingOptions(), attributes: attrs , context: nil)
            
            width += rect.width
            
        }
        return width
    }
    
    fileprivate func deselectAll () {
        
        for button in buttons {
            button.isSelected = false
        }
        
    }
    
    func selectOption (_ sender : SelectionButton) {
        selectOption(sender, animated: true)
    }
    
    
    func selectOption (_ sender : SelectionButton, animated: Bool) {
        
        let valueChanged = selectedIndex != sender.index
        
        if valueChanged {
            
            selectedIndex = sender.index
            deselectAll()
            
            selectionIndicator.snp_remakeConstraints { (make) -> () in
                make.centerX.equalTo(self.buttons[self.selectedIndex])
                make.centerY.equalTo(self.buttons[self.selectedIndex]).offset(12)
                make.size.equalTo(self.selectionIndicatorSize)
            }
            
            if (animated) {
                UIView.animate(withDuration: 0.15, animations: { () -> Void in
                    self.selectionIndicator.layoutIfNeeded()
                    }, completion: { (completed) -> Void in
                        sender.isSelected = true
                        self.sendActions(for: UIControlEvents.valueChanged)
                })
            } else {
                self.selectionIndicator.layoutIfNeeded()
                deselectAll()
                sender.isSelected = true
                self.sendActions(for: UIControlEvents.valueChanged)
            }
            
            
        }  else if !animated {
            deselectAll()
            sender.isSelected = true
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
        self.init(frame:CGRect.zero)
        self.title = title
        self.index = index
    }
    
    override init(frame: CGRect) {
        
        // defaults
        font = Styles.FontFaces.regular(12)
        textColor = Styles.Colors.anthracite1
        selectedTextColor = Styles.Colors.red2
        borderColor = UIColor.clear
        selectedBorderColor =  UIColor.clear
        buttonBackgroundColor = UIColor.clear
        selectedButtonBackgroundColor = UIColor.clear
        
        titleLabel = UILabel()
        index = -1
        
        didSetupSubviews = false
        didSetupConstraints = true
        
        
        super.init(frame: frame)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
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
        
        backgroundColor = UIColor.clear
        layer.borderWidth = 1
        layer.borderColor = borderColor.cgColor
        
        titleLabel.text = title
        titleLabel.font = font
        titleLabel.textAlignment = NSTextAlignment.center
        titleLabel.textColor = textColor
        addSubview(titleLabel)
        
        didSetupSubviews = true
    }
    
    func setupConstraints() {
        
        self.titleLabel.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self)
        }
        
        didSetupConstraints = true
    }
    
    
    
    override var isSelected: Bool {
        
        didSet {
            
            if(isSelected) {
                backgroundColor = selectedButtonBackgroundColor
                layer.borderColor = selectedBorderColor.cgColor
                titleLabel.textColor = selectedTextColor
            } else {
                backgroundColor = buttonBackgroundColor
                layer.borderColor = borderColor.cgColor
                titleLabel.textColor = textColor
            }
            
        }
    }
    
}
