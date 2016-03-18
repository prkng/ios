//
//  PPTransactionsViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2016-03-01.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class PPTransactionsViewController: AbstractViewController, UITableViewDataSource, UITableViewDelegate {
    
    private let backgroundImageView = UIImageView(image: UIImage(named:"bg_mycar"))
    
    private let tableView = UITableView()
    
    private var upcomingTransactions = [ParkingPandaTransaction]()
    private var pastTransactions = [ParkingPandaTransaction]()
    
    private var didGoToPPIntro = false
    private var reloadOnNextAppear = true
    
    private let ROW_HEIGHT: CGFloat = 70
    private let SECTION_HEADER_HEIGHT: CGFloat = 61
    
    private static let VERTICAL_PADDING = 15
    private static let TOP_VIEW_PADDING = 30 + 24 + VERTICAL_PADDING //from top_layout_guide_bottom: 30 pts of space, 24 pts of segmented control, 15 pts padding
    
    override func loadView() {
        view = UIView()
        setupViews()
        setupConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenName = "My Activity - Reservations View"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if reloadOnNextAppear {
            self.loadTransactions()
        }
        reloadOnNextAppear = true
    }
    
    func loadTransactions() {

        SVProgressHUD.setBackgroundColor(UIColor.clearColor())
        SVProgressHUD.show()

        ParkingPandaOperations.login(username: nil, password: nil) { (user, error) -> Void in
            if user != nil {
                ParkingPandaOperations.getTransactions(user!, forTime: ParkingPandaOperations.ParkingPandaTransactionTime.All, completion: { (transactions, error) -> Void in
                    let currentDate = NSDate()
                    self.pastTransactions = transactions.filter({ (transaction) -> Bool in
                        return transaction.endDateAndTime?.earlierDate(currentDate) == transaction.endDateAndTime
                    })
                    self.pastTransactions.sortInPlace({ (left, right) -> Bool in
                        return left.endDateAndTime?.earlierDate(right.endDateAndTime ?? currentDate) == right.endDateAndTime
                    })
                    self.upcomingTransactions = transactions.filter({ (transaction) -> Bool in
                        return transaction.endDateAndTime?.earlierDate(currentDate) == currentDate
                    })
                    self.upcomingTransactions.sortInPlace({ (left, right) -> Bool in
                        return left.endDateAndTime?.earlierDate(right.endDateAndTime ?? currentDate) == left.endDateAndTime
                    })
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        SVProgressHUD.dismiss()
                        self.tableView.reloadData()
                    })
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    SVProgressHUD.dismiss()
                    if let ppError = error {
                        switch (ppError.errorType) {
                        case .API, .Internal:
                            if !self.didGoToPPIntro {
                                ParkingPandaOperations.logout()
                                let ppIntroVC = PPIntroViewController()
                                ppIntroVC.presentWithVC(nil)
                                self.didGoToPPIntro = true
                            }
                        case .NoError, .Network:
                            break
                        }
                    }
                })
            }
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
            make.top.equalTo(self.snp_topLayoutGuideBottom).offset(PPTransactionsViewController.TOP_VIEW_PADDING)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
    }
    
    //MARK: UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return upcomingTransactions.count
        } else if section == 1 {
            return pastTransactions.count
        }
        return 0
    }
    
    let identifier = "PPTransactionTableViewCell"
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier) as? PPTransactionTableViewCell
        if cell == nil {
            cell = PPTransactionTableViewCell(style: .Default, reuseIdentifier: identifier)
        }
        
        let isPastTransaction = indexPath.section == 1
        let transaction = isPastTransaction ? pastTransactions[indexPath.row] : upcomingTransactions[indexPath.row]
        
        cell?.transaction = transaction
        
        return cell!
    }
    
    
    //MARK: UITableViewDelegate
    
//    @available(iOS 8.0, *)
//    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
//        let deleteAction = UITableViewRowAction(style: UITableViewRowActionStyle.Destructive, title: "delete".localizedString, handler: { (action: UITableViewRowAction, indexPath: NSIndexPath) -> Void in
//            if let _ = self.tableView.cellForRowAtIndexPath(indexPath) as? PPTransactionTableViewCell {
//                let key = Array(self.groupedCheckins!.keys)[indexPath.section]
//                let checkin = self.groupedCheckins![key]![indexPath.row]
//                SpotOperations.hideCheckin(checkin.checkinId, completion: { (success) -> Void in
//                    self.tableView.setEditing(false, animated: true)
//                    self.loadTransactions()
//                })
//            } else {
//                self.tableView.setEditing(false, animated: true)
//            }
//        })
//        return [deleteAction]
//    }
//    
//    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
//        return true
//    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let isPastTransaction = indexPath.section == 1
        let transaction = isPastTransaction ? pastTransactions[indexPath.row] : upcomingTransactions[indexPath.row]
        let transactionVC = PPTransactionViewController(transaction: transaction, lot: nil)
        self.presentViewController(transactionVC, animated: true) { () -> Void in
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            self.reloadOnNextAppear = false
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return ROW_HEIGHT
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SECTION_HEADER_HEIGHT
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerText = ""
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.width))
        paddingView.backgroundColor = Styles.Colors.cream1
        if section == 0 {
            headerText = "upcoming_reservations".localizedString
        } else if section == 1 {
            headerText = "past_reservations".localizedString
        }
        let headerView = GeneralTableHelperViews.sectionHeaderView(headerText)
        if pastTransactions.count == 0 && section == 1 {
            headerView?.addSubview(paddingView)
        }
        return headerView
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
        let totalHeight = topPadding+iconViewHeight+titleLabelTopPadding+titleLabelHeight+PPTransactionsViewController.VERTICAL_PADDING
        
        let headerView = UIView()
        let iconView = UIImageView(image: UIImage(named: "icon_history"))
        let titleLabel = UILabel()

        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.mainScreen().bounds.width), height: totalHeight)
        
        headerView.clipsToBounds = true
        headerView.addSubview(iconView)
        
        titleLabel.font = Styles.Fonts.h1
        titleLabel.textColor = Styles.Colors.cream1
        titleLabel.textAlignment = .Center
        titleLabel.text = "reservations".localizedString
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
