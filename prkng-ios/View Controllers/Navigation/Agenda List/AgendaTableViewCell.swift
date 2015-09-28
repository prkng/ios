//
//  AgendaTableViewCell.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-07-09.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class AgendaTableViewCell: UITableViewCell {
    
    let colorView = UIView()
    let dayLabel = UILabel()
    var icon = UIImageView()
    let hoursText = UILabel()
    var topLine = UIView()
    var bottomLine = UIView()
    
    var agendaItem: AgendaItem
    
    var didSetupSubviews : Bool = false
    var didSetupConstraints : Bool = true
    
    init(agendaItem: AgendaItem, style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.agendaItem = agendaItem
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        if (!didSetupSubviews) {
            setupSubviews(self.agendaItem)
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
    
    func setupSubviews(agendaItem: AgendaItem) {
        
        var hoursTextColor = Styles.Colors.petrol1
        
        if agendaItem.isToday() {
            self.backgroundColor = Styles.Colors.cream1
        } else {
            self.backgroundColor = Styles.Colors.stone
        }
        
        var imageView = UIImageView()
        switch agendaItem.rule.ruleType {
        case .Free:
            colorView.backgroundColor = Styles.Colors.cream1
            imageView = ViewFactory.authorizedIcon(Styles.Colors.petrol2)
            break
        case .Restriction:
            hoursTextColor = Styles.Colors.red2
            colorView.backgroundColor = Styles.Colors.red2
            imageView = ViewFactory.forbiddenIcon(Styles.Colors.red2)
            break
        case .TimeMax:
            colorView.backgroundColor = Styles.Colors.petrol2
            imageView = ViewFactory.timeMaxIcon(agendaItem.timeLimit/60, addMaxLabel: false, color: Styles.Colors.petrol2)
            break
        case .Paid:
            hoursTextColor = Styles.Colors.curry
            colorView.backgroundColor = Styles.Colors.curry
            imageView = ViewFactory.paidIcon("", color: Styles.Colors.curry)
            break
        }
        
        icon.image = imageView.image
        icon.tintColor = imageView.tintColor
        icon.contentMode = .ScaleAspectFit

        dayLabel.font = Styles.Fonts.h3
        dayLabel.textColor = Styles.Colors.midnight1
        dayLabel.textAlignment = .Left
        dayLabel.text = agendaItem.dayText()
        
        hoursText.font = Styles.FontFaces.light(14)
        hoursText.numberOfLines = 2
        hoursText.textColor = hoursTextColor
        hoursText.textAlignment = .Right
        hoursText.attributedText = agendaItem.timeText()
        
        topLine.backgroundColor = Styles.Colors.transparentWhite
        bottomLine.backgroundColor = Styles.Colors.transparentBlack
        
        if !didSetupSubviews {
            contentView.addSubview(colorView)
            contentView.addSubview(dayLabel)
            contentView.addSubview(icon)
            contentView.addSubview(hoursText)
            contentView.addSubview(topLine)
            contentView.addSubview(bottomLine)
        }
        
        didSetupSubviews = true
        didSetupConstraints = false
    }
    
    func setupConstraints () {
        
        colorView.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.contentView)
            make.top.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView)
            make.width.equalTo(14)
        }
        
        dayLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.colorView.snp_right).offset(14)
            make.centerY.equalTo(self.contentView)
        }
        
        icon.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.dayLabel.snp_right).offset(10)
            make.right.equalTo(self.contentView).offset(-114)
            make.centerY.equalTo(self.contentView)
            make.size.equalTo(CGSizeMake(25, 25))
        }
        
        hoursText.snp_makeConstraints { (make) -> () in
            make.left.lessThanOrEqualTo(self.icon.snp_right).offset(10)
            make.right.equalTo(self.contentView).offset(-40)
            make.centerY.equalTo(self.contentView)
        }
        
        topLine.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.top.equalTo(self)
            make.height.equalTo(0.5)
        }
        
        bottomLine.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.bottom.equalTo(self)
            make.height.equalTo(0.5)
        }
        
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
