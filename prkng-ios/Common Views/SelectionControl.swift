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
    var buttons : Array<SelectionButton>
    
    convenience init(titles : Array<String>) {
        self.init(frame:CGRectZero)
        self.titles = titles
    }
    
    override init(frame: CGRect) {
        titles = []
        buttons = []
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
        
        for title in titles {
            buttons.append(SelectionButton())
        }
        
        
        didSetupSubviews = true
    }
    
    func setupConstraints() {
        
        if(buttons.count == 1) {
            
            buttons[0].snp_makeConstraints({ (make) -> () in
                make.center.equalTo(self)
            })
            
        } else if (buttons.count > 1) {
            
            
            
            
            
        }
        
        
        
        // TODO
        didSetupConstraints = true
    }
    
    
}


class SelectionButton: UIControl {
    
    var titleLabel : UILabel
    var title : String?
    
    
    var didSetupSubviews: Bool
    var didSetupConstraints: Bool
    
    
    override init(frame: CGRect) {
        
        titleLabel = UILabel()
        
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