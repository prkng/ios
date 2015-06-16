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

    var checkins : Array<Checkin>?
    
    override func loadView() {
        view = UIView()
        setupViews()
        setupConstraints()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        

        SpotOperations.getCheckins { (checkins) -> Void in
            self.checkins = checkins
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
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let checkins = self.checkins {
            return checkins.count
        }
        
        return 0
    }

    let identifier = "HistoryTableViewCell"
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? HistoryTableViewCell
        
        if cell == nil {
            cell = HistoryTableViewCell(style: .Default, reuseIdentifier: identifier)
        }
        
        let checkin = checkins![indexPath.row]
        
        cell?.dateLabel.text = "date and stuff"
        cell?.addressLabel.text = checkin.name
        
        return cell!
    }
    
    
    //MARK: UITableViewDelegate
    
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    
    //MARK : Button Handlers
    
    func backButtonTapped(sender: UIButton) {
        
    }

   
}
