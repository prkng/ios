//
//  AgendaListViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-07-07.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class AgendaListViewController: PRKModalViewControllerChild, UITableViewDataSource, UITableViewDelegate {

    private var agendaItems : Array<AgendaItem>
    private var tableView: UITableView
    private(set) var HEADER_HEIGHT : CGFloat = Styles.Sizes.modalViewHeaderHeight

    override init(spot: ParkingSpot, view: UIView) {
        agendaItems = []
        tableView = UITableView()
        super.init(spot: spot, view: view)
        agendaItems = ScheduleHelper.getAgendaItems(spot, respectDoNotProcess: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
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
    }
    
    func setupViews() {
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.backgroundColor = Styles.Colors.cream2
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        
    }
    
    func setupConstraints() {
        
        tableView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view).offset(Styles.Sizes.modalViewHeaderHeight)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }


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
    
    
}

class AgendaItem {
    
    var startTime   : NSTimeInterval
    var endTime     : NSTimeInterval
    var dayIndex    : Int   //0 means today, 1 means tomorrow, etc
    var timeLimit   : Int
    var rule        : ParkingRule
    
    init(startTime: NSTimeInterval, endTime: NSTimeInterval, dayIndex: Int, timeLimit: Int, rule: ParkingRule) {
        self.startTime = startTime
        self.endTime = endTime
        self.dayIndex = dayIndex
        self.timeLimit = timeLimit
        self.rule = rule
    }
    
    func isToday() -> Bool {
        return dayIndex == 0
    }
    
    func dayText() -> String {
        let days = DateUtil.sortedDays()
        if dayIndex < days.count && dayIndex > -1 {
            return days[dayIndex]
        }
        return ""
    }
    
    func timeText() -> NSAttributedString {

        let firstPartFont = Styles.FontFaces.regular(14)
        let secondPartFont = Styles.FontFaces.light(14)
        
        if self.rule.ruleType == .Free {
            let attrs = [NSFontAttributeName: firstPartFont]
            let attributedString = NSMutableAttributedString(string: "24 H", attributes: attrs)
            return attributedString
        }

        let fromTime = self.startTime.toAttributedString(condensed: false, firstPartFont: firstPartFont, secondPartFont: secondPartFont)
        let toTime = self.endTime.toAttributedString(condensed: false, firstPartFont: firstPartFont, secondPartFont: secondPartFont)
        
        let attributedString = NSMutableAttributedString(attributedString: fromTime)
        attributedString.appendAttributedString(NSAttributedString(string: "\n"))
        attributedString.appendAttributedString(toTime)
        
        return attributedString
    }
    
}
