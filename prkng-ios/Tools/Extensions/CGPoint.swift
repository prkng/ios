//
//  CGPoint.swift
//  prkng-ios
//
//  Created by Antonino Urbano on 2015-06-17.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit

extension CGPoint {

    func distanceToPoint(otherPoint: CGPoint) -> CGFloat {
        let xDist: CGFloat = (otherPoint.x - self.x);
        let yDist: CGFloat = (otherPoint.y - self.y);
        let distance: CGFloat = sqrt((xDist * xDist) + (yDist * yDist));
        return distance
    }
    
    func yDistanceToPointWithDirection(otherPoint: CGPoint) -> CGFloat {
        let yDist: CGFloat = (otherPoint.y - self.y);
        return yDist
    }


}
