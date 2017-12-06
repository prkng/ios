//
//  PPTransactionsViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2016-03-01.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class PPTransactionsViewController: AbstractViewController, UITableViewDataSource, UITableViewDelegate {
    
    fileprivate let backgroundImageView = UIImageView(image: UIImage(named:"bg_mycar"))
    
    fileprivate let tableView = UITableView()
    
    fileprivate var upcomingTransactions = [ParkingPandaTransaction]()
    fileprivate var pastTransactions = [ParkingPandaTransaction]()
    
    fileprivate var didGoToPPIntro = false
    fileprivate var reloadOnNextAppear = true
    
    fileprivate let ROW_HEIGHT: CGFloat = 70
    fileprivate let SECTION_HEADER_HEIGHT: CGFloat = 61
    
    fileprivate static let VERTICAL_PADDING = 15
    fileprivate static let TOP_VIEW_PADDING = 30 + 24 + VERTICAL_PADDING //from top_layout_guide_bottom: 30 pts of space, 24 pts of segmented control, 15 pts padding
    
    override func loadView() {
        view = UIView()
        setupViews()
        setupConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.screenName = "My Activity - Reservations View"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if reloadOnNextAppear {
            self.loadTransactions()
        }
        reloadOnNextAppear = true
    }
    
    func loadTransactions() {

        SVProgressHUD.setBackgroundColor(UIColor.clear)
        SVProgressHUD.show()

        ParkingPandaOperations.login(username: nil, password: nil) { (user, error) -> Void in
            if user != nil {
                ParkingPandaOperations.getTransactions(user!, forTime: ParkingPandaOperations.ParkingPandaTransactionTime.all, completion: { (transactions, error) -> Void in
                    let currentDate = Date()
                    self.pastTransactions = transactions.filter({ (transaction) -> Bool in
                        return (transaction.endDateAndTime as NSDate?)?.earlierDate(currentDate) == transaction.endDateAndTime
                    })
                    self.pastTransactions.sort(by: { (left, right) -> Bool in
                        return (left.endDateAndTime as NSDate?)?.earlierDate(right.endDateAndTime ?? currentDate) == right.endDateAndTime
                    })
                    self.upcomingTransactions = transactions.filter({ (transaction) -> Bool in
                        return (transaction.endDateAndTime as NSDate?)?.earlierDate(currentDate) == currentDate
                    })
                    self.upcomingTransactions.sort(by: { (left, right) -> Bool in
                        return (left.endDateAndTime as NSDate?)?.earlierDate(right.endDateAndTime ?? currentDate) == left.endDateAndTime
                    })
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        SVProgressHUD.dismiss()
                        self.tableView.reloadData()
                    })
                })
            } else {
                DispatchQueue.main.async(execute: { () -> Void in
                    SVProgressHUD.dismiss()
                    if let ppError = error {
                        switch (ppError.errorType) {
                        case .api, .internal:
                            if !self.didGoToPPIntro {
                                ParkingPandaOperations.logout()
                                let ppIntroVC = PPIntroViewController()
                                ppIntroVC.presentWithVC(nil)
                                self.didGoToPPIntro = true
                            }
                        case .noError, .network:
                            break
                        }
                    }
                })
            }
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
            make.top.equalTo(self.snp_topLayoutGuideBottom).offset(PPTransactionsViewController.TOP_VIEW_PADDING)
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }
    }
    
    //MARK: UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            return upcomingTransactions.count
        } else if section == 1 {
            return pastTransactions.count
        }
        return 0
    }
    
    let identifier = "PPTransactionTableViewCell"
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? PPTransactionTableViewCell
        if cell == nil {
            cell = PPTransactionTableViewCell(style: .default, reuseIdentifier: identifier)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let isPastTransaction = indexPath.section == 1
        let transaction = isPastTransaction ? pastTransactions[indexPath.row] : upcomingTransactions[indexPath.row]
        let transactionVC = PPTransactionViewController(transaction: transaction, lot: nil)
        self.present(transactionVC, animated: true) { () -> Void in
            tableView.deselectRow(at: indexPath, animated: true)
            self.reloadOnNextAppear = false
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ROW_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SECTION_HEADER_HEIGHT
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var headerText = ""
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width))
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
    
    func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
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

        headerView.frame = CGRect(x: 0, y: 0, width: Int(UIScreen.main.bounds.width), height: totalHeight)
        
        headerView.clipsToBounds = true
        headerView.addSubview(iconView)
        
        titleLabel.font = Styles.Fonts.h1
        titleLabel.textColor = Styles.Colors.cream1
        titleLabel.textAlignment = .center
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
