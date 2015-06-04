//
//  ReportOverlayView.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 04/06/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class ReportOverlayView: UIView {
    
    var reportTitleLabel : UILabel
    var streetNameLabel : UILabel
    var textLabel : UILabel
    var thanksLabel : UILabel
    
    var didSetupSubviews: Bool
    var didSetupConstraints: Bool
    
    var delegate : SpotDetailViewDelegate?
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    override init(frame: CGRect) {
        
        reportTitleLabel = UILabel()
        streetNameLabel = UILabel()
        textLabel = UILabel()
        thanksLabel = UILabel()
        
        
        didSetupSubviews = false
        didSetupConstraints = false
        
        super.init(frame: frame)
        
        setupSubviews()
        self.setNeedsUpdateConstraints()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func updateConstraints() {
        if(!self.didSetupConstraints) {
            setupConstraints()
        }
        
        super.updateConstraints()
    }
    
    func setupSubviews() {
        
        self.backgroundColor = Styles.Colors.transparentBackground
        
        reportTitleLabel.font = Styles.FontFaces.light(12)
        reportTitleLabel.textColor = Styles.Colors.stone
        reportTitleLabel.textAlignment = NSTextAlignment.Center
        reportTitleLabel.text = "report_title".localizedString
        addSubview(reportTitleLabel)
        
        streetNameLabel.font = Styles.Fonts.h1
        streetNameLabel.textColor = Styles.Colors.cream1
        streetNameLabel.textAlignment = NSTextAlignment.Center
        addSubview(streetNameLabel)
        
        textLabel.font = Styles.Fonts.h3
        textLabel.textColor = Styles.Colors.red2
        textLabel.textAlignment = NSTextAlignment.Center
        textLabel.numberOfLines = 0
        textLabel.text = "report_text".localizedString
        addSubview(textLabel)
        
        thanksLabel.font = Styles.FontFaces.light(12)
        thanksLabel.textAlignment = NSTextAlignment.Center
        thanksLabel.textColor = Styles.Colors.stone
        thanksLabel.text = "report_thanks".localizedString
        addSubview(thanksLabel)
        
    }
    
    
    func setupConstraints() {
        
        textLabel.snp_makeConstraints { (make) -> () in
            make.center.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
        }
        
        streetNameLabel.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.textLabel.snp_top).with.offset(-77)
            make.height.equalTo(34)
            make.left.equalTo(self)
            make.right.equalTo(self)
        }
        
        reportTitleLabel.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.streetNameLabel.snp_top).with.offset(-7)
            make.height.equalTo(34)
            make.left.equalTo(self)
            make.right.equalTo(self)
        }
        
        thanksLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.textLabel.snp_bottom).with.offset(98)
            make.height.equalTo(17)
            make.left.equalTo(self)
            make.right.equalTo(self)
        }
        
        
    }
    
    
    
}
