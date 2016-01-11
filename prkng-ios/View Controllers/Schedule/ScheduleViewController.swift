//
//  ScheduleViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 02/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class ScheduleViewController: PRKModalViewControllerChild, UIScrollViewDelegate {
    
    private var scheduleItems : Array<ScheduleItemModel>

    private var scrollView : UIScrollView
    private var contentView : UIView
    private var leftView : ScheduleLeftView
    private var columnViews : Array<ScheduleColumnView>
    private var scheduleItemViews : Array<ScheduleItemView>
    
    private(set) var LEFT_VIEW_WIDTH : CGFloat
    private(set) var COLUMN_SIZE : CGFloat
    private(set) var COLUMN_HEADER_HEIGHT : CGFloat
    private(set) var CONTENTVIEW_HEIGHT : CGFloat
    private(set) var ITEM_HOUR_HEIGHT : CGFloat
    
    override init(spot: ParkingSpot, view: UIView) {
        scrollView = UIScrollView()
        contentView = UIView()
        leftView = ScheduleLeftView()
        scheduleItems = []
        columnViews = []
        scheduleItemViews = []
        
        LEFT_VIEW_WIDTH = UIScreen.mainScreen().bounds.size.width * 0.18
        COLUMN_SIZE = UIScreen.mainScreen().bounds.size.width * 0.28
        CONTENTVIEW_HEIGHT = UIScreen.mainScreen().bounds.size.height - Styles.Sizes.modalViewHeaderHeight - 71.0
        COLUMN_HEADER_HEIGHT = 45.0
        ITEM_HOUR_HEIGHT = (CONTENTVIEW_HEIGHT - COLUMN_HEADER_HEIGHT) / 24.0
        
        super.init(spot: spot, view: view)
        
        scheduleItems = ScheduleHelper.getScheduleItems(spot)
        scheduleItems = ScheduleHelper.processScheduleItems(scheduleItems)
    }
    
    required init?(coder aDecoder: NSCoder) {
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
        self.screenName = "Schedule (Agenda) View"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateValues()
    }
    
    override func viewWillLayoutSubviews() {
        
        //forbidden views should be on top
        for column in columnViews {
            for view in column.subviews {
                if let subview =  view as? ScheduleItemView {
                    if(subview.rule.ruleType == ParkingRuleType.TimeMax) {
                        column.bringSubviewToFront(subview)
                    }
                }
            }
        }
        //...but snow removals should be on top of them!
        for column in columnViews {
            for view in column.subviews {
                if let subview =  view as? ScheduleItemView {
                    if(subview.rule.ruleType == ParkingRuleType.SnowRestriction) {
                        column.bringSubviewToFront(subview)
                    }
                }
            }
        }
        
        super.viewWillLayoutSubviews()
    }
    
    func setupViews() {
        scrollView.backgroundColor = Styles.Colors.cream2
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        self.view.addSubview(scrollView)
        
        let scheduleTimes = ScheduleTimeModel.getScheduleTimesFromItems(scheduleItems)
        leftView = ScheduleLeftView(model: scheduleTimes)
        leftView.backgroundColor = Styles.Colors.cream2
        self.view.addSubview(leftView)

        scrollView.addSubview(contentView)
        
        for _ in 0...6 {
            let columnView : ScheduleColumnView = ScheduleColumnView()
            contentView.addSubview(columnView)
            columnViews.append(columnView)
            columnView.setActive(false)
        }
        
        columnViews[0].setActive(true)
        
        for scheduleItem in scheduleItems {
            let scheduleItemView : ScheduleItemView = ScheduleItemView(model : scheduleItem)
            columnViews[scheduleItem.columnIndex!].addSubview(scheduleItemView)
            scheduleItemViews.append(scheduleItemView)
        }
        
        
    }
    
    func setupConstraints () {
        
        leftView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view).offset(Styles.Sizes.modalViewHeaderHeight)
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.width.equalTo(self.LEFT_VIEW_WIDTH)
        }
        
        for label in leftView.timeLabels {
            label.snp_makeConstraints(closure: { (make) -> () in
                make.left.equalTo(self.leftView)
                make.right.equalTo(self.leftView).offset(-7)
                make.centerY.equalTo(self.leftView.snp_top).offset((self.ITEM_HOUR_HEIGHT * label.scheduleTimeModel!.yIndexMultiplier) + (label.scheduleTimeModel!.heightOffsetInHours * self.ITEM_HOUR_HEIGHT) + self.COLUMN_HEADER_HEIGHT)
                make.top.greaterThanOrEqualTo(self.leftView)
                make.bottom.lessThanOrEqualTo(self.leftView)
            })
        }

        
        scrollView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view).offset(Styles.Sizes.modalViewHeaderHeight)
            make.left.equalTo(self.view).offset(self.LEFT_VIEW_WIDTH)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        
        contentView.snp_makeConstraints { (make) -> () in
            make.height.equalTo(self.scrollView)//CONTENTVIEW_HEIGHT)
            make.width.equalTo(self.COLUMN_SIZE * 7.0)
            make.edges.equalTo(self.scrollView)
        }
        
        var columnIndex = 0
        for column in columnViews {
            column.snp_makeConstraints(closure: { (make) -> () in
                make.top.equalTo(self.contentView)
                make.bottom.equalTo(self.contentView)
                make.width.equalTo(self.COLUMN_SIZE)
                make.left.equalTo(self.contentView).offset(self.COLUMN_SIZE * CGFloat(columnIndex))
            });
            columnIndex++;
        }
        
        var itemIndex = 0
        for itemView in scheduleItemViews {
            
            
            let scheduleItem = scheduleItems[itemIndex]
            
            let columnView = columnViews[scheduleItem.columnIndex!]
            
            itemView.snp_makeConstraints(closure: { (make) -> () in
                make.top.equalTo(columnView).offset((self.ITEM_HOUR_HEIGHT * scheduleItem.yIndexMultiplier!) + self.COLUMN_HEADER_HEIGHT)
                make.height.equalTo(self.ITEM_HOUR_HEIGHT * scheduleItem.heightMultiplier!)
                make.left.equalTo(columnView)
                make.right.equalTo(columnView)
            })
            
            itemIndex++;
        }
        
    }
    
    func updateValues () {
        
        var columnTitles = DateUtil.sortedDayAbbreviations()
        var index = 0
        for columnView in columnViews {
            columnView.setTitle(columnTitles[index++])
        }
    }
    
    // UIScrollViewDelegate
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let kMaxIndex : CGFloat  = 7
        
        let targetX : CGFloat = scrollView.contentOffset.x + velocity.x * 60.0
        var targetIndex : CGFloat = round(targetX / COLUMN_SIZE)
        if (targetIndex < 0) {
            targetIndex = 0
        }
        if (targetIndex > kMaxIndex) {
            targetIndex = kMaxIndex;
        }
        
        targetContentOffset.memory.x = targetIndex * (self.COLUMN_SIZE)
    }
    
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//        
//        let maxOffset : Float = Float(COLUMN_SIZE * 4.0)
//        var ratio : Float = 0.0
//        
//        if (scrollView.contentOffset.x != 0) {
//            ratio = Float(scrollView.contentOffset.x) / maxOffset
//        }
//        
//    }
    
    
    //MARK: Helper functions directly related to this view controller
    
    func scheduleItemViewOverlapsInColumn(itemView: ScheduleItemView, columnView:ScheduleColumnView) -> Bool {
        
        var scheduleItemViewsInColumn: [ScheduleItemView] = []
        for view in columnView.subviews {
            if view.isKindOfClass(ScheduleItemView) {
                scheduleItemViewsInColumn.append(view as! ScheduleItemView)
            }
        }

        let intersectingViews = scheduleItemViewsInColumn.filter { $0 != itemView && itemView.frame.intersects($0.frame) }
        return intersectingViews.count > 0
    }
    
    
}

