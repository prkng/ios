//
//  HistoryViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 10/06/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class HistoryViewController: AbstractViewController, UITableViewDataSource, UITableViewDelegate {
    
    let backgroundImageView = UIImageView(image: UIImage(named:"bg_blue_gradient"))
    
    let headerView = UIView()
    let headerImageView = UIImageView()
    let HEADER_MIN_HEIGHT : Float = 90
    let HEADER_MAX_HEIGHT : Float = floor(Float(UIScreen.mainScreen().bounds.size.height) * 0.44)
    var previousYPosition : Float = 90 - floor(Float(UIScreen.mainScreen().bounds.size.height) * 0.44)
    var currentHeaderHeight : Float = floor(Float(UIScreen.mainScreen().bounds.size.height) * 0.44)  // default same as HEADER_MAX_HEIGHT
    
    let iconView = UIImageView(image: UIImage(named: "icon_history"))
    let titleLabel = UILabel()
    let tableView = UITableView()
    let backButton = ViewFactory.hugeButton()
    
    var groupedCheckins : Dictionary<String, Array<Checkin>>?
    
    var settingsDelegate: SettingsViewControllerDelegate?
    
    override func loadView() {
        view = UIView()
        setupViews()
        setupConstraints()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        SpotOperations.getCheckins { (checkins) -> Void in
            
            self.groupedCheckins = Dictionary()
            if let ungroupedCheckins = checkins {
                
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
        tableView.contentInset = UIEdgeInsetsMake(CGFloat(HEADER_MAX_HEIGHT - HEADER_MIN_HEIGHT), 0, 0, 0);
        tableView.setContentOffset(CGPointMake(0, -tableView.contentInset.top), animated: false)
        
        
        tableView.separatorStyle = .None
        tableView.dataSource = self
        tableView.delegate = self
        tableView.clipsToBounds = true
        view.addSubview(tableView)
        
        view.addSubview(headerView)
        
        headerImageView.image = UIImage(named:"bg_blue_gradient")
        headerImageView.contentMode = .ScaleAspectFill
        headerView.addSubview(headerImageView)
        headerView.clipsToBounds = true
        headerView.addSubview(iconView)
        
        titleLabel.font = Styles.FontFaces.light(29)
        titleLabel.textColor = Styles.Colors.cream1
        titleLabel.textAlignment = .Center
        titleLabel.text = "history".localizedString
        headerView.addSubview(titleLabel)
        
        backButton.setTitle("back".localizedString, forState: .Normal)
        backButton.addTarget(self, action: "backButtonTapped:", forControlEvents: .TouchUpInside)
        view.addSubview(backButton)
        
    }
    
    
    func setupConstraints() {
        
        backgroundImageView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }
        
        headerImageView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.headerView)
            make.left.equalTo(self.headerView)
            make.right.equalTo(self.headerView)
            make.bottom.equalTo(self.view)
        }
        
        iconView.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.titleLabel.snp_top).with.offset(-12)
            make.centerX.equalTo(self.view)
            make.size.equalTo(CGSizeMake(68, 68))
        }
        
        titleLabel.snp_makeConstraints { (make) -> () in
            make.bottom.equalTo(self.headerView).multipliedBy(0.70)
            make.height.equalTo(34)
            make.left.equalTo(self.headerView)
            make.right.equalTo(self.headerView)
        }
        
        
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let screenHeight = UIScreen.mainScreen().bounds.size.height - CGFloat(Styles.Sizes.tabbarHeight)
        
        headerView.frame = CGRectMake(0, 0, screenWidth, CGFloat(HEADER_MAX_HEIGHT))
        
        let tableViewHeight = screenHeight - CGFloat(HEADER_MIN_HEIGHT) - CGFloat(Styles.Sizes.hugeButtonHeight)
        tableView.frame = CGRectMake(0, CGFloat(HEADER_MIN_HEIGHT), screenWidth, tableViewHeight)
        backButton.frame = CGRectMake(0, tableViewHeight + CGFloat(HEADER_MIN_HEIGHT), screenWidth, CGFloat(Styles.Sizes.hugeButtonHeight))
        
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
            
            let key = checkins.keys.array[section]
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
        
        let key = groupedCheckins!.keys.array[indexPath.section]
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let key = groupedCheckins!.keys.array[indexPath.section]
        let checkin = groupedCheckins![key]![indexPath.row]
        
        if settingsDelegate != nil {
            settingsDelegate?.goToCoordinate(checkin.location.coordinate, named:checkin.name) 
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = HistorySectionTitleView()
        sectionHeader.label.text = groupedCheckins!.keys.array[section].uppercaseString
        return sectionHeader
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let yPos = Float(scrollView.contentOffset.y)
        var height:Float = currentHeaderHeight
        let dy = previousYPosition - yPos
        
        println("dy : \(dy)")
        println("previousYPosition : \(previousYPosition)")
        println("yPos : \(yPos)")
        
        height += dy
        
        if (yPos > Float(scrollView.contentSize.height - scrollView.frame.size.height)){
            return
        }
        
        
        if (height > HEADER_MAX_HEIGHT) {
            height = HEADER_MAX_HEIGHT
        } else if (height < HEADER_MIN_HEIGHT) {
            height = HEADER_MIN_HEIGHT
        }
        
        println("header height : \(height)")
        println("contentInset top : \(scrollView.contentInset.top)")

        
        if (height == HEADER_MAX_HEIGHT) && (Float(scrollView.contentInset.top) + yPos <= 0.0) {
            return
        }

        if (height != Float(headerView.frame.size.height)) {
            
            var headerViewFrame : CGRect = self.headerView.frame
            headerViewFrame.size.height = CGFloat(height)
            headerView.frame = headerViewFrame
            
            tableView.delegate = nil
            tableView.contentInset = UIEdgeInsetsMake(CGFloat(height - HEADER_MIN_HEIGHT), 0, 0, 0)
            tableView.delegate = self
            
            currentHeaderHeight = height
            iconView.alpha = CGFloat(((height - HEADER_MIN_HEIGHT) / HEADER_MAX_HEIGHT))
            
            headerView.layoutIfNeeded()
        }
        
        previousYPosition = yPos

    }
    
    //MARK: Button Handlers
    
    func backButtonTapped(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
