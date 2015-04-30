//
//  ScheduleViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 02/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class ScheduleViewController: AbstractViewController, UIScrollViewDelegate {
    
    var spot : ParkingSpot
    var delegate : ScheduleViewControllerDelegate?
    private var scheduleItems : Array<ScheduleItemModel>

    private var headerView : ScheduleHeaderView
    private var scrollView : UIScrollView
    private var contentView : UIView
    private var columnViews : Array<ScheduleColumnView>
    private var scheduleItemViews : Array<ScheduleItemView>
    private var dayIndicator : ScheduleDayIndicatorView
    
    private(set) var HEADER_HEIGHT : CGFloat
    private(set) var DAY_INDICATOR_HEIGHT : CGFloat
    private(set) var COLUMN_SIZE : CGFloat
    private(set) var COLUMN_HEADER_HEIGHT : CGFloat
    private(set) var CONTENTVIEW_HEIGHT : CGFloat
    private(set) var ITEM_HOUR_HEIGHT : CGFloat
    
    init(spot : ParkingSpot) {
        self.spot = spot
        headerView = ScheduleHeaderView()
        scrollView = UIScrollView()
        contentView = UIView()
        scheduleItems = []
        columnViews = []
        scheduleItems = []
        scheduleItemViews = []
        dayIndicator = ScheduleDayIndicatorView()
        
        HEADER_HEIGHT = 142.0
        COLUMN_SIZE = UIScreen.mainScreen().bounds.size.width / 3.0
        DAY_INDICATOR_HEIGHT = 50.0
        CONTENTVIEW_HEIGHT = UIScreen.mainScreen().bounds.size.height - HEADER_HEIGHT - DAY_INDICATOR_HEIGHT - 71.0
        COLUMN_HEADER_HEIGHT = 45.0
        ITEM_HOUR_HEIGHT = (CONTENTVIEW_HEIGHT - COLUMN_HEADER_HEIGHT) / 24.0
        
        NSLog("item_hour_height : %f", ITEM_HOUR_HEIGHT)
        
        super.init(nibName: nil, bundle: nil)
        
        var index = 0
        for arr in spot.rules.agenda {
            if (arr.count > 0) {
                var startF : CGFloat = CGFloat(spot.rules.agenda[index][0])
                var endF : CGFloat = CGFloat(spot.rules.agenda[index][1])
                self.scheduleItems.append(ScheduleItemModel(startF: startF, endF: endF, column : index, limited: false))
            }
            ++index
        }
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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateValues()
    }
    
    func setupViews() {
        scrollView.backgroundColor = Styles.Colors.cream2
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        self.view.addSubview(scrollView)
        
        self.view.addSubview(headerView)
        headerView.layer.shadowColor = UIColor.blackColor().CGColor
        headerView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        headerView.layer.shadowOpacity = 0.2
        headerView.layer.shadowRadius = 0.5
        headerView.scheduleButton.addTarget(self, action: "dismiss", forControlEvents: UIControlEvents.TouchUpInside)
        
        scrollView.addSubview(contentView)
        
        for i in 0...6 {
            var columnView : ScheduleColumnView = ScheduleColumnView()
            contentView.addSubview(columnView)
            columnViews.append(columnView)
            columnView.setActive(false)
        }
        
        columnViews[0].setActive(true)
        
        dayIndicator.userInteractionEnabled = false
        view.addSubview(self.dayIndicator)
        
        for scheduleItem in scheduleItems {
            var scheduleItemView : ScheduleItemView = ScheduleItemView(model : scheduleItem)
            columnViews[scheduleItem.columnIndex!].addSubview(scheduleItemView)
            scheduleItemViews.append(scheduleItemView)
        }
        
    }
    
    func setupConstraints () {
        
        headerView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(self.HEADER_HEIGHT)
        }
        
        scrollView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.headerView.snp_bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        
        contentView.snp_makeConstraints { (make) -> () in
            make.height.equalTo(self.CONTENTVIEW_HEIGHT)
            make.width.equalTo(self.COLUMN_SIZE * 7.0)
            make.edges.equalTo(self.scrollView)
        }
        
        var columnIndex = 0
        for column in columnViews {
            column.snp_makeConstraints({ (make) -> () in
                make.top.equalTo(self.contentView)
                make.bottom.equalTo(self.contentView)
                make.width.equalTo(self.COLUMN_SIZE)
                make.left.equalTo(self.contentView).with.offset(self.COLUMN_SIZE * CGFloat(columnIndex))
            });
            columnIndex++;
        }
        
        var itemIndex = 0
        for itemView in scheduleItemViews {
            var scheduleItem = scheduleItems[itemIndex]
            var columnView = columnViews[scheduleItem.columnIndex!]
            
            NSLog("column index : %d", scheduleItem.columnIndex!)
            NSLog("y multiplier : %f", scheduleItem.yIndexMultiplier!)
            NSLog("height multiplier : %f", scheduleItem.heightMultiplier!)


            
            itemView.snp_makeConstraints({ (make) -> () in
                make.top.equalTo(columnView).with.offset((self.ITEM_HOUR_HEIGHT * scheduleItem.yIndexMultiplier!) + self.COLUMN_HEADER_HEIGHT)
                make.height.equalTo(self.ITEM_HOUR_HEIGHT * scheduleItem.heightMultiplier!)
                make.left.equalTo(columnView)
                make.right.equalTo(columnView)
            })
            
            itemIndex++;
        }
       
        dayIndicator.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(self.DAY_INDICATOR_HEIGHT)
        }
        
        // items
    }
    
    func updateValues () {
        headerView.titleLabel.text = spot.name
        dayIndicator.setDays(["M", "T", "W", "T", "F", "S", "S"])
        
        var columnTitles = ["TODAY", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
        var index = 0
        for columnView in columnViews {
            columnView.setTitle(columnTitles[index++])
        }
    }

    
    
    
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
//    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
//        
//        var cell : ScheduleCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(scheduleCollectionViewCellIdentifier, forIndexPath: indexPath) as! ScheduleCollectionViewCell
//        
//        cell.backgroundColor = Styles.Colors.red2
//        
//        
//        var startF : Float = spot.rules.agenda[indexPath.section][0]
//        var endF : Float = spot.rules.agenda[indexPath.section][1]
//        
//        cell.setHours( ScheduleCellModel(startF: startF, endF: endF))       
//        
//        
//        return cell;
//    }
    
    
    // UIScrollViewDelegate
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        var kMaxIndex : CGFloat  = 7
        
        var targetX : CGFloat = scrollView.contentOffset.x + velocity.x * 60.0
        var targetIndex : CGFloat = round(targetX / COLUMN_SIZE)
        if (targetIndex < 0) {
            targetIndex = 0
        }
        if (targetIndex > kMaxIndex) {
            targetIndex = kMaxIndex;
        }
        
        targetContentOffset.memory.x = targetIndex * (self.view.frame.size.width / 3.0)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        NSLog("content offset : %f", scrollView.contentOffset.x)
        
        var maxOffset : Float = Float(COLUMN_SIZE * 4.0)
        var ratio : Float = 0.0
        
        NSLog("max offset : %f", maxOffset)

        
        if (scrollView.contentOffset.x != 0) {
            ratio = Float(scrollView.contentOffset.x) / maxOffset
        }
        
        NSLog("ratio : %f", ratio)
        
        self.dayIndicator.setPositionRatio(CGFloat(ratio))
        
    }
    
    
    func dismiss () {
        self.delegate!.hideScheduleView()
    }

    
}



class ScheduleItemModel {
    
    var startTime : String?
    var startTimeAmPm : String?
    var endTime : String?
    var endTimeAmPm : String?
    
    var heightMultiplier : CGFloat?
    var yIndexMultiplier : CGFloat?
    
    var columnIndex : Int?
    
    var limited : Bool
    
    init (startF : CGFloat, endF : CGFloat, column : Int, limited: Bool) {
        
        columnIndex = column
        
        self.limited = limited
        
        heightMultiplier = (endF - startF)
        yIndexMultiplier = startF
        
        if(heightMultiplier < 2.5) {
            heightMultiplier = 2.5
        }
        
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


protocol ScheduleViewControllerDelegate {
    func hideScheduleView()
}