//MARK: Helper class for managing and parsing schedules

class ScheduleHelper {
        
    static func getAgendaItems(spot: ParkingSpot) -> [AgendaItem] {
        
        var agendaItems = [AgendaItem]()
        var dayIndexes = Set<Int>()

        var scheduleItems = getScheduleItems(spot)
        scheduleItems = processScheduleItems(scheduleItems)
        
        //convert schedule items into agenda items
        for scheduleItem in scheduleItems {
            let agendaItem = AgendaItem(startTime: NSTimeInterval(scheduleItem.startInterval), endTime: NSTimeInterval(scheduleItem.endInterval), dayIndex: scheduleItem.columnIndex!, timeLimit: Int(scheduleItem.limit), rule: scheduleItem.rule)
            agendaItems.append(agendaItem)
            dayIndexes.insert(scheduleItem.columnIndex!)

        }
        
        let notPresentDayIndexes = Set(0...6).subtract(dayIndexes)
        for dayIndex in notPresentDayIndexes {
            let agendaItem = AgendaItem(startTime: 0, endTime: 24*3600, dayIndex: dayIndex, timeLimit: 0, rule: ParkingRule(ruleType: .Free))
            agendaItems.append(agendaItem)
        }
        
        agendaItems.sortInPlace { (first, second) -> Bool in
            if first.dayIndex == second.dayIndex {
                return first.startTime < second.startTime
            } else {
                return first.dayIndex < second.dayIndex
            }
        }
        
        return agendaItems
    }

