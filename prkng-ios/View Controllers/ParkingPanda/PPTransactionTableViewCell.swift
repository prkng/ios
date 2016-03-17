//
//  PPTransactionTableViewCell.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2016-03-01.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class PPTransactionTableViewCell: UITableViewCell {

    var transaction: ParkingPandaTransaction? {
        didSet {
            setupTransaction()
        }
    }
    
    private let topLabel = UILabel()
    private let bottomLabel = UILabel()

    private var didSetupSubviews : Bool = false
    private var didSetupConstraints : Bool = true
    
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
                
        self.backgroundColor = Styles.Colors.cream1
        
        topLabel.font = Styles.FontFaces.regular(12)
        self.contentView.addSubview(topLabel)
        
        bottomLabel.font = Styles.FontFaces.bold(22)
        self.contentView.addSubview(bottomLabel)
        
        didSetupSubviews = true
        didSetupConstraints = false
    }
    
    func setupConstraints () {
        
        topLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.contentView).offset(40)
            make.right.equalTo(self.contentView).offset(-10)
            make.top.equalTo(self.contentView).offset(16)
        }
        
        bottomLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(topLabel)
            make.right.equalTo(topLabel)
            make.top.equalTo(topLabel.snp_bottom).offset(2)
        }
        
    }
    
    private func setupTransaction() {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy 'at' HH:mm"

        let currentDate = NSDate()
        let fromDateString = dateFormatter.stringFromDate(transaction?.startDateAndTime ?? currentDate)
        let toDateString = NSDateFormatter.localizedStringFromDate(transaction?.endDateAndTime ?? currentDate, dateStyle: .NoStyle, timeStyle: .ShortStyle)
        topLabel.text = fromDateString + " - " + toDateString
        bottomLabel.text = transaction?.location.address
        
        if transaction?.endDateAndTime?.earlierDate(currentDate) == currentDate {
            //then the transaction is in the future
            topLabel.textColor = Styles.Colors.red2
            bottomLabel.textColor = Styles.Colors.midnight2
        } else {
            //it's in the past!
            topLabel.textColor = Styles.Colors.anthracite1
            bottomLabel.textColor = Styles.Colors.anthracite1
        }
    }
    
    
    
}
