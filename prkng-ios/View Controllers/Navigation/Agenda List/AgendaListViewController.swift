//
//  AgendaListViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-07-07.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class AgendaListViewController: AbstractViewController, UITableViewDataSource, UITableViewDelegate, PRKVerticalGestureRecognizerDelegate {

    var spot : ParkingSpot
    var delegate : ScheduleViewControllerDelegate?
    private var agendaItems : Array<AgendaItem>
    private var parentView: UIView

    private var headerView : ScheduleHeaderView
    private var headerViewButton: UIButton
    private var tableView: UITableView
    
    private var verticalRec: PRKVerticalGestureRecognizer

    private(set) var HEADER_HEIGHT : CGFloat = Styles.Sizes.modalViewHeaderHeight

    init(spot: ParkingSpot, view: UIView) {
        self.spot = spot
        self.parentView = view
        agendaItems = []
        headerView = ScheduleHeaderView()
        headerViewButton = ViewFactory.checkInButton()
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
        tableView.backgroundColor = Styles.Colors.cream2
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        
        self.view.addSubview(headerView)
        headerView.layer.shadowColor = UIColor.blackColor().CGColor
        headerView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        headerView.layer.shadowOpacity = 0.2
        headerView.layer.shadowRadius = 0.5
        headerView.userInteractionEnabled = false
        
        self.view.addSubview(headerViewButton)
        headerViewButton.addTarget(self, action: "dismiss", forControlEvents: UIControlEvents.TouchUpInside)
        
        verticalRec = PRKVerticalGestureRecognizer(view: self.view, superViewOfView: self.parentView)
        verticalRec.delegate = self

        self.view.sendSubviewToBack(headerViewButton)

    }
    
    func setupConstraints() {
        
        headerView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.height.equalTo(self.HEADER_HEIGHT)
        }
        
        headerViewButton.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.headerView)
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
        
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? AgendaTableViewCell
        
        if cell == nil {
            cell = AgendaTableViewCell(agendaItem: agendaItems[indexPath.row], style: .Default, reuseIdentifier: identifier)
        }
        
        
        return cell!
    }
    
    
    //MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        //TODO: if 4
        return 60
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
}

class AgendaItem {
    
    enum AgendaItemState {
        case FREE
        case RESTRICTION
        case TIMEMAX
    }
    
    var startTime   : NSTimeInterval?
    var endTime     : NSTimeInterval?
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
        
        switch self.state() {
        case .FREE:
            let attrs = [NSFontAttributeName: firstPartFont]
            var attributedString = NSMutableAttributedString(string: "24 H", attributes: attrs)
            return attributedString
        
        case .TIMEMAX:
            let color = Styles.Colors.petrol1
            let fromTime = self.startTime!.toAttributedString(condensed: false, firstPartFont: firstPartFont, secondPartFont: secondPartFont)
            let toTime = self.endTime!.toAttributedString(condensed: false, firstPartFont: firstPartFont, secondPartFont: secondPartFont)
            
            var attributedString = NSMutableAttributedString(attributedString: fromTime)
            attributedString.appendAttributedString(NSAttributedString(string: "\n"))
            attributedString.appendAttributedString(toTime)
            
            return attributedString
            
        case .RESTRICTION:
            let color = Styles.Colors.red2
            let fromTime = self.startTime!.toAttributedString(condensed: false, firstPartFont: firstPartFont, secondPartFont: secondPartFont)
            let toTime = self.endTime!.toAttributedString(condensed: false, firstPartFont: firstPartFont, secondPartFont: secondPartFont)
            
            var attributedString = NSMutableAttributedString(attributedString: fromTime)
            attributedString.appendAttributedString(NSAttributedString(string: "\n"))
            attributedString.appendAttributedString(toTime)
            
            return attributedString
        }

        return NSAttributedString(string: "")
    }
    
}

class AgendaTableViewCell: UITableViewCell {

    let colorView = UIView()
    let dayLabel = UILabel()
    var icon = UIImageView()
    let hoursText = UILabel()
    let seperator = UIView()
    
    var agendaItem: AgendaItem
    
    var didSetupSubviews : Bool = false
    var didSetupConstraints : Bool = true
    
    init(agendaItem: AgendaItem, style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.agendaItem = agendaItem
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        if (!didSetupSubviews) {
            setupSubviews()
            setNeedsUpdateConstraints()
        }
        super.layoutSubviews()
    }
    
    override func updateConstraints() {
        if (!didSetupConstraints) {
            setupConstraints()
        }
        super.updateConstraints()
    }
    
    func setupSubviews() {
        
        var hoursTextColor = Styles.Colors.petrol1
        
        if agendaItem.isToday() {
            self.backgroundColor = Styles.Colors.cream1
        } else {
            self.backgroundColor = Styles.Colors.stone
        }
        
        switch agendaItem.state() {
            
        case .FREE:
            colorView.backgroundColor = Styles.Colors.cream1
            icon = ViewFactory.authorizedIcon(Styles.Colors.petrol2)
            break
        case .RESTRICTION:
            hoursTextColor = Styles.Colors.red2
            colorView.backgroundColor = Styles.Colors.red2
            icon = ViewFactory.forbiddenIcon(Styles.Colors.red2)
            break
        case .TIMEMAX:
            colorView.backgroundColor = Styles.Colors.petrol2
            icon = ViewFactory.timeMaxIcon(agendaItem.timeLimit/60, addMaxLabel: false, color: Styles.Colors.petrol2)
            break
            
        }
        
        contentView.addSubview(colorView)
        
        dayLabel.font = Styles.Fonts.h3
        dayLabel.textColor = Styles.Colors.midnight1
        dayLabel.textAlignment = .Left
        dayLabel.text = agendaItem.dayText()
        contentView.addSubview(dayLabel)
        
        icon.contentMode = .ScaleAspectFit
        contentView.addSubview(icon)
        
        hoursText.font = Styles.FontFaces.light(14)
        hoursText.numberOfLines = 2
        hoursText.textColor = hoursTextColor
        hoursText.textAlignment = .Right
        hoursText.attributedText = agendaItem.timeText()
        contentView.addSubview(hoursText)
        
        seperator.backgroundColor = UIColor(white: 0, alpha: 0.05)
        seperator.layer.shadowColor = UIColor(white: 1.0, alpha: 1).CGColor
        seperator.layer.shadowOpacity = 0.05
        seperator.layer.shadowRadius = 1
        seperator.layer.shadowOffset = CGSize(width: 0, height: 1)
        contentView.addSubview(seperator)
        
        didSetupSubviews = true
        didSetupConstraints = false
    }
    
    func setupConstraints () {
        
        colorView.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.contentView)
            make.top.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView)
            make.width.equalTo(14)
        }
        
        dayLabel.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.colorView.snp_right).with.offset(14)
            make.centerY.equalTo(self.contentView)
        }
        
        icon.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.dayLabel.snp_right).with.offset(10)
            make.right.equalTo(self.contentView).with.offset(-114)
            make.centerY.equalTo(self.contentView)
            make.size.equalTo(CGSizeMake(25, 25))
        }
        
        hoursText.snp_makeConstraints { (make) -> () in
            make.left.lessThanOrEqualTo(self.icon.snp_right).with.offset(10)
            make.right.equalTo(self.contentView).with.offset(-40)
            make.centerY.equalTo(self.contentView)
        }
        
        seperator.snp_makeConstraints { (make) -> () in
            make.left.equalTo(self.contentView)
            make.right.equalTo(self.contentView)
            make.bottom.equalTo(self.contentView).with.offset(-1)
            make.height.equalTo(1)
        }
        
    }
    
    
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