    static func getScheduleItems(spot: ParkingSpot) -> [ScheduleItemModel] {

        var scheduleItems = [ScheduleItemModel]()
        let agenda = spot.sortedTimePeriods()
        for dayAgenda in agenda {
            
            var column : Int = 0
            for period in dayAgenda.timePeriods {
                
                if (period != nil) {
                    let startF : CGFloat = CGFloat(period!.start)
                    let endF : CGFloat = CGFloat(period!.end)
                    let scheduleItem = ScheduleItemModel(startF: startF, endF: endF, column : column, limitInterval: period!.timeLimit, rule: dayAgenda.rule)
                    scheduleItems.append(scheduleItem)
                }
                ++column
            }
        }
        
        //the sorted time periods above are not enough to created a sorted schedule items list
        scheduleItems.sortInPlace { (left, right) -> Bool in
            if left.columnIndex == right.columnIndex {
                if left.startInterval == right.startInterval {
                    return ParkingSpot.parkingRulesSorter(left.rule, right.rule)
                } else {
                    return left.startInterval < right.startInterval
                }
            }
            return left.columnIndex < right.columnIndex
        }
        
        return scheduleItems
    }
    
    static func processScheduleItems(scheduleItems: [ScheduleItemModel]) -> [ScheduleItemModel] {
        var newScheduleItems = [ScheduleItemModel]()
        
        for i in 0...6 {
            let tempScheduleItems = scheduleItems.filter({ (scheduleItem: ScheduleItemModel) -> Bool in
                return scheduleItem.columnIndex! == i && !scheduleItem.shouldNotProcess
            }).sort({ (left: ScheduleItemModel, right: ScheduleItemModel) -> Bool in
                left.columnIndex! <= right.columnIndex!
                    && left.startInterval <= right.startInterval
                    && left.endInterval <= right.endInterval
                    && left.limit <= right.limit
            })
            
            for scheduleItem in tempScheduleItems {
                let lastScheduleItem = newScheduleItems.last
                
                //this loop is to see if this is the only item, potentially on other days of the week, in the schedule.
                //we can then deduce that it's safe to alter it and make it taller without messing with other items.
                var allScheduleItemsEqual = true
                for item in scheduleItems {
                    if item.startInterval != scheduleItem.startInterval
                        || item.endInterval != scheduleItem.endInterval
                        || item.limit != scheduleItem.limit
                        || item.rule.ruleType != scheduleItem.rule.ruleType {
                            allScheduleItemsEqual = false
                    }

                }

                //RULE: IF ONLY RESTRICTION, MAKE IT TALLER!
                if tempScheduleItems.count == 1 && allScheduleItemsEqual {
                    scheduleItem.setMinimumHeight()
                    newScheduleItems.append(scheduleItem)
                }
                    //RULE: MERGE CONSECUTIVE EQUAL RULES
                else if (lastScheduleItem != nil
                    && lastScheduleItem!.columnIndex! == scheduleItem.columnIndex!
                    && lastScheduleItem!.endInterval >= scheduleItem.startInterval
                    && lastScheduleItem!.limit == scheduleItem.limit
                    && lastScheduleItem!.rule.ruleType == scheduleItem.rule.ruleType) {
                        newScheduleItems.removeLast()
                        let newScheduleItem = ScheduleItemModel(startF: lastScheduleItem!.startInterval, endF: scheduleItem.endInterval, column : scheduleItem.columnIndex!, limitInterval: scheduleItem.limit, rule: scheduleItem.rule)
                        newScheduleItems.append(newScheduleItem)
                }
                    //RULE: SPLIT (TIME MAXES OR PAID) IF A RESTRICTION OVERLAPS IT
                else if (lastScheduleItem != nil
                    && lastScheduleItem!.columnIndex! == scheduleItem.columnIndex!
                    && lastScheduleItem!.startInterval < scheduleItem.endInterval
                    && lastScheduleItem!.endInterval > scheduleItem.startInterval
                    && lastScheduleItem!.rule.ruleType != scheduleItem.rule.ruleType) {
                        //now just determine which is the restriction and which is the time max
                        var restriction: ScheduleItemModel = ScheduleItemModel()
                        var timeMax: ScheduleItemModel = ScheduleItemModel()
                        
                        if lastScheduleItem!.rule.ruleType != .Restriction { //then this is the time max or paid
                            restriction = scheduleItem
                            timeMax = lastScheduleItem!
                            newScheduleItems.removeLast()
                            newScheduleItems.append(restriction)
                        } else {
                            restriction = lastScheduleItem!
                            timeMax = scheduleItem
                        }
                        
                        if timeMax.isLongerThan(restriction) {
                            
                            //now split the time max...
                            if timeMax.startInterval >= restriction.startInterval {
                                //then just make our time max start after
                                timeMax = ScheduleItemModel(startF: restriction.endInterval, endF: timeMax.endInterval, column: timeMax.columnIndex!, limitInterval: timeMax.limit, rule: timeMax.rule)
                                newScheduleItems.append(timeMax)
                            } else if restriction.startInterval > timeMax.startInterval
                                && restriction.endInterval < timeMax.endInterval {
                                    //we have a total overlap, make 2 new time maxes
                                    let timeMax1 = ScheduleItemModel(startF: timeMax.startInterval, endF: restriction.startInterval, column: timeMax.columnIndex!, limitInterval: timeMax.limit, rule: timeMax.rule)
                                    let timeMax2 = ScheduleItemModel(startF: restriction.endInterval, endF: timeMax.endInterval, column: timeMax.columnIndex!, limitInterval: timeMax.limit, rule: timeMax.rule)
                                    newScheduleItems.append(timeMax1)
                                    newScheduleItems.append(timeMax2)
                            } else if restriction.endInterval >= timeMax.endInterval {
                                timeMax = ScheduleItemModel(startF: timeMax.startInterval, endF: restriction.startInterval, column: timeMax.columnIndex!, limitInterval: timeMax.limit, rule: timeMax.rule)
                                newScheduleItems.append(timeMax)
                            }
                            
                        }
                }
                else {
                    newScheduleItems.append(scheduleItem)
                }
                
            }
        }
        
        //in the first steps we removed the snow restrictions, now let's add them back, un-processed!
        newScheduleItems += scheduleItems.filter({ (scheduleItem: ScheduleItemModel) -> Bool in
            return scheduleItem.shouldNotProcess
        })
        
        return newScheduleItems
    }
    
}

