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
    
    var backgroundView: UIView
    var buttonContainers: Array<UIView>
    var buttons: Array<SliderSelectionButton>
    private var frontButtonContainers: Array<UIView>
    private var frontButtons: Array<SliderSelectionButton>
    var selectionIndicator: UISlider
    
    var selectedIndex: Int
    
    var borderColor: UIColor?
    var selectedBorderColor: UIColor?
    var textColor: UIColor = Styles.Colors.petrol2
    var selectedTextColor: UIColor = Styles.Colors.cream1
    var buttonBackgroundColor: UIColor = Styles.Colors.cream1 //only applies if < ios 8, otherwise we blur
    var selectedButtonBackgroundColor: UIColor = Styles.Colors.red2
    var selectionIndicatorColor: UIColor = Styles.Colors.red2
    var font: UIFont = Styles.FontFaces.regular(14)
    
    var thumbImage: UIImage { get {
        let rect = CGRect(x: 0, y: 0, width: self.width, height: SliderSelectionControl.HEIGHT)
        let image = UIImage.imageWithColor(UIColor.clearColor(), size: rect.size)
        return image
        }
    }
    
    static let HEIGHT: CGFloat = 60
    var width: CGFloat
    var lastThumbPixelValue: CGFloat = 0

    convenience init(titles: Array<String>) {
        self.init(frame:CGRectZero)
        self.titles = titles
        
        self.width = UIScreen.mainScreen().bounds.width/CGFloat(self.titles.count)
        
        if Settings.iOS8OrLater() {
            buttonBackgroundColor = UIColor.clearColor()
            selectedButtonBackgroundColor = UIColor.clearColor()
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
            backgroundView = UIVisualEffectView(effect: blurEffect)
//            backgroundView.backgroundColor = Styles.Colors.cream1
//            backgroundView.alpha = 0.9
        } else {
            backgroundView.backgroundColor = buttonBackgroundColor
        }

        var i: Int = 0
        for title in titles {
            buttons.append(SliderSelectionButton(title:title, index: i++))
        }

        i = 0
        for title in titles {
            frontButtons.append(SliderSelectionButton(title:title, index: i++))
        }

    }
    
    override init(frame: CGRect) {
        titles = []
        frontButtons = []
        buttons = []
        frontButtonContainers = []
        buttonContainers = []
        didSetupSubviews = false
        didSetupConstraints = true
        selectedIndex = 1
        selectionIndicator = UISlider()
        backgroundView = UIView()
        width = 0
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
        
        selectOption(self.buttons[selectedIndex], animated: true, forceRedraw: true)
        
        super.layoutSubviews()
    }
    
    override func updateConstraints() {
        
        if(!didSetupConstraints) {
            setupConstraints()
        }
        super.updateConstraints()
    }
    
    func setupSubviews() {
        
        self.addSubview(backgroundView)

        var index: Int = 0
        
        for title in titles {
            
            let buttonContainer = UIView()
            buttonContainer.userInteractionEnabled = false
            backgroundView.addSubview(buttonContainer)
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
            
            button.addTarget(self, action: "selectOption:", forControlEvents: UIControlEvents.TouchUpInside)
            button.selected = (selectedIndex == index)
            buttonContainer.addSubview(button)
            
            index++
        }
        
        selectionIndicator.continuous = true
        selectionIndicator.setThumbImage(thumbImage, forState: UIControlState.Normal)
        selectionIndicator.minimumValue = 0
        selectionIndicator.maximumValue = Float(titles.count-1)
        selectionIndicator.minimumTrackTintColor = UIColor.clearColor()
        selectionIndicator.maximumTrackTintColor = UIColor.clearColor()
        
        selectionIndicator.addTarget(self, action: "sliderSelectionValueChanged", forControlEvents: UIControlEvents.TouchUpInside)
        selectionIndicator.addTarget(self, action: "sliderSelectionValueChanging", forControlEvents: UIControlEvents.AllEvents)
        backgroundView.addSubview(selectionIndicator)
        
        let tapRec = UITapGestureRecognizer(target: self, action: "sliderSelectionTapped:")
        tapRec.delegate = self
        selectionIndicator.addGestureRecognizer(tapRec)
        
        
        index = 0
        
        for title in titles {
            
            let frontButtonContainer = UIView()
            frontButtonContainer.userInteractionEnabled = false
            backgroundView.addSubview(frontButtonContainer)
            frontButtonContainers.append(frontButtonContainer)
            
            let frontButton = frontButtons[index]
            
            frontButton.userInteractionEnabled = false
            
            if borderColor != nil {
                frontButton.borderColor = borderColor!
            }
            
            if selectedBorderColor != nil {
                frontButton.selectedBorderColor = selectedBorderColor!
            }
            
            frontButton.textColor = UIColor.clearColor()//textColor
            
            frontButton.selectedTextColor = selectedTextColor
            
            frontButton.buttonBackgroundColor = UIColor.clearColor()
            
            frontButton.selectedButtonBackgroundColor = selectedButtonBackgroundColor
            
            frontButton.font = font
            
            frontButton.addTarget(self, action: "selectOption:", forControlEvents: UIControlEvents.TouchUpInside)
            frontButton.selected = (selectedIndex == index)
            frontButtonContainer.addSubview(frontButton)
            
            index++
        }
        
        didSetupSubviews = true
    }
    
    func setupConstraints() {
        
        if(buttons.count == 1) {
            
            buttons[0].snp_makeConstraints({ (make) -> () in
                make.center.equalTo(self)
                make.height.equalTo(SliderSelectionControl.HEIGHT)
                make.width.equalTo(self)
            })
            
        } else if (buttons.count > 1) {
            
            var leftViewConstraint = self.snp_left
            
            for index in 0...buttons.count-1 {
                
                buttonContainers[index].snp_makeConstraints({ (make) -> () in
                    make.width.equalTo(self.width)
                    make.height.equalTo(SliderSelectionControl.HEIGHT)
                    make.left.equalTo(leftViewConstraint)
                    make.top.equalTo(self)
                })
                
                buttons[index].snp_makeConstraints({ (make) -> () in
                    make.edges.equalTo(buttonContainers[index])
                })
                
                leftViewConstraint = buttonContainers[index].snp_right
                
            }
        }
        
        if(frontButtons.count == 1) {
            
            frontButtons[0].snp_makeConstraints({ (make) -> () in
                make.center.equalTo(self)
                make.height.equalTo(SliderSelectionControl.HEIGHT)
                make.width.equalTo(self)
            })
            
        } else if (frontButtons.count > 1) {
            
            var leftViewConstraint = self.snp_left
            
            for index in 0...frontButtons.count-1 {
                
                frontButtonContainers[index].snp_makeConstraints({ (make) -> () in
                    make.width.equalTo(self.width)
                    make.height.equalTo(SliderSelectionControl.HEIGHT)
                    make.left.equalTo(leftViewConstraint)
                    make.top.equalTo(self)
                })
                
                frontButtons[index].snp_makeConstraints({ (make) -> () in
                    make.edges.equalTo(frontButtonContainers[index])
                })
                
                leftViewConstraint = frontButtonContainers[index].snp_right
                
            }
        }
        
        selectionIndicator.snp_makeConstraints { (make) -> () in
            make.height.equalTo(SliderSelectionControl.HEIGHT)
            make.left.equalTo(self.snp_left)
            make.right.equalTo(self.snp_right)
            make.centerY.equalTo(self)
        }
        
        backgroundView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self)
        }
        
        didSetupConstraints = true
    }
    
    private func deselectAll () {
        
        for button in buttons {
            button.selected = false
        }
        
        for button in frontButtons {
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
    
    func sliderSelectionValueChanging() {
        
        let newValue = self.selectionIndicator.value
        
        let bounds = self.selectionIndicator.bounds
        let trackRect = selectionIndicator.trackRectForBounds(bounds)
        let thumbRect = selectionIndicator.thumbRectForBounds(bounds, trackRect: trackRect, value: newValue)

        let xDifference = (bounds.width - trackRect.size.width) / 2
        let yDifference = CGFloat(-0.5)//(bounds.height - CGFloat(SliderSelectionControl.HEIGHT)) / 2

        var fullThumbImage = UIImage.imageWithColor(selectionIndicatorColor, size: CGSize(width: bounds.size.width, height: CGFloat(SliderSelectionControl.HEIGHT)))

        let thumbDrawRect = CGRect(x: thumbRect.origin.x, y: 1, width: CGFloat(self.width), height: CGFloat(SliderSelectionControl.HEIGHT))

        //draw the 3 titles in the image
        for i in 0..<titles.count {
            let title = titles[i]
            let attributedTitle = NSMutableAttributedString(string: title, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: selectedTextColor])
            let labelRect = CGRect(x: xDifference + (CGFloat(i)*CGFloat(self.width)), y: yDifference, width: CGFloat(self.width), height: CGFloat(SliderSelectionControl.HEIGHT))
            fullThumbImage = fullThumbImage.addText(attributedTitle, labelRect: labelRect)
        }
        
        let modifiedThumbImage = fullThumbImage.redrawImageInRect(thumbDrawRect)
        selectionIndicator.setThumbImage(modifiedThumbImage, forState: UIControlState.Normal)
        
    }
    
    func sliderSelectionValueChanged() {
        sliderSelectionValueChanged(self.selectionIndicator.value)
    }
    
    func sliderSelectionValueChanged(newValue: Float) {
        
        if newValue < 0.5 {
            selectOption(buttons[0])
        } else if newValue < 1.5 {
            selectOption(buttons[1])
        } else {
            selectOption(buttons[2])
        }

    }
    
    func selectOption (sender: SliderSelectionButton) {
        selectOption(sender, animated: true, forceRedraw: false)
    }
    
    
    func selectOption (sender: SliderSelectionButton, animated: Bool, forceRedraw: Bool) {
        
        let frontButton = frontButtons[sender.index]
        
        UIView.animateWithDuration(0.15, animations: { () -> Void in
            
            self.selectionIndicator.setValue(Float(sender.index), animated: false)
            if forceRedraw {
                self.sliderSelectionValueChanging()
            }
            
            }, completion: { (completed) -> Void in
                
                self.deselectAll()
                sender.selected = true
                frontButton.selected = true
                
                let valueChanged = self.selectedIndex != sender.index
                
                if valueChanged {
                    self.selectedIndex = sender.index
                    self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
                }

        })
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
//                backgroundColor = selectedButtonBackgroundColor
//                layer.borderColor = selectedBorderColor.CGColor
//                titleLabel.textColor = selectedTextColor
            } else {
                backgroundColor = buttonBackgroundColor
                layer.borderColor = borderColor.CGColor
                titleLabel.textColor = textColor
            }
            
        }
    }
    
}