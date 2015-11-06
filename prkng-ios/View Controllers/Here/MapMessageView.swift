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
    
    private var didsetupSubviews : Bool
    private var didSetupConstraints : Bool
    
    override init(frame: CGRect) {
        
        messageContainer = UIView()
        mapMessageViewImage = UIImageView(image: UIImage(named:"icon_exclamation"))
        mapMessageLabel = UILabel()
        
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
        
        didsetupSubviews = true
        didSetupConstraints = false
    }
    
    func setupConstraints () {
        
        messageContainer.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.top.equalTo(self)
            make.bottom.equalTo(self)
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
        
    }
        
}
