//
//  SearchResultsTableViewController.swift
//  
//
//  Created by Antonino Urbano on 2015-08-05.
//
//

import UIKit

class SearchResultsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var delegate: SearchResultsTableViewControllerDelegate?
    
    private var searchResultValues: [SearchResult] = []
    private var tableView: UITableView
    private var blurView = UIImageView()
    
    func updateSearchResultValues(searchResultValues: [SearchResult]) {
        self.searchResultValues = searchResultValues
        self.tableView.reloadData()
    }
    
    func customSeparator() -> UIView {
        let screenWidth = UIScreen.mainScreen().bounds.width
        let view = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 0.5))
        view.backgroundColor = Styles.Colors.transparentWhite
        return view
    }
    
    init(searchResultValues: [SearchResult]) {
        self.tableView = UITableView()
        self.searchResultValues = searchResultValues
        super.init(nibName: nil, bundle: nil)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateBlur() {
        
        let screenHeight = UIScreen.mainScreen().bounds.height
        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let root = delegate.window?.rootViewController
        let bounds = CGRect(x: 0, y: -SearchFilterView.TOTAL_HEIGHT, width: root!.view.bounds.width, height: screenHeight)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: root!.view.bounds.width, height: screenHeight - SearchFilterView.TOTAL_HEIGHT),
            true, Settings.screenScale)
        root!.view.drawViewHierarchyInRect(bounds,
            afterScreenUpdates: true)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let blur = screenshot.applyBlurWithRadius(10, tintColor: Styles.Colors.beige1.colorWithAlphaComponent(0.3), saturationDeltaFactor: 1.8, maskImage: nil)
        
        let screenview = UIImageView(image: screenshot)
        screenview.contentMode = UIViewContentMode.Center
        let blurredview = UIImageView(image: blur)
        
        blurView.frame = self.view.bounds
        blurView.image = blur
        blurView.contentMode = .Top
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView = UITableView(frame: self.view.frame, style: UITableViewStyle.Plain)
        self.tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.view.addSubview(self.tableView)
        
        self.tableView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }

//        if Settings.iOS8OrLater() {
//            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
//            let blurView = UIVisualEffectView(effect: blurEffect)
//            blurView.frame = self.view.frame
//            self.view.insertSubview(blurView, atIndex: 0)
//        } else {
//            self.view.backgroundColor = Styles.Colors.midnight2
//        }
        
        updateBlur()
        self.view.insertSubview(blurView, atIndex: 0)
        
        self.tableView.backgroundColor = UIColor.clearColor()
        self.tableView.separatorStyle = .None
        
        let screenWidth = UIScreen.mainScreen().bounds.width
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 40))
        footer.addSubview(customSeparator())
        let label = UILabel(frame: CGRect(x: 0, y: 0.5, width: screenWidth, height: 39.5))
        label.text = "provided_by_foursquare".localizedString
        label.textColor = Styles.Colors.anthracite1
        label.font = Styles.FontFaces.regular(14)
        label.textAlignment = .Center
        footer.addSubview(label)
        self.tableView.tableFooterView = footer
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return searchResultValues.count
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        var cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as? UITableViewCell
//
//        if cell == nil {
           let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "reuseIdentifier")
//        }
        // Configure the cell...
        cell.backgroundColor = UIColor.clearColor()//Styles.Colors.midnight2
        cell.indentationWidth = 48
        cell.indentationLevel = 1
        cell.textLabel?.text = searchResultValues[indexPath.row].title
        cell.textLabel?.textColor = Styles.Colors.petrol2
        cell.textLabel?.font = Styles.FontFaces.bold(14)
        cell.detailTextLabel?.text = searchResultValues[indexPath.row].subtitle
        cell.detailTextLabel?.textColor = Styles.Colors.anthracite1
        cell.detailTextLabel?.font = Styles.FontFaces.regular(14)
        cell.addSubview(customSeparator())
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        AnalyticsOperations.sendSearchQueryToAnalytics(searchResultValues[indexPath.row].title!)
        delegate?.didSelectSearchResult(searchResultValues[indexPath.row])
    }

}

protocol SearchResultsTableViewControllerDelegate {
    func didSelectSearchResult(result: SearchResult)
}
