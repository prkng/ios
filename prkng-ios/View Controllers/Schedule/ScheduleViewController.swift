//
//  ScheduleViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 02/04/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class ScheduleViewController: AbstractViewController, UIScrollViewDelegate, PRKVerticalGestureRecognizerDelegate, ModalHeaderViewDelegate {
    
    var spot : ParkingSpot
    var delegate : ScheduleViewControllerDelegate?
    private var scheduleItems : Array<ScheduleItemModel>
    private var parentView: UIView

    private var headerView : ModalHeaderView
    private var scrollView : UIScrollView
    private var contentView : UIView
    private var leftView : ScheduleLeftView
    private var columnViews : Array<ScheduleColumnView>
    private var scheduleItemViews : Array<ScheduleItemView>
    
    private var verticalRec: PRKVerticalGestureRecognizer

    private(set) var HEADER_HEIGHT : CGFloat = Styles.Sizes.modalViewHeaderHeight
    private(set) var LEFT_VIEW_WIDTH : CGFloat
    private(set) var COLUMN_SIZE : CGFloat
    private(set) var COLUMN_HEADER_HEIGHT : CGFloat
    private(set) var CONTENTVIEW_HEIGHT : CGFloat
    private(set) var ITEM_HOUR_HEIGHT : CGFloat
    
    init(spot: ParkingSpot, view: UIView) {
        self.spot = spot
        self.parentView = view
        headerView = ModalHeaderView()
        scrollView = UIScrollView()
        contentView = UIView()
        leftView = ScheduleLeftView()
        scheduleItems = []
        columnViews = []
        scheduleItemViews = []
        verticalRec = PRKVerticalGestureRecognizer()
        
        LEFT_VIEW_WIDTH = UIScreen.mainScreen().bounds.size.width * 0.18
        COLUMN_SIZE = UIScreen.mainScreen().bounds.size.width * 0.28
        CONTENTVIEW_HEIGHT = UIScreen.mainScreen().bounds.size.height - HEADER_HEIGHT - 71.0
        COLUMN_HEADER_HEIGHT = 45.0
        ITEM_HOUR_HEIGHT = (CONTENTVIEW_HEIGHT - COLUMN_HEADER_HEIGHT) / 24.0
        
        super.init(nibName: nil, bundle: nil)
        
        scheduleItems = ScheduleHelper.getScheduleItems(spot)
        scheduleItems = ScheduleHelper.processScheduleItems(scheduleItems)
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
        self.screenName = "Schedule (Agenda) View"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateValues()
    }
    
    override func viewWillLayoutSubviews() {
        
        // forbidden views should be on top
        for column in columnViews {
            for view in column.subviews {
                if let subview =  view as? ScheduleItemView {
                    if(!subview.limited) {
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
        
        var scheduleTimes = ScheduleTimeModel.getScheduleTimesFromItems(scheduleItems)
        leftView = ScheduleLeftView(model: scheduleTimes)
        leftView.backgroundColor = Styles.Colors.cream2
        self.view.addSubview(leftView)

        self.view.addSubview(headerView)
        headerView.delegate = self
        headerView.layer.shadowColor = UIColor.blackColor().CGColor
        headerView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        headerView.layer.shadowOpacity = 0.2
        headerView.layer.shadowRadius = 0.5
        
        verticalRec = PRKVerticalGestureRecognizer(view: self.view, superViewOfView: self.parentView)
        verticalRec.delegate = self
        
        scrollView.addSubview(contentView)
        
        for i in 0...6 {
            var columnView : ScheduleColumnView = ScheduleColumnView()
            contentView.addSubview(columnView)
            columnViews.append(columnView)
            columnView.setActive(false)
        }
        
        columnViews[0].setActive(true)
        
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

        leftView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.headerView.snp_bottom)
            make.left.equalTo(self.view)
            make.bottom.equalTo(self.view)
            make.width.equalTo(self.LEFT_VIEW_WIDTH)
        }
        
        for label in leftView.timeLabels {
            label.snp_makeConstraints({ (make) -> () in
                make.left.equalTo(self.leftView)
                make.right.equalTo(self.leftView).with.offset(-7)
                make.centerY.equalTo(self.leftView.snp_top).with.offset((self.ITEM_HOUR_HEIGHT * label.scheduleTimeModel!.yIndexMultiplier) + (label.scheduleTimeModel!.heightOffsetInHours * self.ITEM_HOUR_HEIGHT) + self.COLUMN_HEADER_HEIGHT)
                make.top.greaterThanOrEqualTo(self.leftView)
                make.bottom.lessThanOrEqualTo(self.leftView)
            })
        }

        
        scrollView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.headerView.snp_bottom)
            make.left.equalTo(self.view).with.offset(self.LEFT_VIEW_WIDTH)
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
            
            itemView.snp_makeConstraints({ (make) -> () in
                make.top.equalTo(columnView).with.offset((self.ITEM_HOUR_HEIGHT * scheduleItem.yIndexMultiplier!) + self.COLUMN_HEADER_HEIGHT)
                make.height.equalTo(self.ITEM_HOUR_HEIGHT * scheduleItem.heightMultiplier!)
                make.left.equalTo(columnView)
                make.right.equalTo(columnView)
            })
            
            itemIndex++;
        }
        
    }
    
    func updateValues () {
        headerView.titleLabel.text = spot.name
        
        var columnTitles = ScheduleHelper.sortedDayAbbreviations()
        var index = 0
        for columnView in columnViews {
            columnView.setTitle(columnTitles[index++])
        }
    }
    
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
        
        targetContentOffset.memory.x = targetIndex * (self.COLUMN_SIZE)
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        var maxOffset : Float = Float(COLUMN_SIZE * 4.0)
        var ratio : Float = 0.0
        
        if (scrollView.contentOffset.x != 0) {
            ratio = Float(scrollView.contentOffset.x) / maxOffset
        }
        
    }
    
    func dismiss () {
        self.delegate!.hideScheduleView()
    }
    
    
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
    
    
    //MARK: PRKVerticalGestureRecognizerDelegate methods
    func swipeDidBegin() {
        
    }
    
    func swipeInProgress(yDistanceFromBeginTap: CGFloat) {
        self.delegate?.shouldAdjustTopConstraintWithOffset(-yDistanceFromBeginTap, animated: false)
    }
    
    func swipeDidEndUp() {
        self.delegate?.shouldAdjustTopConstraintWithOffset(0, animated: true)
    }
    
    func swipeDidEndDown() {
        self.delegate!.hideScheduleView()
    }
    
    
    //MARK: ModalHeaderViewDelegate
    
    func tappedBackButton() {
        self.delegate!.hideScheduleView()
    }
    
    func tappedRightButton() {
        NSLog("Handle the right button tap")
    }

}

