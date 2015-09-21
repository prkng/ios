//
//  TSThumbLayer.swift
//  SliderWithTicks
//
//  Created by Alexander Batalov on 3/2/15.
//  Copyright (c) 2015 Alexander Batalov. All rights reserved.
//

import UIKit

class PRKModeSliderThumbLayer: CALayer {
    
    let thumbBackgroundColor = Styles.Colors.red2
    let textColor = Styles.Colors.cream1
    let font = Styles.FontFaces.regular(14)

    weak var prkModeSlider : PRKModeSlider?
    
    var highlighted: Bool = false {
        didSet {
            setNeedsLayout()
        }
    }

    override func layoutSublayers() {
        super.layoutSublayers()
        if let slider = prkModeSlider {
            let value = self.frame.origin.x / self.bounds.width
            for i in 0..<self.sublayers.count {
                let labelRect = CGRect(x: (CGFloat(i)*slider.thumbWidth) - (CGFloat(value) * slider.thumbWidth), y: 0, width: slider.thumbWidth, height: slider.bounds.height)
                let sublayer = self.sublayers[i] as! CALayer
                sublayer.frame = labelRect
            }
        }
    }
    
    func setupWithSlider(slider: PRKModeSlider) {
        
        self.prkModeSlider = slider

        self.needsDisplayOnBoundsChange = true
        self.masksToBounds = true
        self.backgroundColor = thumbBackgroundColor.CGColor
        
        //layers for all the text
        for i in 0..<slider.titles.count {
            let title = slider.titles[i]
            let attributedTitle = NSMutableAttributedString(string: title, attributes: [NSFontAttributeName: font, NSForegroundColorAttributeName: textColor])
            let labelRect = CGRect(x: (CGFloat(i)*slider.thumbWidth), y: 0, width: slider.thumbWidth, height: slider.bounds.height)
            
            let textLayer = LCTextLayer()
            textLayer.frame = labelRect
            textLayer.string = title
            textLayer.font = CTFontCreateWithName(font.fontName, font.pointSize, nil)
            textLayer.fontSize = font.pointSize
            textLayer.foregroundColor = textColor.CGColor
            textLayer.alignmentMode = kCAAlignmentCenter
            textLayer.contentsScale = UIScreen.mainScreen().scale
            self.addSublayer(textLayer)
        }

        
    }
}


//this class is to vertically center CATextLayer in the parent layer
class LCTextLayer : CATextLayer {
    
    // REF: http://lists.apple.com/archives/quartz-dev/2008/Aug/msg00016.html
    // CREDIT: David Hoerl - https://github.com/dhoerl
    // USAGE: To fix the vertical alignment issue that currently exists within the CATextLayer class. Change made to the yDiff calculation.
    
    override init!() {
        super.init()
    }
    
    override init!(layer: AnyObject!) {
        super.init(layer: layer)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(layer: aDecoder)
    }
    
    override func drawInContext(ctx: CGContext!) {
        let height = self.bounds.size.height
        let fontSize = self.fontSize
        let yDiff = (height-fontSize)/2 - fontSize/10
        
        CGContextSaveGState(ctx)
        CGContextTranslateCTM(ctx, 0.0, yDiff)
        super.drawInContext(ctx)
        CGContextRestoreGState(ctx)
    }
}

