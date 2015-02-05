//
//  MapViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 05/02/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit
import Snap

class MapViewController: AbstractViewController {
    
    var mapView : RMMapView
    
    override init () {

        let source = RMMapboxSource(mapID: "cagdas.l4ob5af0")
        mapView = RMMapView(frame: CGRectMake(0,0,100,100), andTilesource: source)
        mapView.zoom = 16
        mapView.centerCoordinate = CLLocationCoordinate2D(latitude: 45.521743896993634, longitude: -73.564453125)
        
        super.init(nibName:nil, bundle:nil)
    }
    
    override func loadView() {
        self.view = UIView()

        self.view.addSubview(mapView)
        
        mapView.snp_makeConstraints { make in
            make.edges.equalTo(self.view)
            return
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
