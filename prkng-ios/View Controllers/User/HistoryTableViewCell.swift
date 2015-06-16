//
//  HistoryTableViewCell.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 16/06/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {

    let dateLabel = UILabel()
    let addressLabel = UILabel()
    
    var didSetupSubviews : Bool = false
    var didSetupConstraints : Bool = true
    
    override func layoutSubviews() {
        if (!didSetupSubviews) {
            setupSubviews()
            setNeedsUpdateConstraints()
        }
        super.layoutSubviews()
    }
    
    override func updateConstraints() {
        if (!didSetupConstraints) {
            setupConstraints()
        }
        super.updateConstraints()
    }
    
    func setupSubviews() {
        
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.05
        layer.shadowRadius = 1
        layer.shadowOffset = CGSize(width: 0, height: 1)
        
        
        self.backgroundColor = Styles.Colors.stone
    
        dateLabel.font = Styles.FontFaces.regular(12)
        dateLabel.textColor = Styles.Colors.red2
        contentView.addSubview(dateLabel)
        
        addressLabel.font = Styles.FontFaces.light(20)
        addressLabel.textColor = Styles.Colors.midnight2
        contentView.addSubview(addressLabel)
        
        didSetupSubviews = true
        didSetupConstraints = false
    }
    
    func setupConstraints () {
        
        dateLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.contentView).with.offset(25)
            make.right.equalTo(self.contentView).with.offset(-25)
            make.top.equalTo(self.contentView).with.offset(5)
            make.height.equalTo(17)            
        }
        
        addressLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.dateLabel.snp_bottom).with.offset(1.5)
            make.left.equalTo(self.dateLabel)
            make.right.equalTo(self.dateLabel)
        }
        
    }
    
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
