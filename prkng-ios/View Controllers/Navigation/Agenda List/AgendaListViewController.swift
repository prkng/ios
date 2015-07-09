//
//  AgendaListViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-07-07.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class AgendaListViewController: AbstractViewController, UITableViewDataSource, UITableViewDelegate, PRKVerticalGestureRecognizerDelegate, ModalHeaderViewDelegate {

    var spot : ParkingSpot
    var delegate : ScheduleViewControllerDelegate?
    private var agendaItems : Array<AgendaItem>
    private var parentView: UIView

    private var headerView : ModalHeaderView
    private var tableView: UITableView
    
    private var verticalRec: PRKVerticalGestureRecognizer

    private(set) var HEADER_HEIGHT : CGFloat = Styles.Sizes.modalViewHeaderHeight

    init(spot: ParkingSpot, view: UIView) {
        self.spot = spot
        self.parentView = view
        agendaItems = []
        headerView = ModalHeaderView()
        tableView = UITableView()
        verticalRec = PRKVerticalGestureRecognizer()
        super.init(nibName: nil, bundle: nil)
        agendaItems = ScheduleHelper.getAgendaItems(spot)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenName = "Agenda List View"
    }

    override func loadView() {
        view = UIView()
        view.backgroundColor = Styles.Colors.stone
        setupViews()
        setupConstraints()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        updateValues()
    }
    
    func setupViews() {
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.backgroundColor = Styles.Colors.cream2
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        
        self.view.addSubview(headerView)
        headerView.delegate = self
        headerView.layer.shadowColor = UIColor.blackColor().CGColor
        headerView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        headerView.layer.shadowOpacity = 0.2
        headerView.layer.shadowRadius = 0.5
        
        verticalRec = PRKVerticalGestureRecognizer(view: self.view, superViewOfView: self.parentView)
        verticalRec.delegate = self

    }
    
    func setupConstraints() {
        
        headerView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(self.HEADER_HEIGHT)
        }
        
        tableView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.headerView.snp_bottom)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }


    }
    
    func updateValues () {
        headerView.titleLabel.text = spot.name
    }
    
    func dismiss () {
        self.delegate!.hideScheduleView()
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
    
    
    //MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return agendaItems.count
    }
    
    let identifier = "AgendaTableViewCell"
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let agendaItem = agendaItems[indexPath.row]
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? AgendaTableViewCell
        
        if cell == nil {
            cell = AgendaTableViewCell(agendaItem: agendaItem, style: .Default, reuseIdentifier: identifier)
        } else {
            cell?.setupSubviews(agendaItem)
        }
        
        return cell!
    }
    
    
    //MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let useableHeight = UIScreen.mainScreen().bounds.height - Styles.Sizes.modalViewHeaderHeight - CGFloat(Styles.Sizes.tabbarHeight)
        let height = useableHeight / 7 > 60 ? Int(useableHeight / 7) : 60
        return CGFloat(height)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    //MARK: ModalHeaderViewDelegate
    
    func tappedBackButton() {
        self.delegate!.hideScheduleView()
    }
    
    func tappedRightButton() {
        NSLog("Handle the right button tap")
    }
    
}

class AgendaItem {
    
    enum AgendaItemState {
        case FREE
        case RESTRICTION
        case TIMEMAX
    }
    
    var startTime   : NSTimeInterval
    var endTime     : NSTimeInterval
    var dayIndex    : Int   //0 means today, 1 means tomorrow, etc
    var timeLimit   : Int
    
    init(startTime: NSTimeInterval, endTime: NSTimeInterval, dayIndex: Int, timeLimit: Int) {
        self.startTime = startTime
        self.endTime = endTime
        self.dayIndex = dayIndex
        self.timeLimit = timeLimit
    }
    
    func state() -> AgendaItemState {
        
        if startTime == 0 && endTime == 3600 * 24 {
            return AgendaItemState.FREE
        }
        if timeLimit > 0 {
            return AgendaItemState.TIMEMAX
        } else {
            return AgendaItemState.RESTRICTION
        }

    }
    
    func isToday() -> Bool {
        return dayIndex == 0
    }
    
    func dayText() -> String {
        let days = ScheduleHelper.sortedDays()
        if dayIndex < days.count && dayIndex > -1 {
            return days[dayIndex]
        }
        return ""
    }
    
    func timeText() -> NSAttributedString {

        let firstPartFont = Styles.FontFaces.regular(14)
        let secondPartFont = Styles.FontFaces.light(14)
        
        if self.state() == .FREE {
            let attrs = [NSFontAttributeName: firstPartFont]
            var attributedString = NSMutableAttributedString(string: "24 H", attributes: attrs)
            return attributedString
        }

        let fromTime = self.startTime.toAttributedString(condensed: false, firstPartFont: firstPartFont, secondPartFont: secondPartFont)
        let toTime = self.endTime.toAttributedString(condensed: false, firstPartFont: firstPartFont, secondPartFont: secondPartFont)
        
        var attributedString = NSMutableAttributedString(attributedString: fromTime)
        attributedString.appendAttributedString(NSAttributedString(string: "\n"))
        attributedString.appendAttributedString(toTime)
        
        return attributedString
    }
    
}
