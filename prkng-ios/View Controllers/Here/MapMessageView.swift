//
//  MapMessageView.swift
//  
//
//  Created by Antonino Urbano on 2015-07-29.
//
//

import UIKit

class MapMessageView: UIView {
    
    private var messageContainer: UIView
    private var mapMessageViewImage: UIImageView
    var mapMessageLabel: UILabel

    private var availableCityPicker: UIView
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
    
    required init(coder aDecoder: NSCoder) {
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
            make.height.greaterThanOrEqualTo(70)
        }
        
        mapMessageViewImage.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.messageContainer).with.offset(34)
            make.centerY.equalTo(self.messageContainer).with.offset(Styles.Sizes.statusBarHeight/2)
            make.bottom.lessThanOrEqualTo(self.messageContainer).with.offset(-15)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        mapMessageLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.mapMessageViewImage.snp_right).with.offset(16)
            make.right.equalTo(self.messageContainer).with.offset(-20)
            make.centerY.equalTo(self.messageContainer).with.offset(Styles.Sizes.statusBarHeight/2)
            make.bottom.lessThanOrEqualTo(self.messageContainer).with.offset(-15)
        }
        
        hideCityPicker()
        
        availableInLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.availableCityPicker).with.offset(34)
            make.centerY.equalTo(self.availableCityPicker)
        }
        
        montrealButton.snp_makeConstraints { (make) -> () in
            make.right.equalTo(self.quebecCityButton.snp_left).with.offset(-15)
            make.centerY.equalTo(self.availableCityPicker)
            make.size.equalTo(CGSizeMake(75, 20))
        }

        quebecCityButton.snp_makeConstraints { (make) -> () in
            make.right.equalTo(self.availableCityPicker).with.offset(-34)
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
        }
    }
    
    func hideCityPicker() {
        
        availableCityPicker.hidden = true
        
        availableCityPicker.snp_remakeConstraints { (make) -> () in
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.top.equalTo(self.messageContainer.snp_bottom)
            make.height.equalTo(0)
        }

    }
    
    func montrealButtonTapped() {
        self.delegate?.cityDidChange(fromCity: Settings.City.Montreal, toCity: Settings.City.Montreal)
    }
    
    func quebecCityButtonTapped() {
        self.delegate?.cityDidChange(fromCity: Settings.City.QuebecCity, toCity: Settings.City.QuebecCity)
    }
        
}

protocol MapMessageViewDelegate {
    func cityDidChange(#fromCity: Settings.City, toCity: Settings.City)
}