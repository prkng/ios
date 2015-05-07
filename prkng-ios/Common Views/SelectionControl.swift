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
    
    convenience init(titles : Array<String>) {
        self.init(frame:CGRectZero)
        self.titles = titles
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
        
        super.layoutSubviews()
    }
    
    override func updateConstraints() {
        
        if(!self.didSetupConstraints) {
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
            
            let button = SelectionButton(title:title, index : index)
            button.layer.cornerRadius =  self.buttonSize.height / 2.0
            button.addTarget(self, action: "selectOption:", forControlEvents: UIControlEvents.TouchUpInside)
            buttonContainer.addSubview(button)
            buttons.append(button)
            
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
        
        deselectAll()
        selectedIndex = sender.index
        sender.selected = true
        
    }
    
    
}


class SelectionButton: UIControl {
    
    var titleLabel : UILabel
    var title : String?
    
    var index : Int
    
    var didSetupSubviews: Bool
    var didSetupConstraints: Bool
    
    
    convenience init (title : String, index: Int) {
        self.init(frame:CGRectZero)
        self.title = title
    }
    
    override init(frame: CGRect) {
        
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
        layer.borderColor = Styles.Colors.stone.CGColor
        
        titleLabel.text = title
        titleLabel.font = Styles.FontFaces.light(12)
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.textColor = Styles.Colors.stone
        selected = false
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
                backgroundColor = Styles.Colors.red2
                layer.borderColor = Styles.Colors.red2.CGColor
            } else {
                backgroundColor = UIColor.clearColor()
                layer.borderColor = Styles.Colors.stone.CGColor
            }
            
        }
    }
    
}