//MARK: Helper class for managing and parsing schedules

class ScheduleHelper {
    
    static func sortedDays() -> Array<String> {
        var array : Array<String> = []
        
        var days : Array<String> = []
        
        days.append("monday".localizedString)
        days.append("tuesday".localizedString)
        days.append("wednesday".localizedString)
        days.append("thursday".localizedString)
        days.append("friday".localizedString)
        days.append("saturday".localizedString)
        days.append("sunday".localizedString)
        
        let today = DateUtil.dayIndexOfTheWeek()
        
        for var i = today; i < 7; ++i {
            array.append(days[i])
        }
        
        for var j = 0; j < today; ++j {
            array.append(days[j])
        }
        
        array[0] = "today".localizedString
        array[1] = "tomorrow".localizedString

        return array
    }
    
    static func sortedDayAbbreviations() -> Array<String> {
        var array : Array<String> = []
        
        var days : Array<String> = []
        
        days.append("monday".localizedString.uppercaseString[0...2])
        days.append("tuesday".localizedString.uppercaseString[0...2])
        days.append("wednesday".localizedString.uppercaseString[0...2])
        days.append("thursday".localizedString.uppercaseString[0...2])
        days.append("friday".localizedString.uppercaseString[0...2])
        days.append("saturday".localizedString.uppercaseString[0...2])
        days.append("sunday".localizedString.uppercaseString[0...2])
        
        let today = DateUtil.dayIndexOfTheWeek()
        
        for var i = today; i < 7; ++i {
            array.append(days[i])
        }
        
        for var j = 0; j < today; ++j {
            array.append(days[j])
        }
        
        array[0] = "this_day".localizedString.uppercaseString
        
        return array
    }
    
