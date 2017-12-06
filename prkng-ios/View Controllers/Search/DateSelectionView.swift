//
//  DateSelectionView.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 29/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class DateSelectionView: UIView {
    
    var topContainer : UIView
    var bottomContainer : UIView
    var todayButton : DayButton
    var tomorrowButton : DayButton
    var weekButtons : Array<DayOfWeekButton>
    
    var didSetupSubviews: Bool
    var didSetupConstraints: Bool
    
    
    convenience init(title: String, icon : UIImage?, selectedIcon : UIImage?) {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {
        
        topContainer = UIView()
        bottomContainer = UIView()
        todayButton = DayButton()
        tomorrowButton = DayButton()
        weekButtons = []
        
        for _ in 0...6 {
            weekButtons.append(DayOfWeekButton())
        }
        
        didSetupSubviews = false
        didSetupConstraints = true
        
        selectedDay = 0
        super.init(frame: frame)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    
    override func layoutSubviews() {
        
        if(!didSetupSubviews) {
            setupSubviews()
            didSetupConstraints = false
            self.setNeedsUpdateConstraints()
        }
        
        super.layoutSubviews()
    }
    
    override func updateConstraints() {
        
        if(!self.didSetupConstraints) {
            setupConstraints()
        }
        super.updateConstraints()
    }
    
    func setupSubviews() {
        
        addSubview(topContainer)
        
        
        bottomContainer.backgroundColor = Styles.Colors.stone
        addSubview(bottomContainer)
        
        
        todayButton.title = NSLocalizedString("today", comment : "" )
        todayButton.addTarget(self, action: #selector(DateSelectionView.selectToday), for: UIControlEvents.touchUpInside)
        topContainer.addSubview(todayButton)
        
        tomorrowButton.title = NSLocalizedString("tomorrow", comment : "" )
        tomorrowButton.addTarget(self, action: #selector(DateSelectionView.selectTomorrow), for: UIControlEvents.touchUpInside)
        topContainer.addSubview(tomorrowButton)
        
        
        
        let monday = NSLocalizedString("monday", comment:"") as NSString
        weekButtons[0].title  = monday.substring(with: NSRange(location: 0, length: 1))
        weekButtons[0].addTarget(self, action: #selector(DateSelectionView.select0), for: UIControlEvents.touchUpInside)
        
        let tuesday = NSLocalizedString("tuesday", comment:"") as NSString
        weekButtons[1].title  = tuesday.substring(with: NSRange(location: 0, length: 1))
        weekButtons[1].addTarget(self, action: #selector(DateSelectionView.select1), for: UIControlEvents.touchUpInside)
        
        let wednesday = NSLocalizedString("wednesday", comment:"") as NSString
        weekButtons[2].title  = wednesday.substring(with: NSRange(location: 0, length: 1))
        weekButtons[2].addTarget(self, action: #selector(DateSelectionView.select2), for: UIControlEvents.touchUpInside)
        
        let thursday = NSLocalizedString("thursday", comment:"") as NSString
        weekButtons[3].title  = thursday.substring(with: NSRange(location: 0, length: 1))
        weekButtons[3].addTarget(self, action: #selector(DateSelectionView.select3), for: UIControlEvents.touchUpInside)
        
        let friday = NSLocalizedString("friday", comment:"") as NSString
        weekButtons[4].title = friday.substring(with: NSRange(location: 0, length: 1))
        weekButtons[4].addTarget(self, action: #selector(DateSelectionView.select4), for: UIControlEvents.touchUpInside)
        
        let saturday = NSLocalizedString("saturday", comment:"") as NSString
        weekButtons[5].title  = saturday.substring(with: NSRange(location: 0, length: 1))
        weekButtons[5].addTarget(self, action: #selector(DateSelectionView.select5), for: UIControlEvents.touchUpInside)
        
        let sunday = NSLocalizedString("sunday", comment:"") as NSString
        weekButtons[6].title = sunday.substring(with: NSRange(location: 0, length: 1))
        weekButtons[6].addTarget(self, action: #selector(DateSelectionView.select6), for: UIControlEvents.touchUpInside)
    
        
        for b in weekButtons {
            bottomContainer.addSubview(b)
        }
        
        didSetupSubviews = true
    }
    
    func setupConstraints() {
        
        topContainer.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(50)
        }
        
        bottomContainer.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self)
            make.left.equalTo(self)
            make.right.equalTo(self)
            make.height.equalTo(60)
        }
        
        
        todayButton.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.topContainer)
            make.left.equalTo(self.topContainer)
            make.bottom.equalTo(self.topContainer)
            make.width.equalTo(self.topContainer).multipliedBy(0.5)
        }
        
        tomorrowButton.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.topContainer)
            make.right.equalTo(self.topContainer)
            make.bottom.equalTo(self.topContainer)
            make.width.equalTo(self.topContainer).multipliedBy(0.5)
        }
        
        
        
        weekButtons[0].snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.bottomContainer)
            make.width.equalTo(self.bottomContainer).multipliedBy(1.0/7.0)
            make.top.equalTo(self.bottomContainer)
            make.bottom.equalTo(self.bottomContainer)
        }
        
        for i in 1...6 {
            
            weekButtons[i].snp_makeConstraints(closure: { (make) -> () in
                make.left.equalTo(self.weekButtons[i-1].snp_right)
                make.width.equalTo(self.bottomContainer).multipliedBy(1.0/7.0)
                make.top.equalTo(self.bottomContainer)
                make.bottom.equalTo(self.bottomContainer)            })
            
        }
        
        
        didSetupConstraints = true
    }
    
    
    
    func selectToday () {
        selectedDay = DateUtil.dayIndexOfTheWeek()
    }
    
    func selectTomorrow () {
        
        let day = DateUtil.dayIndexOfTheWeek()
        
        if (day == 6) {
            selectedDay = 0
        } else {
            selectedDay = day + 1
        }
        
        
    }
    
    func select0 () { selectedDay = 0 }
    func select1 () { selectedDay = 1 }
    func select2 () { selectedDay = 2 }
    func select3 () { selectedDay = 3 }
    func select4 () { selectedDay = 4 }
    func select5 () { selectedDay = 5 }
    func select6 () { selectedDay = 6 }
    
    
    func deselectAll () {
        
        todayButton.isSelected = false
        tomorrowButton.isSelected = false
        
        for b in weekButtons {
            b.isSelected = false
        }
        
    }
    

    
    var selectedDay : Int {
        
        didSet {
            
            deselectAll()
            
            let day = DateUtil.dayIndexOfTheWeek()
            
            if (day == selectedDay) {
                todayButton.isSelected = true
            } else if (day == (selectedDay - 1)
                || ((day == 6) && selectedDay == 0) ) {
                    tomorrowButton.isSelected = true
            }
            
            weekButtons[selectedDay].isSelected = true
        }
    }
    
    
    
    
}
