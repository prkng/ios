//
//  ScheduleViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 02/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class ScheduleViewController: AbstractViewController, UICollectionViewDataSource, UICollectionViewDelegate, ScheduleCollectionViewLayoutDelegate{
    
    var spot : ParkingSpot
    var headerView : ScheduleHeaderView
    var collectionView : UICollectionView
    var collectionViewLayout : ScheduleCollectionViewLayout
    var dayIndicator : ScheduleDayIndicatorView
    
    let scheduleCollectionViewCellIdentifier : String = "ScheduleCollectionViewCell"
    
    init(spot : ParkingSpot) {
        headerView = ScheduleHeaderView()
        collectionViewLayout = ScheduleCollectionViewLayout()
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionViewLayout)
        self.spot = spot
        dayIndicator = ScheduleDayIndicatorView()
        
        super.init(nibName: nil, bundle: nil)
        
        collectionViewLayout.delegate = self
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = Styles.Colors.stone
        setupViews()
        setupConstraints()
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.registerClass(ScheduleCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: scheduleCollectionViewCellIdentifier)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateHeaderValues()
    }
    
    func setupViews() {
        collectionView.backgroundColor = Styles.Colors.stone
        collectionView.dataSource = self
        collectionView.delegate = self
        self.view.addSubview(collectionView)

        
        self.view.addSubview(headerView)
        headerView.layer.shadowColor = UIColor.blackColor().CGColor
        headerView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        headerView.layer.shadowOpacity = 0.2
        headerView.layer.shadowRadius = 0.5
        
        dayIndicator.setDays(["M", "T", "W", "T", "F", "S", "S"])
        self.view.addSubview(self.dayIndicator)
        
    }
    
    func setupConstraints () {
        
        collectionView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.headerView.snp_bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.dayIndicator.snp_top)
        }
       
        headerView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(150)
        }
        
        dayIndicator.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(50)
        }
    }
    
    func updateHeaderValues () {
        headerView.titleLabel.text = spot.name
    }

    
    // UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 7; //days in a week
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        NSLog("section : %@, count : %@", section.description, spot.rules.agenda[section].count.description)
        return spot.rules.agenda[section].count;
        
    }
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cell : ScheduleCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(scheduleCollectionViewCellIdentifier, forIndexPath: indexPath) as! ScheduleCollectionViewCell
        
        cell.backgroundColor = Styles.Colors.red2
        
        
        var startF : Float = spot.rules.agenda[indexPath.section][0]
        var endF : Float = spot.rules.agenda[indexPath.section][1]
        
        cell.setHours( ScheduleCellModel(startF: startF, endF: endF))       
        
        
        return cell;
    }
    
    
    // UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    // UIScrollViewDelegate
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        var kMaxIndex : CGFloat  = 7;
        var kCellWidth : CGFloat = self.view.frame.size.width / 3
        
        var targetX : CGFloat = scrollView.contentOffset.x + velocity.x * 60.0;
        var targetIndex : CGFloat = round(targetX / kCellWidth);
        if (targetIndex < 0) {
            targetIndex = 0;
        }
        if (targetIndex > kMaxIndex) {
            targetIndex = kMaxIndex;
        }
        
        targetContentOffset.memory.x = targetIndex * (self.view.frame.size.width / 3.0)
    }

    
    
    //
    
    func modelForItemAtIndexPath(indexpath : NSIndexPath) -> ScheduleCellModel {     
        
        var startF : Float = spot.rules.agenda[indexpath.section][0]
        var endF : Float = spot.rules.agenda[indexpath.section][1]
        
        return ScheduleCellModel(startF: startF, endF: endF)
    }
    
    func contentSizeForCollectionView () -> CGSize {
        return CGSize(width: self.view.frame.size.width * 7.0 / 3.0 , height: self.view.frame.size.height - 202.0)
    }

}



class ScheduleCellModel {
    
    var startTime : String?
    var startTimeAmPm : String?
    var endTime : String?
    var endTimeAmPm : String?
    
    var heightMultiplier : Double?
    var yIndexMultiplier : Double?
    
    init (startF : Float, endF : Float) {
        
        heightMultiplier = Double(endF - startF)
        yIndexMultiplier = Double(startF / 24.0)
        
        
        var startTm = startF
        var endTm = endF
        
        let nf = NSNumberFormatter()
        nf.numberStyle = NSNumberFormatterStyle.DecimalStyle
        nf.maximumIntegerDigits = 2
        nf.minimumIntegerDigits = 2
        nf.maximumFractionDigits = 0
        
        
        if(startF > 12.0) {
            startTimeAmPm = "PM"
            startTm = startF - 12
        } else {
            startTimeAmPm = "AM"
        }
        
        var diffStart = startTm - floor(startTm)
        
        
        var startMinutes : String = "00"
        
        if (diffStart > 0) {
            startMinutes = nf.stringFromNumber(diffStart * 60)!
        }
       
        
        startTime = nf.stringFromNumber(startTm)! + ":" + startMinutes

        
        if(endF > 12) {
            endTimeAmPm = "PM"
            endTm = endTm - 12
        } else {
            endTimeAmPm = "AM"
        }
        
        var diffEnd = endTm - floor(endTm)
        
        
        var endMinutes : String = "00"
        
        if (diffStart > 0) {
            endMinutes = nf.stringFromNumber(diffEnd * 60)!
        }
        endTime = nf.stringFromNumber(endTm)! + ":" + endMinutes
        
        
    }
    
}