    static func getAgendaItems(spot: ParkingSpot) -> [AgendaItem] {
        
        var agendaItems = [AgendaItem]()
        var dayIndexes = Set<Int>()
        let agenda = spot.sortedTimePeriods()
        for dayAgenda in agenda {
            
            var dayIndex : Int = 0
            for period in dayAgenda {
                
                if (period != nil) {
                    var agendaItem = AgendaItem(startTime: period!.start, endTime: period!.end, dayIndex: dayIndex, timeLimit: Int(period!.timeLimit))
                    agendaItems.append(agendaItem)
                    dayIndexes.insert(dayIndex)
                }
                ++dayIndex
            }
        }
        
        let notPresentDayIndexes = Set(0...6).subtract(dayIndexes)
        for dayIndex in notPresentDayIndexes {
            let agendaItem = AgendaItem(startTime: 0, endTime: 24*3600, dayIndex: dayIndex, timeLimit: 0)
            agendaItems.append(agendaItem)
        }
        
        agendaItems.sort { (first, second) -> Bool in
            first.dayIndex < second.dayIndex
        }
        
        return agendaItems
    }

    static func getScheduleItems(spot: ParkingSpot) -> [ScheduleItemModel] {

        var scheduleItems = [ScheduleItemModel]()
        let agenda = spot.sortedTimePeriods()
        for dayAgenda in agenda {
            
            var column : Int = 0
            for period in dayAgenda {
                
                if (period != nil) {
                    var startF : CGFloat = CGFloat(period!.start)
                    var endF : CGFloat = CGFloat(period!.end)
                    var scheduleItem = ScheduleItemModel(startF: startF, endF: endF, column : column, limitInterval: period!.timeLimit)
                    scheduleItems.append(scheduleItem)
                }
                ++column
            }
        }
        
        return scheduleItems
    }
    
