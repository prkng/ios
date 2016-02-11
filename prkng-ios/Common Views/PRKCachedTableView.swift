//
//  PRKCachedTableView.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2016-02-11.
//  Copyright © 2016 PRKNG. All rights reserved.
//

import Foundation

class PRKCachedTableView: UITableView {
    
    var cachedCells = [UITableViewCell]()
    
    override func dequeueReusableCellWithIdentifier(identifier: String) -> UITableViewCell? {
        let cell = super.dequeueReusableCellWithIdentifier(identifier)
        //sometimes cells don't dequeue (if we manually reload the table, or reload a section
        if cell == nil {
            for cachedCell in cachedCells {
                if cachedCell.reuseIdentifier == identifier {
                    return cachedCell
                }
            }
        }
        return cell
    }
    
    // add generated cells to cachedCells in the delegate's 
    //func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell 
    //in order to reuse that exact view when dequeing might recreate it
    
}