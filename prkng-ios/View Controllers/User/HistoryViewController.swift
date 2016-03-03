//
//  HistoryViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 10/06/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class HistoryViewController: AbstractViewController, UITableViewDataSource, UITableViewDelegate {
    
    let backgroundImageView = UIImageView(image: UIImage(named:"bg_mycar"))
    
    let tableView = UITableView()
    
    var groupedCheckins : Dictionary<String, Array<Checkin>>?
    
    let SECTION_HEADER_HEIGHT: CGFloat = 30
    
    private static let VERTICAL_PADDING = 15
    private static let TOP_VIEW_PADDING = 30 + 24 + VERTICAL_PADDING //from top_layout_guide_bottom: 30 pts of space, 24 pts of segmented control, 15 pts padding
    

    override func loadView() {
        view = UIView()
        setupViews()
        setupConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenName = "User - History View"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loadCheckinHistory()
    }
    
    func loadCheckinHistory() {

        SpotOperations.getCheckins { (checkins) -> Void in
            
            let shownCheckins = checkins?.filter({ (checkin) -> Bool in
                return checkin.hidden == false
            })
            
            self.groupedCheckins = Dictionary()
            if let ungroupedCheckins = shownCheckins {
                
                let formatter = NSDateFormatter()
                formatter.dateFormat = "MMM yyyy"
                
                for checkin in ungroupedCheckins {
                    let group = formatter.stringFromDate(checkin.date)
                    
                    if self.groupedCheckins![group] != nil {
                        self.groupedCheckins![group]!.append(checkin)
                    } else {
                        var array : Array<Checkin> = []
                        array.append(checkin)
                        self.groupedCheckins![group] = array
                    }
                    
                }
                
                
            }
            
            
            self.tableView.reloadData()
        }
    }
    
    func setupViews() {
        
        backgroundImageView.contentMode = .ScaleAspectFill
        view.addSubview(backgroundImageView)
        
        tableView.backgroundColor = UIColor.clearColor()
        
        tableView.separatorStyle = .None
        tableView.dataSource = self
        tableView.delegate = self
        tableView.clipsToBounds = true
        view.addSubview(tableView)
        
        tableView.tableHeaderView = headerView()
        
    }
    
    
    func setupConstraints() {
        
        backgroundImageView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }
        
        tableView.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.snp_topLayoutGuideBottom).offset(HistoryViewController.TOP_VIEW_PADDING)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
        
    }
    
    //MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if groupedCheckins != nil {
            return groupedCheckins!.count
        }
        
        
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let checkins = groupedCheckins {
            
            let key = Array(checkins.keys)[section]
            if let array = checkins[key] {
                return array.count
            }
            
            
        }
        
        return 0
    }
    
    let identifier = "HistoryTableViewCell"
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? HistoryTableViewCell
        
        if cell == nil {
            cell = HistoryTableViewCell(style: .Default, reuseIdentifier: identifier)
        }
        
        let key = Array(groupedCheckins!.keys)[indexPath.section]
        let checkin = groupedCheckins![key]![indexPath.row]
        
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEEE - hh:mm a"
        cell?.dateLabel.text = formatter.stringFromDate(checkin.date).uppercaseString
        
        formatter.dateFormat = "dd"
        cell?.dayLabel.text = formatter.stringFromDate(checkin.date)
        
        
        cell?.addressLabel.text = checkin.name
        
        return cell!
    }
    
    
    //MARK: UITableViewDelegate
    
    @available(iOS 8.0, *)
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "delete".localizedString, handler: { (action: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
            if let _ = self.tableView.cellForRowAtIndexPath(indexPath) as? HistoryTableViewCell {
                let key = Array(self.groupedCheckins!.keys)[indexPath.section]
                let checkin = self.groupedCheckins![key]![indexPath.row]
                SpotOperations.hideCheckin(checkin.checkinId, completion: { (success) -> Void in
                    self.tableView.setEditing(false, animated: true)
                    self.loadCheckinHistory()
                })
            } else {
                self.tableView.setEditing(false, animated: true)
            }
        })
        return [deleteAction]
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let key = Array(groupedCheckins!.keys)[indexPath.section]
        let checkin = groupedCheckins![key]![indexPath.row]
        let userInfo: [String: AnyObject] = ["location": checkin.location, "name": checkin.name]
        NSNotificationCenter.defaultCenter().postNotificationName("goToCoordinate", object: nil, userInfo: userInfo)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SECTION_HEADER_HEIGHT
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = HistorySectionTitleView(
            frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: SECTION_HEADER_HEIGHT),
            labelText: Array(groupedCheckins!.keys)[section].uppercaseString)
        return sectionHeader
    }
    
    
    //MARK: Button Handlers
    
    func backButtonTapped(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func headerView() -> UIView {
        
        let topPadding = 25
        let iconViewHeight = 68
        let titleLabelHeight = 34
        let titleLabelTopPadding = 12
        let totalHeight = topPadding+iconViewHeight+titleLabelTopPadding+titleLabelHeight+HistoryViewController.VERTICAL_PADDING
        
        let headerView = UIView()
        let iconView = UIImageView(image: UIImage(named: "icon_history"))
        let titleLabel = UILabel()
        
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.mainScreen().bounds.width), height: totalHeight)
        
        headerView.clipsToBounds = true
        headerView.addSubview(iconView)
        
        titleLabel.font = Styles.Fonts.h1
        titleLabel.textColor = Styles.Colors.cream1
        titleLabel.textAlignment = .Center
        titleLabel.text = "history".localizedString
        headerView.addSubview(titleLabel)
        
        iconView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(headerView).offset(topPadding)
            make.centerX.equalTo(headerView)
            make.size.equalTo(CGSize(width: iconViewHeight, height: iconViewHeight))
        }
        
        titleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(iconView.snp_bottom).offset(titleLabelTopPadding)
            make.height.equalTo(titleLabelHeight)
            make.left.equalTo(headerView)
            make.right.equalTo(headerView)
        }
        
        return headerView
    }
    
    
}
