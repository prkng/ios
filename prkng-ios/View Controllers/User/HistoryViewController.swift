//
//  HistoryViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 10/06/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class HistoryViewController: AbstractViewController, UITableViewDataSource, UITableViewDelegate {
    
    let iconView = UIImageView(image: UIImage(named: "icon_history"))
    let titleLabel = UILabel()
    let tableView = UITableView()
    let backButton = UIButton()
    
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
        
        view.backgroundColor = Styles.Colors.midnight2
        
        view.addSubview(iconView)
        
        titleLabel.font = Styles.FontFaces.light(29)
        titleLabel.textColor = Styles.Colors.cream1
        titleLabel.textAlignment = .Center
        titleLabel.text = "history".localizedString
        view.addSubview(titleLabel)
        
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = .None
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
        
    }
    
    
    func setupConstraints() {
        
        iconView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.view).with.offset(48)
            make.centerX.equalTo(self.view)
            make.size.equalTo(CGSizeMake(68, 68))
        }
        
        titleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.iconView.snp_bottom).with.offset(12)
            make.height.equalTo(34)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
        }
        
        tableView.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.titleLabel.snp_bottom).with.offset(23)
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
        formatter.dateFormat = "EEEE, dd - hh:mm a"
        
        
        cell?.dateLabel.text = formatter.stringFromDate(checkin.date).uppercaseString
        cell?.addressLabel.text = checkin.name
        
        return cell!
    }
    
    
    //MARK: UITableViewDelegate
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let checkin = checkins![indexPath.row]
//        if settingsDelegate != nil {
//            settingsDelegate?.goToPreviousCheckin(checkin)
//        }
        
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
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
    
    
    //MARK: Button Handlers
    
    func backButtonTapped(sender: UIButton) {
        
    }
    
    
    //MARK: Helper
    
//    func addSuffixToNumber(number : Int){
//        
//        
//        var suffix : String
//        let ones = number % 10;
//        let tens = (number/10) % 10;
//        
//        if (tens ==1) {
//        suffix = "th";
//        } else if (ones ==1){
//        suffix = "st";
//        } else if (ones ==2){
//        suffix = "nd";
//        } else if (ones ==3){
//        suffix = "rd";
//        } else {
//        suffix = "th";
//        }
//        
//        NSString *completeAsString = [NSString stringWithFormat:@"%d%@",number,suffix];
//        return completeAsString;
//    }
    
    
    
}