class ScheduleItemModel {
    
    var startInterval: CGFloat
    var endInterval: CGFloat
    var limit: NSTimeInterval
    
    var heightMultiplier: CGFloat?
    var yIndexMultiplier: CGFloat?
    
    var columnIndex: Int?
    
    var timeLimitText: String?
    
    var rule: ParkingRule
    
    var shouldNotProcess: Bool {
        return self.rule.ruleType == ParkingRuleType.SnowRestriction
    }
    
    init () {
        startInterval = 0
        endInterval = 0
        limit = 0
        rule = ParkingRule(ruleType: ParkingRuleType.Free)
    }
    
    init (startF : CGFloat, endF : CGFloat, column : Int, limitInterval: NSTimeInterval, rule: ParkingRule) {
        
        self.rule = rule
        startInterval = startF
        endInterval = endF
        limit = limitInterval
        columnIndex = column
        
        heightMultiplier = (endF - startF) / 3600
        yIndexMultiplier = startF / 3600
        
        if (limit > 0) {
            let limitMinutes  = Int(limit / 60)
            timeLimitText =  String(NSString(format: "%01ld",limitMinutes))
        }
    }
    
    func setMinimumHeight() {
        
        if heightMultiplier < 4
        && ((startInterval / 3600) > 20
            || (endInterval / 3600) > 20) {
                return
//                    enable the lines below if we ever fix the labels displaying correctly
//                yIndexMultiplier = (endInterval / 3600) - 4
//                heightMultiplier = 4
        }
        
        if heightMultiplier < 4 {
                heightMultiplier = 4
        }

    }
    
