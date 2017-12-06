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
    
    fileprivate static let VERTICAL_PADDING = 15
    fileprivate static let TOP_VIEW_PADDING = 30 + 24 + VERTICAL_PADDING //from top_layout_guide_bottom: 30 pts of space, 24 pts of segmented control, 15 pts padding
    

    override func loadView() {
        view = UIView()
        setupViews()
        setupConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenName = "User - History View"
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
                
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM yyyy"
                
                for checkin in ungroupedCheckins {
                    let group = formatter.string(from: checkin.date as Date)
                    
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
        
        backgroundImageView.contentMode = .scaleAspectFill
        view.addSubview(backgroundImageView)
        
        tableView.backgroundColor = UIColor.clear
        
        tableView.separatorStyle = .none
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        if groupedCheckins != nil {
            return groupedCheckins!.count
        }
        
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let checkins = groupedCheckins {
            
            let key = Array(checkins.keys)[section]
            if let array = checkins[key] {
                return array.count
            }
            
            
        }
        
        return 0
    }
    
    let identifier = "HistoryTableViewCell"
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? HistoryTableViewCell
        
        if cell == nil {
            cell = HistoryTableViewCell(style: .default, reuseIdentifier: identifier)
        }
        
        let key = Array(groupedCheckins!.keys)[indexPath.section]
        let checkin = groupedCheckins![key]![indexPath.row]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE - hh:mm a"
        cell?.dateLabel.text = formatter.string(from: checkin.date as Date).uppercased()
        
        formatter.dateFormat = "dd"
        cell?.dayLabel.text = formatter.string(from: checkin.date as Date)
        
        
        cell?.addressLabel.text = checkin.name
        
        return cell!
    }
    
    
    //MARK: UITableViewDelegate
    
    @available(iOS 8.0, *)
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteClosure = { (action: UITableViewRowAction, indexPath: IndexPath) -> Void in
            if let _ = self.tableView.cellForRow(at: indexPath as IndexPath) as? HistoryTableViewCell {
                let key = Array(self.groupedCheckins!.keys)[indexPath.section]
                let checkin = self.groupedCheckins![key]![indexPath.row]
                SpotOperations.hideCheckin(checkin.checkinId, completion: { (success) -> Void in
                    self.tableView.setEditing(false, animated: true)
                    self.loadCheckinHistory()
                })
            } else {
                self.tableView.setEditing(false, animated: true)
            }
        }
        let deleteAction = UITableViewRowAction(style: .destructive, title: "delete".localizedString, handler: deleteClosure)
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let key = Array(groupedCheckins!.keys)[indexPath.section]
        let checkin = groupedCheckins![key]![indexPath.row]
        let userInfo: [String: AnyObject] = ["location": checkin.location, "name": checkin.name as AnyObject]
        NotificationCenter.default.post(name: Notification.Name(rawValue: "goToCoordinate"), object: nil, userInfo: userInfo)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SECTION_HEADER_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = HistorySectionTitleView(
            frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: SECTION_HEADER_HEIGHT),
            labelText: Array(groupedCheckins!.keys)[section].uppercased())
        return sectionHeader
    }
    
    
    //MARK: Button Handlers
    
    func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
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
        
        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: totalHeight)
        
        headerView.clipsToBounds = true
        headerView.addSubview(iconView)
        
        titleLabel.font = Styles.Fonts.h1
        titleLabel.textColor = Styles.Colors.cream1
        titleLabel.textAlignment = .center
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