    static func processScheduleItems(scheduleItems: [ScheduleItemModel]) -> [ScheduleItemModel] {
        var newScheduleItems = [ScheduleItemModel]()
        
        for i in 0...6 {
            var tempScheduleItems = scheduleItems.filter({ (var scheduleItem: ScheduleItemModel) -> Bool in
                return scheduleItem.columnIndex! == i
            }).sorted({ (var left: ScheduleItemModel, var right: ScheduleItemModel) -> Bool in
                left.columnIndex! <= right.columnIndex!
                    && left.startInterval <= right.startInterval
                    && left.endInterval <= right.endInterval
                    && left.limit <= right.limit
            })
            
            for scheduleItem in tempScheduleItems {
                var lastScheduleItem = newScheduleItems.last
                
                //RULE: IF ONLY RESTRICTION, MAKE IT TALLER!
                if tempScheduleItems.count == 1 {
                    scheduleItem.setMinimumHeight()
                    newScheduleItems.append(scheduleItem)
                }
                    //RULE: MERGE CONSECUTIVE EQUAL RULES
                else if (lastScheduleItem != nil
                    && lastScheduleItem!.columnIndex! == scheduleItem.columnIndex!
                    && lastScheduleItem!.endInterval >= scheduleItem.startInterval
                    && lastScheduleItem!.limit == scheduleItem.limit) {
                        newScheduleItems.removeLast()
                        var newScheduleItem = ScheduleItemModel(startF: lastScheduleItem!.startInterval, endF: scheduleItem.endInterval, column : scheduleItem.columnIndex!, limitInterval: scheduleItem.limit)
                        newScheduleItems.append(newScheduleItem)
                }
                    //RULE: SPLIT TIME MAXES IF A RESTRICTION OVERLAPS IT
                else if (lastScheduleItem != nil
                    && lastScheduleItem!.columnIndex! == scheduleItem.columnIndex!
                    && lastScheduleItem!.startInterval < scheduleItem.endInterval
                    && lastScheduleItem!.endInterval > scheduleItem.startInterval
                    && lastScheduleItem!.limit != scheduleItem.limit) {
                        //now just determine which is the restriction and which is the time max
                        var restriction: ScheduleItemModel = ScheduleItemModel()
                        var timeMax: ScheduleItemModel = ScheduleItemModel()
                        
                        if lastScheduleItem!.limit > 0 { //then this is the time mac
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
                                timeMax = ScheduleItemModel(startF: restriction.endInterval, endF: timeMax.endInterval, column: timeMax.columnIndex!, limitInterval: timeMax.limit)
                                newScheduleItems.append(timeMax)
                            } else if restriction.startInterval > timeMax.startInterval
                                && restriction.endInterval < timeMax.endInterval {
                                    //we have a total overlap, make 2 new time maxes
                                    var timeMax1 = ScheduleItemModel(startF: timeMax.startInterval, endF: restriction.startInterval, column: timeMax.columnIndex!, limitInterval: timeMax.limit)
                                    var timeMax2 = ScheduleItemModel(startF: restriction.endInterval, endF: timeMax.endInterval, column: timeMax.columnIndex!, limitInterval: timeMax.limit)
                                    newScheduleItems.append(timeMax1)
                                    newScheduleItems.append(timeMax2)
                            } else if restriction.endInterval >= timeMax.endInterval {
                                timeMax = ScheduleItemModel(startF: timeMax.startInterval, endF: restriction.startInterval, column: timeMax.columnIndex!, limitInterval: timeMax.limit)
                                newScheduleItems.append(timeMax)
                            }
                            
                        }
                }
                else {
                    newScheduleItems.append(scheduleItem)
                }
                
            }
        }
        
        return newScheduleItems
    }
    
}

class ScheduleItemModel {
    
    var startInterval: CGFloat
    var endInterval: CGFloat
    var limit: NSTimeInterval
    
    var heightMultiplier : CGFloat?
    var yIndexMultiplier : CGFloat?
    
    var columnIndex : Int?
    
    var timeLimitText : String?
    
    init () {
        startInterval = 0
        endInterval = 0
        limit = 0
    }
    
    init (startF : CGFloat, endF : CGFloat, column : Int, limitInterval: NSTimeInterval) {
        
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
        var offset = interval/maxInterval
        return offset
    }
    
    func bottomOffset() -> CGFloat {
        let maxInterval: CGFloat = 24
        let interval = endInterval / 3600
        var offset = interval/maxInterval
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
        
        return Array(allTimeValues).map { (var interval: CGFloat) -> ScheduleTimeModel in
            if let index = find(endTimeValues, interval) {
                let heightOffsetInHours = endTimeHeightMultipliers[index] - ((endTimeValues[index] - startTimeValues[index]) / 3600)
                return ScheduleTimeModel(interval: interval, heightOff: heightOffsetInHours)
            }
            return ScheduleTimeModel(interval: interval, heightOff: 0)
        }
    }

}

protocol ScheduleViewControllerDelegate {
    func hideScheduleView()
    func shouldAdjustTopConstraintWithOffset(distanceFromTop: CGFloat, animated: Bool)
}