    func isLongerThan(otherScheduleItem: ScheduleItemModel) -> Bool {
        let myInterval = endInterval - startInterval
        let otherInterval = otherScheduleItem.endInterval - otherScheduleItem.startInterval
        
        return myInterval > otherInterval
    }
    
    func topOffset() -> CGFloat {
        let maxInterval: CGFloat = 24
        let interval = startInterval / 3600
        let offset = interval/maxInterval
        return offset
    }
    
    func bottomOffset() -> CGFloat {
        let maxInterval: CGFloat = 24
        let interval = endInterval / 3600
        let offset = interval/maxInterval
        return offset
    }
    
    private func offset() -> CGFloat {
        return 0
    }
    
    /*
    ---(May be useful in the future)---
    We are going to manipulate the data here to draw things in 6 hour periods.
    There are only 4 slots:
    0  to 6  = 0     to 21600
    6  to 12 = 21600 to 43200
    12 to 18 = 43200 to 64800
    18 to 24 = 64800 to 86400
    */
    let SIX_HOUR_BLOCK: CGFloat = 6*60*60

    private func correctStartTimeToSixHourBlock(startF : CGFloat) -> CGFloat {
        
        var correctedStart: CGFloat = startF

        if startF < SIX_HOUR_BLOCK {
            correctedStart = 0
        } else if startF < SIX_HOUR_BLOCK*2 {
            correctedStart = SIX_HOUR_BLOCK
        } else if startF < SIX_HOUR_BLOCK*3 {
            correctedStart = SIX_HOUR_BLOCK*2
        } else if startF < SIX_HOUR_BLOCK*4 {
            correctedStart = SIX_HOUR_BLOCK*3
        }
        
        return correctedStart

    }

    private func correctEndTimeToSixHourBlock(endF : CGFloat) -> CGFloat {
        
        var correctedEnd: CGFloat = endF

        if endF <= SIX_HOUR_BLOCK {
            correctedEnd = SIX_HOUR_BLOCK
        } else if endF <= SIX_HOUR_BLOCK*2 {
            correctedEnd = SIX_HOUR_BLOCK*2
        } else if endF <= SIX_HOUR_BLOCK*3 {
            correctedEnd = SIX_HOUR_BLOCK*3
        } else if endF <= SIX_HOUR_BLOCK*4 {
            correctedEnd = SIX_HOUR_BLOCK*4
        }
        
        return correctedEnd
        
    }
    
}

class ScheduleTimeModel {
    
    var timeInterval: NSTimeInterval
    var heightOffsetInHours : CGFloat
    var yIndexMultiplier : CGFloat { get { return CGFloat(timeInterval / 3600) } }
    
    init(interval: NSTimeInterval, heightOff: CGFloat) {
        timeInterval = interval
        self.heightOffsetInHours = heightOff
    }

    init(interval: CGFloat, heightOff: CGFloat) {
        timeInterval = NSTimeInterval(interval)
        self.heightOffsetInHours = heightOff
    }

    static func getScheduleTimesFromItems(scheduleItems: [ScheduleItemModel]) -> [ScheduleTimeModel] {
        //maintain a list of the start and end values
        var allTimeValues = Set<CGFloat>()
        var startTimeValues = [CGFloat]()
        var endTimeValues = [CGFloat]()
        var endTimeHeightMultipliers = [CGFloat]()

        for scheduleItem in scheduleItems {
            allTimeValues.insert(scheduleItem.startInterval)
            allTimeValues.insert(scheduleItem.endInterval)
            startTimeValues.append(scheduleItem.startInterval)
            endTimeValues.append(scheduleItem.endInterval)
            endTimeHeightMultipliers.append(scheduleItem.heightMultiplier!)
        }
        
        return Array(allTimeValues).map { (interval: CGFloat) -> ScheduleTimeModel in
            if let index = endTimeValues.indexOf(interval) {
                let heightOffsetInHours = endTimeHeightMultipliers[index] - ((endTimeValues[index] - startTimeValues[index]) / 3600)
                return ScheduleTimeModel(interval: interval, heightOff: heightOffsetInHours)
            }
            return ScheduleTimeModel(interval: interval, heightOff: 0)
        }
    }

}
