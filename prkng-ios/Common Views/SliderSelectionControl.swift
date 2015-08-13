//
//  SliderSelectionControl.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 12/08/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class SliderSelectionControl: UIControl, UIGestureRecognizerDelegate {
    
    var didSetupSubviews: Bool
    var didSetupConstraints: Bool
    
    var titles: Array<String>
    
    var buttonContainers: Array<UIView>
    var buttons: Array<SliderSelectionButton>
    var selectionIndicator: UISlider
    
    var selectedIndex: Int
    
    var buttonSize: CGSize
    var selectionIndicatorSize: CGSize
    var borderColor: UIColor?
    var selectedBorderColor: UIColor?
    var textColor: UIColor = Styles.Colors.cream1
    var selectedTextColor: UIColor = Styles.Colors.cream2
    var buttonBackgroundColor: UIColor = Styles.Colors.midnight2
    var selectedButtonBackgroundColor: UIColor = Styles.Colors.midnight1
    var selectionIndicatorColor: UIColor = Styles.Colors.midnight1
    var font: UIFont = Styles.FontFaces.regular(12)
    var fixedWidth: Int = 0
    
    var thumbImage: UIImage {
        let rect = CGRect(x: 0, y: 0, width: 30, height: 30)
        let image = UIImage.imageWithColor(selectionIndicatorColor, size: rect.size)
        let roundedImage = UIImage.getRoundedRectImageFromImage(image, rect: rect, cornerRadius: 15)
        return roundedImage
    }
    
    convenience init(titles: Array<String>) {
        self.init(frame:CGRectZero)
        self.titles = titles
        
        var i: Int = 0
        for title in titles {
            buttons.append(SliderSelectionButton(title:title, index: i++))
        }
        
    }
    
    override init(frame: CGRect) {
        titles = []
        buttons = []
        buttonContainers = []
        didSetupSubviews = false
        didSetupConstraints = true
        buttonSize = CGSizeMake(30, 30) // Default
        selectionIndicatorSize = CGSizeMake(30, 30)
        selectedIndex = 1
        selectionIndicator = UISlider()
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
        
        var index: Int = 0
        
        selectionIndicator.continuous = false
        selectionIndicator.setThumbImage(self.thumbImage, forState: UIControlState.Normal)
        selectionIndicator.minimumValue = 0
        selectionIndicator.maximumValue = Float(titles.count-1)
        selectionIndicator.minimumTrackTintColor = Styles.Colors.midnight2
        selectionIndicator.maximumTrackTintColor = Styles.Colors.midnight2

        selectionIndicator.addTarget(self, action: "sliderSelectionValueChanged", forControlEvents: UIControlEvents.ValueChanged)
        addSubview(selectionIndicator)
        
        let tapRec = UITapGestureRecognizer(target: self, action: "sliderSelectionTapped:")
        tapRec.delegate = self
        selectionIndicator.addGestureRecognizer(tapRec)
        
        for title in titles {
            
            let buttonContainer = UIView()
            buttonContainer.userInteractionEnabled = false
            addSubview(buttonContainer)
            buttonContainers.append(buttonContainer)
            
            let button = buttons[index]
            
            button.userInteractionEnabled = false

            if borderColor != nil {
                button.borderColor = borderColor!
            }
            
            if selectedBorderColor != nil {
                button.selectedBorderColor = selectedBorderColor!
            }
            
            button.textColor = textColor
            
            button.selectedTextColor = selectedTextColor
            
            button.buttonBackgroundColor = buttonBackgroundColor
            
            button.selectedButtonBackgroundColor = selectedButtonBackgroundColor
            
            button.font = font
            
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
            
            if fixedWidth > 0 {
                
                var rightConstraint = self.snp_left
                
                for index in 0...buttons.count-1 {
                    
                    buttonContainers[index].snp_makeConstraints({ (make) -> () in
                        make.left.equalTo(rightConstraint).with.offset(self.fixedWidth)
                        make.top.equalTo(self)
                        make.bottom.equalTo(self)
                    })
                    
                    buttons[index].snp_makeConstraints({ (make) -> () in
                        make.edges.equalTo(self.buttonContainers[index])
                        
                    })

                    rightConstraint = buttons[index].snp_right
                    
                }
            } else {
                
                for index in 0...buttons.count-1 {
                    
                    let multiplier: Float = 2.0 * Float(index + 1) / (Float(buttons.count + 1) )  // MAGIC =)
                    NSLog("multiplier: %f", multiplier)
                    
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
            
            
            
            
            
            
        }
        
        let leftMultiplier: Float = 2.0 * Float(0 + 1) / (Float(buttons.count + 1) )  // MAGIC =)
        let rightMultiplier: Float = 2.0 * Float(2 + 1) / (Float(buttons.count + 1) )  // MAGIC =)

        selectionIndicator.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.snp_centerX).multipliedBy(leftMultiplier).with.offset(-13)
            make.right.equalTo(self.snp_centerX).multipliedBy(rightMultiplier).with.offset(13)
            make.centerY.equalTo(self)
        }
        
        didSetupConstraints = true
    }
    
    //only works for fixed width...
    func calculatedWidth() -> CGFloat {
        var width: CGFloat = 0
        for title in titles {
            width += CGFloat(fixedWidth)
            
            let attrs = [NSFontAttributeName: font]
            let maximumLabelSize = CGSizeMake(310, 9999);
            let rect = (title as NSString).boundingRectWithSize(maximumLabelSize, options: NSStringDrawingOptions.allZeros, attributes: attrs , context: nil)
            
            width += rect.width
            
        }
        return width
    }
    
    private func deselectAll () {
        
        for button in buttons {
            button.selected = false
        }
        
    }
    
    func sliderSelectionTapped(tapRec: UITapGestureRecognizer) {
        if tapRec.state == UIGestureRecognizerState.Ended {
            let tap = tapRec.locationInView(self.selectionIndicator)
            let newValue = (tap.x / self.selectionIndicator.bounds.width) * CGFloat(self.titles.count - 1)
//            self.selectionIndicator.setValue(Float(newValue), animated: true)
            sliderSelectionValueChanged(Float(newValue))
        }
    }
    
    func sliderSelectionValueChanged() {
        sliderSelectionValueChanged(self.selectionIndicator.value)
    }
    
    func sliderSelectionValueChanged(newValue: Float) {
        
        if newValue < 0.5 {
            selectOption(buttons[0])
//            self.selectionIndicator.setValue(0, animated: true)
        } else if newValue < 1.5 {
            selectOption(buttons[1])
//            self.selectionIndicator.setValue(1, animated: true)
        } else {
            selectOption(buttons[2])
//            self.selectionIndicator.setValue(2, animated: true)
        }

    }
    
    func selectOption (sender: SliderSelectionButton) {
        selectOption(sender, animated: true)
    }
    
    
    func selectOption (sender: SliderSelectionButton, animated: Bool) {
        
        selectionIndicator.setValue(Float(sender.index), animated: animated)

        let valueChanged = selectedIndex != sender.index
        
        if valueChanged {
            
            selectedIndex = sender.index
            deselectAll()
            
//            selectionIndicator.snp_remakeConstraints { (make) -> () in
//                make.centerX.equalTo(self.buttons[self.selectedIndex])
//                make.centerY.equalTo(self.buttons[self.selectedIndex])//.with.offset(12)
//                make.size.equalTo(self.selectionIndicatorSize)
//            }
            
            if (animated) {
                UIView.animateWithDuration(0.15, animations: { () -> Void in
                    self.selectionIndicator.layoutIfNeeded()
                    }, completion: { (completed) -> Void in
                        sender.selected = true
                        self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
                })
            } else {
                self.selectionIndicator.layoutIfNeeded()
                deselectAll()
                sender.selected = true
                self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
            }
            
            
        }  else if !animated {
            deselectAll()
            sender.selected = true
        }
        
    }
    
    
}


class SliderSelectionButton: UIControl {
    
    var titleLabel: UILabel
    var title: String?
    
    var index: Int
    
    var didSetupSubviews: Bool
    var didSetupConstraints: Bool
    
    var font: UIFont
    var borderColor: UIColor
    var selectedBorderColor: UIColor
    var textColor: UIColor
    var selectedTextColor: UIColor
    var buttonBackgroundColor: UIColor
    var selectedButtonBackgroundColor: UIColor
    
    
    convenience init (title: String, index: Int) {
        self.init(frame:CGRectZero)
        self.title = title
        self.index = index
    }
    
    override init(frame: CGRect) {
        
        // defaults
        font = Styles.FontFaces.regular(12)
        textColor = Styles.Colors.anthracite1
        selectedTextColor = Styles.Colors.red2
        borderColor = UIColor.clearColor()
        selectedBorderColor =  UIColor.clearColor()
        buttonBackgroundColor = UIColor.clearColor()
        selectedButtonBackgroundColor = UIColor.clearColor()
        
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
            make.edges.equalTo(self)
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