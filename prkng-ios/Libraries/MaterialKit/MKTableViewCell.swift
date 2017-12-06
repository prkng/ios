//
//  MKTableViewCell.swift
//  MaterialKit
//
//  Created by Le Van Nghia on 11/15/14.
//  Copyright (c) 2014 Le Van Nghia. All rights reserved.
//

import UIKit

open class MKTableViewCell : UITableViewCell {
    @IBInspectable open var rippleLocation: MKRippleLocation = .tapLocation {
        didSet {
            mkLayer.rippleLocation = rippleLocation
        }
    }
    @IBInspectable open var rippleAniDuration: Float = 0.75
    @IBInspectable open var backgroundAniDuration: Float = 1.0
    @IBInspectable open var rippleAniTimingFunction: MKTimingFunction = .linear
    @IBInspectable open var shadowAniEnabled: Bool = true

    // color
    @IBInspectable open var rippleLayerColor: UIColor = UIColor(white: 0.45, alpha: 0.5) {
        didSet {
            mkLayer.setCircleLayerColor(rippleLayerColor)
        }
    }
    @IBInspectable open var backgroundLayerColor: UIColor = UIColor(white: 0.75, alpha: 0.25) {
        didSet {
            mkLayer.setBackgroundLayerColor(backgroundLayerColor)
        }
    }

    fileprivate lazy var mkLayer: MKLayer = MKLayer(superLayer: self.contentView.layer)
    fileprivate var contentViewResized = false

    override public init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayer()
    }

    fileprivate func setupLayer() {
        selectionStyle = .none
        mkLayer.setBackgroundLayerColor(backgroundLayerColor)
        mkLayer.setCircleLayerColor(rippleLayerColor)
        mkLayer.ripplePercent = 1.2
    }

    open override func prepareForReuse() {
        super.prepareForReuse()
        self.mkLayer.removeAllAnimations()
    }
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if let firstTouch = touches.first {
            if !contentViewResized {
                mkLayer.superLayerDidResize()
                contentViewResized = true
            }
            mkLayer.didChangeTapLocation(firstTouch.location(in: contentView))

            mkLayer.animateScaleForCircleLayer(0.65, toScale: 1.0, timingFunction: rippleAniTimingFunction, duration: CFTimeInterval(rippleAniDuration))
            mkLayer.animateAlphaForBackgroundLayer(MKTimingFunction.linear, duration: CFTimeInterval(backgroundAniDuration))
        }
    }
}
