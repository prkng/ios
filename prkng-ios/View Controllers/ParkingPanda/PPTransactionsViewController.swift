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
    
    private let headerView = UIView()
    private let headerImageView = UIImageView()
    private let HEADER_MIN_HEIGHT : Float = 90
    private let HEADER_MAX_HEIGHT : Float = floor(Float(UIScreen.mainScreen().bounds.size.height) * 0.44)
    private var previousYPosition : Float = 90 - floor(Float(UIScreen.mainScreen().bounds.size.height) * 0.44)
    private var currentHeaderHeight : Float = floor(Float(UIScreen.mainScreen().bounds.size.height) * 0.44)  // default same as HEADER_MAX_HEIGHT
    
    private let iconView = UIImageView(image: UIImage(named: "icon_history"))
    private let titleLabel = UILabel()
    private let tableView = UITableView()
    
    private var upcomingTransactions = [ParkingPandaTransaction]()
    private var pastTransactions = [ParkingPandaTransaction]()
    
    private var didGoToPPIntro = false
    
    private let ROW_HEIGHT: CGFloat = 70
    private let SECTION_HEADER_HEIGHT: CGFloat = 61
    
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
        self.loadTransactions()
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
        tableView.contentInset = UIEdgeInsetsMake(CGFloat(HEADER_MAX_HEIGHT - HEADER_MIN_HEIGHT), 0, 0, 0);
        tableView.setContentOffset(CGPointMake(0, -tableView.contentInset.top), animated: false)
        
        
        tableView.separatorStyle = .None
        tableView.dataSource = self
        tableView.delegate = self
        tableView.clipsToBounds = true
        view.addSubview(tableView)
        
        view.addSubview(headerView)
        
        headerImageView.image = UIImage(named:"bg_mycar")
        headerImageView.contentMode = .ScaleAspectFill
        headerView.addSubview(headerImageView)
        headerView.clipsToBounds = true
        headerView.addSubview(iconView)
        
        titleLabel.font = Styles.Fonts.h1
        titleLabel.textColor = Styles.Colors.cream1
        titleLabel.textAlignment = .Center
        titleLabel.text = "reservations".localizedString
        headerView.addSubview(titleLabel)
        
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
            make.top.equalTo(self.headerView).offset(20+40+30+24)
            make.centerX.equalTo(self.view)
            make.size.equalTo(CGSizeMake(68, 68))
        }
        
        titleLabel.snp_makeConstraints { (make) -> () in
            make.top.equalTo(self.iconView.snp_bottom).offset(12)
            make.height.equalTo(34)
            make.left.equalTo(self.headerView)
            make.right.equalTo(self.headerView)
        }
        
        
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        let screenHeight = UIScreen.mainScreen().bounds.size.height - CGFloat(Styles.Sizes.tabbarHeight)
        
        headerView.frame = CGRectMake(0, 0, screenWidth, CGFloat(HEADER_MAX_HEIGHT))
        
        let tableViewHeight = screenHeight - CGFloat(HEADER_MIN_HEIGHT)
        tableView.frame = CGRectMake(0, CGFloat(HEADER_MIN_HEIGHT), screenWidth, tableViewHeight)
        
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
        //TODO: Localize
        if section == 0 {
            headerText = "upcoming_reservations".localizedString
        } else if section == 1 {
            headerText = "past_reservations".localizedString
        }
        return GeneralTableHelperViews.sectionHeaderView(headerText)
    }
    
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let yPos = Float(scrollView.contentOffset.y)
        var height:Float = currentHeaderHeight
        let dy = previousYPosition - yPos
        
//        print("dy : \(dy)")
//        print("previousYPosition : \(previousYPosition)")
//        print("yPos : \(yPos)")
        
        height += dy
        
        if (yPos > Float(scrollView.contentSize.height - scrollView.frame.size.height)){
            return
        }
        
        
        if (height > HEADER_MAX_HEIGHT) {
            height = HEADER_MAX_HEIGHT
        } else if (height < HEADER_MIN_HEIGHT) {
            height = HEADER_MIN_HEIGHT
        }
        
//        print("header height : \(height)")
//        print("contentInset top : \(scrollView.contentInset.top)")
        
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
//            tableView.backgroundColor = Styles.Colors.stone
            
            currentHeaderHeight = height
            var alpha = CGFloat((height / HEADER_MAX_HEIGHT))
            
            if(alpha > 0.9) {
                alpha = 1
            } else if(alpha < 0.5) {
                alpha = alpha / 2
            }
            if(alpha < 0.2) {
                alpha = 0
            }
            
            iconView.alpha = alpha
            titleLabel.alpha = alpha
            
            headerView.layoutIfNeeded()
        }
        
        previousYPosition = yPos

    }
    
    //MARK: Button Handlers
    
    func backButtonTapped(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
}
