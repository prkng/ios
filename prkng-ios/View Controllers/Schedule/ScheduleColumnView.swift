//
//  ColumnHeader.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 10/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class ScheduleColumnView: UIView {
    
    var titleLabel : UILabel
    private var titleContainerView : UIView
    private var horizontalSeperator : UIView
    private var verticalSeperator : UIView
    
    var didSetupSubviews : Bool
    var didSetupConstraints : Bool
    
    override init(frame: CGRect) {
        
        didSetupSubviews = false
        didSetupConstraints = false
       
        titleLabel = UILabel()
        titleContainerView = UIView()
        horizontalSeperator = UIView()
        verticalSeperator = UIView()
        super.init(frame: frame)
        
        setupSubviews()
        self.setNeedsUpdateConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func updateConstraints() {
        
        if !didSetupConstraints {
            setupConstraints()
        }
        
        super.updateConstraints()
    }

    private func setupSubviews() {
        
        addSubview(titleContainerView)

        titleLabel.font = Styles.FontFaces.regular(14)
        titleLabel.textColor = Styles.Colors.petrol2
        titleContainerView.addSubview(titleLabel)

        verticalSeperator.backgroundColor = Styles.Colors.beige1
        addSubview(verticalSeperator)
        
        horizontalSeperator.backgroundColor = Styles.Colors.beige1
        addSubview(horizontalSeperator)
        
        didSetupSubviews = true
    }
    
    private func setupConstraints () {
        
        titleContainerView.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self)
            make.top.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(45)
        }
        
        titleLabel.snp_makeConstraints { (make) -> () in
            make.center.equalTo(self.titleContainerView)
        }
        
        verticalSeperator.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.titleContainerView.snp_bottom)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(0.5)
        }
        
        horizontalSeperator.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self)
            make.bottom.equalTo(self)
            make.right.equalTo(self)
            make.width.equalTo(0.5)
        }
        
        didSetupConstraints = true
    }
    
    func setActive (active: Bool) {
        
        if(active) {
            self.backgroundColor = Styles.Colors.cream1
        } else {
            self.backgroundColor = Styles.Colors.cream2
        }
    }
    
    func setTitle(title : String) {
        self.titleLabel.text = title
    }
}
