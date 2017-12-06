//
//  PPCreditCardCell.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2016-01-28.
//  Copyright © 2016 PRKNG. All rights reserved.
//

import Foundation

class PPCreditCardCell: UITableViewCell {
    
    static let LEFT_IMAGE_OFFSET = 25
    static let IMAGE_TO_TEXT_OFFSET = 10
    
    fileprivate var creditCardType: CardIOCreditCardType
    fileprivate var creditCardTypeImageView = UIImageView()
    fileprivate var creditCardLabel = UILabel()
    
    fileprivate var didSetupSubviews: Bool = false
    fileprivate var didSetupConstraints: Bool = false
    
    var creditCardNumber: String {
        didSet {
            let locale = Locale.current.identifier
            let cardTypeText = CardIOCreditCardInfo.displayString(for: creditCardType, usingLanguageOrLocale: locale)

            var labelText = cardTypeText ?? ""

            if creditCardNumber.length() >= 4 {
                let lastFourDigits = " **** " + creditCardNumber.substring(from: creditCardNumber.characters.index(creditCardNumber.endIndex, offsetBy: -4))
                labelText += lastFourDigits
            }
            
            creditCardLabel.text = labelText

        }
    }
    
    init(creditCardType: CardIOCreditCardType, isDefault: Bool, reuseIdentifier: String?) {
        self.creditCardType = creditCardType
        self.creditCardNumber = ""
        
        if let creditCardTypeImage = CardIOCreditCardInfo.logo(for: creditCardType) {
            creditCardTypeImageView.image = creditCardTypeImage
        }
        
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        //enable this once we have an appropriate edit card screen
        if isDefault {
            let defaultCCImage = UIImage(named: "icon_checkmark_small_red")
            self.accessoryView = UIImageView(image: defaultCCImage)
        }
        
        setupViews()
        self.setNeedsUpdateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        if !didSetupConstraints {
            setupConstraints()
        }
        super.updateConstraints()
    }

    func setupViews() {
        
        self.contentView.addSubview(creditCardTypeImageView)
        
        creditCardLabel.textColor = Styles.Colors.petrol2
        creditCardLabel.font = Styles.FontFaces.regular(14)
        self.contentView.addSubview(creditCardLabel)
        
        didSetupSubviews = true
    }
    
    func setupConstraints() {
        
        creditCardTypeImageView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.contentView).offset(PPCreditCardCell.LEFT_IMAGE_OFFSET)
            make.centerY.equalTo(self.contentView)
            make.size.equalTo(CGSize(width: 36, height: 25)) //this is the default size of CardIO's CardIOCreditCardInfo.logoForCardType(cardType: CardIOCreditCardType) method
        }
        
        creditCardLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(creditCardTypeImageView.snp_right).offset(PPCreditCardCell.IMAGE_TO_TEXT_OFFSET)
            make.centerY.equalTo(self.contentView)
        }
        
        didSetupConstraints = true
    }
    
    
}
