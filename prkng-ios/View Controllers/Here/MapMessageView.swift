//
//  MapMessageView.swift
//  
//
//  Created by Antonino Urbano on 2015-07-29.
//
//

import UIKit

class MapMessageView: UIView {
    
    var messageContainer: UIView
    private var mapMessageViewImage: UIImageView
    var mapMessageLabel: UILabel

    var availableCityPicker: UIView
    private var availableInLabel: UILabel
    private var montrealButton: UIButton
    private var quebecCityButton: UIButton

    var delegate : MapMessageViewDelegate?
    
    private var didsetupSubviews : Bool
    private var didSetupConstraints : Bool
    
    override init(frame: CGRect) {
        
        messageContainer = UIView()
        mapMessageViewImage = UIImageView(image: UIImage(named:"icon_exclamation"))
        mapMessageLabel = UILabel()
        
        availableCityPicker = UIView()
        availableInLabel = UILabel()
        montrealButton = ViewFactory.transparentRoundedButton()
        quebecCityButton = ViewFactory.transparentRoundedButton()
        
        didsetupSubviews = false
        didSetupConstraints = true
        
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        if (!didsetupSubviews) {
            setupSubviews()
            self.setNeedsUpdateConstraints()
        }
        
        super.layoutSubviews()
    }
    
    override func updateConstraints() {
        if(!didSetupConstraints) {
            setupConstraints()
        }
        
        super.updateConstraints()
    }
    
    func setupSubviews () {
        
        self.addSubview(messageContainer)
        
        messageContainer.backgroundColor = Styles.Colors.red2.colorWithAlphaComponent(0.8)
        messageContainer.addSubview(mapMessageViewImage)
        mapMessageLabel.textColor = Styles.Colors.cream1
        mapMessageLabel.font = Styles.Fonts.s2r
        mapMessageLabel.numberOfLines = 0
        mapMessageLabel.textAlignment = .Left
        messageContainer.addSubview(mapMessageLabel)
        
        availableCityPicker.backgroundColor = Styles.Colors.stone.colorWithAlphaComponent(0.8)
        self.addSubview(availableCityPicker)
        
        availableInLabel.text = "available_in".localizedString
        availableInLabel.textColor = Styles.Colors.petrol2
        availableInLabel.font = Styles.Fonts.s3r
        availableCityPicker.addSubview(availableInLabel)

        montrealButton.setTitleColor(Styles.Colors.petrol2, forState: UIControlState.Normal)
        montrealButton.layer.borderColor = Styles.Colors.petrol2.CGColor
        montrealButton.layer.cornerRadius = 10
        montrealButton.setTitle("Montréal", forState: .Normal)
        montrealButton.addTarget(self, action: "montrealButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        availableCityPicker.addSubview(montrealButton)
        
        quebecCityButton.setTitleColor(Styles.Colors.petrol2, forState: UIControlState.Normal)
        quebecCityButton.layer.borderColor = Styles.Colors.petrol2.CGColor
        quebecCityButton.layer.cornerRadius = 10
        quebecCityButton.setTitle("Québec", forState: .Normal)
        quebecCityButton.addTarget(self, action: "quebecCityButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
        availableCityPicker.addSubview(quebecCityButton)

        didsetupSubviews = true
        didSetupConstraints = false
    }
    
    func setupConstraints () {
        
        messageContainer.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.top.equalTo(self)
        }
        
        mapMessageViewImage.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.messageContainer).offset(34)
            make.centerY.equalTo(self.messageContainer).offset(Styles.Sizes.statusBarHeight/2)
            make.bottom.lessThanOrEqualTo(self.messageContainer).offset(-15)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        mapMessageLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.mapMessageViewImage.snp_right).offset(16).priorityRequired()
            make.right.equalTo(self.messageContainer).offset(-20).priorityRequired()
            make.centerY.equalTo(self.messageContainer).offset(Styles.Sizes.statusBarHeight/2).priorityRequired()
            make.bottom.greaterThanOrEqualTo(self.messageContainer).offset(-15).priorityRequired()
        }
        
        hideCityPicker()
        
        availableInLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.availableCityPicker).offset(34)
            make.centerY.equalTo(self.availableCityPicker)
        }
        
        montrealButton.snp_makeConstraints { (make) -> () in
            make.right.equalTo(self.quebecCityButton.snp_left).offset(-15)
            make.centerY.equalTo(self.availableCityPicker)
            make.size.equalTo(CGSizeMake(75, 20))
        }

        quebecCityButton.snp_makeConstraints { (make) -> () in
            make.right.equalTo(self.availableCityPicker).offset(-34)
            make.centerY.equalTo(self.availableCityPicker)
            make.size.equalTo(CGSizeMake(75, 20))
        }
        
    }
    
    func showCityPicker() {
        
        availableCityPicker.hidden = false

        availableCityPicker.snp_remakeConstraints { (make) -> () in
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.top.equalTo(self.messageContainer.snp_bottom)
            make.height.equalTo(50)
            make.bottom.equalTo(self)
        }
    }
    
    func hideCityPicker() {
        
        availableCityPicker.hidden = true
        
        availableCityPicker.snp_remakeConstraints { (make) -> () in
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.top.equalTo(self.messageContainer.snp_bottom)
            make.height.equalTo(0)
            make.bottom.equalTo(self)

        }

    }
    
    func montrealButtonTapped() {
        self.delegate?.cityDidChange(fromCity: Settings.City.Montreal, toCity: Settings.City.Montreal)
    }
    
    func quebecCityButtonTapped() {
        self.delegate?.cityDidChange(fromCity: Settings.City.QuebecCity, toCity: Settings.City.QuebecCity)
    }
    
    func height() -> CGFloat {
        
//        let attrs = [NSFontAttributeName: indicatorButton.titleLabel!.font]
//        let maximumLabelSize = CGSize(width: rightViewWidth - locationButtonWidth - 10, height: 20)
//        let rect = (indicatorText as NSString).boundingRectWithSize(maximumLabelSize, options: NSStringDrawingOptions.allZeros, attributes: attrs, context: nil)
//
//        return Styles.Sizes.statusBarHeight +

        return 0
    }
        
}

protocol MapMessageViewDelegate {
    func cityDidChange(fromCity fromCity: Settings.City, toCity: Settings.City)
}