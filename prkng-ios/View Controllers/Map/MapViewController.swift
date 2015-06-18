//
//  MapViewController.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-06-11.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

class MapViewController: AbstractViewController {

    var delegate: MapViewControllerDelegate?
    
    var searchCheckinDate : NSDate?
    var searchDuration : Float?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func displaySearchResults(results: Array<SearchResult>, checkinTime : NSDate?) { }
    func clearSearchResults() { }
    func showUserLocation(shouldShow: Bool) { }
    func trackUser(shouldTrack: Bool) { }
    func updateAnnotations() { }

    //shows a checkin on the map as a regular marker
    func goToPreviousCheckin(checkin: Checkin) { }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

protocol MapViewControllerDelegate {
    
    func mapDidDismissSelection()
    
    func didSelectSpot(spot: ParkingSpot)
    
    func shouldShowUserTrackingButton() -> Bool
    
    //returns the number of hours to search for as a minimum parking duration
    func activeFilterDuration() -> Float?
    
}