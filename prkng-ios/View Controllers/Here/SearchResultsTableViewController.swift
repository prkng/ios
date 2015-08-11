//
//  SearchResultsTableViewController.swift
//  
//
//  Created by Antonino Urbano on 2015-08-05.
//
//

import UIKit

class SearchResultsTableViewController: UITableViewController {

    var delegate: SearchResultsTableViewControllerDelegate?
    
    private var searchResultValues: [SearchResult] = []
    
    func customSeparator() -> UIView {
        let screenWidth = UIScreen.mainScreen().bounds.width
        let view = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 0.5))
        view.backgroundColor = Styles.Colors.transparentWhite
        return view
    }
    
    init(searchResultValues: [SearchResult]) {
        self.searchResultValues = searchResultValues
        super.init(nibName: nil, bundle: nil)
    }

    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = Styles.Colors.midnight2
        self.tableView.separatorStyle = .None
        self.tableView.tableFooterView = customSeparator()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return searchResultValues.count
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        var cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as? UITableViewCell
//
//        if cell == nil {
           let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "reuseIdentifier")
//        }
        // Configure the cell...
        cell.backgroundColor = Styles.Colors.midnight2
        cell.indentationWidth = 48
        cell.indentationLevel = 1
        cell.textLabel?.text = searchResultValues[indexPath.row].title
        cell.textLabel?.textColor = Styles.Colors.cream2
        cell.textLabel?.font = Styles.FontFaces.bold(16)
        cell.detailTextLabel?.text = searchResultValues[indexPath.row].subtitle
        cell.detailTextLabel?.textColor = Styles.Colors.anthracite1
        cell.detailTextLabel?.font = Styles.FontFaces.regular(14)
        cell.addSubview(customSeparator())
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.didSelectSearchResult(searchResultValues[indexPath.row])
    }

}

protocol SearchResultsTableViewControllerDelegate {
    func didSelectSearchResult(result: SearchResult)
}
