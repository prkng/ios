//
//  TSTrackLayer.swift
//  SliderWithTicks
//
//  Created by Alexander Batalov on 3/3/15.
//  Copyright (c) 2015 Alexander Batalov. All rights reserved.
//

import UIKit

class PRKModeSliderTrackLayer: CALayer {
    weak var prkModeSlider : PRKModeSlider?
    
    override func drawInContext(ctx: CGContext!) {
        if let slider = prkModeSlider {
            // Path without ticks
            let trackPath = UIBezierPath(rect: CGRect(x: 0, y: bounds.maxY - slider.trackHeight, width: bounds.width, height: slider.trackHeight))
            
            
            // Fill the track
            CGContextSetFillColorWithColor(ctx, slider.trackColor)
            CGContextAddPath(ctx, trackPath.CGPath)
            CGContextFillPath(ctx)
            
        }
    }
}
