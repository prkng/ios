//
//  PPAddCreditCardCell.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2016-01-28.
//  Copyright © 2016 PRKNG. All rights reserved.
//

import Foundation

class PPAddCreditCardCell: UITableViewCell {
    
    private var addCreditCardImageView = UIImageView()
    private var centeredLabel = UILabel()
    
    private var didSetupSubviews: Bool = false
    private var didSetupConstraints: Bool = false
    
    init(reuseIdentifier: String?) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        self.accessoryType = .DisclosureIndicator
        self.setupSubviews()
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
    
    func setupSubviews() {
        
        //this image should be 36x25 to match CardIO's CardIOCreditCardInfo.logoForCardType(cardType: CardIOCreditCardType) method
        addCreditCardImageView.contentMode = .Center
        addCreditCardImageView.image = UIImage(named: "btn_accessory_plus")
        self.contentView.addSubview(addCreditCardImageView)
        
        centeredLabel.textColor = Styles.Colors.red2
        centeredLabel.font = Styles.FontFaces.regular(14)
        centeredLabel.text = "add_payment_method".localizedString
        self.contentView.addSubview(centeredLabel)
        
        didSetupSubviews = true
    }
    
    func setupConstraints() {
        
        addCreditCardImageView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.contentView).offset(PPCreditCardCell.LEFT_IMAGE_OFFSET)
            make.centerY.equalTo(self.contentView)
            make.size.equalTo(CGSize(width: 36, height: 25))
        }
        
        centeredLabel.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(addCreditCardImageView.snp_right).offset(PPCreditCardCell.IMAGE_TO_TEXT_OFFSET)
            make.centerY.equalTo(self.contentView)
        }
        
        didSetupConstraints = true
    }
    
}
