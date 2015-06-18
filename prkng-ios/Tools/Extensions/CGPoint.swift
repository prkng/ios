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
        var xDist: CGFloat = (otherPoint.x - self.x);
        var yDist: CGFloat = (otherPoint.y - self.y);
        var distance: CGFloat = sqrt((xDist * xDist) + (yDist * yDist));
        return distance
    }

}
