//
//  MKLayer.swift
//  MaterialKit
//
//  Created by Le Van Nghia on 11/15/14.
//  Copyright (c) 2014 Le Van Nghia. All rights reserved.
//

import UIKit
import QuartzCore

public enum MKTimingFunction {
    case linear
    case easeIn
    case easeOut
    case custom(Float, Float, Float, Float)

    public var function: CAMediaTimingFunction {
        switch self {
        case .linear:
            return CAMediaTimingFunction(name: "linear")
        case .easeIn:
            return CAMediaTimingFunction(name: "easeIn")
        case .easeOut:
            return CAMediaTimingFunction(name: "easeOut")
        case .custom(let cpx1, let cpy1, let cpx2, let cpy2):
            return CAMediaTimingFunction(controlPoints: cpx1, cpy1, cpx2, cpy2)
        }
    }
}

public enum MKRippleLocation {
    case center
    case left
    case right
    case tapLocation
}

open class MKLayer {
    fileprivate var superLayer: CALayer!
    fileprivate let rippleLayer = CALayer()
    fileprivate let backgroundLayer = CALayer()
    fileprivate let maskLayer = CAShapeLayer()
    
    open var rippleLocation: MKRippleLocation = .tapLocation {
        didSet {
            let origin: CGPoint?
            let sw = superLayer.bounds.width
            let sh = superLayer.bounds.height
            
            switch rippleLocation {
            case .center:
                origin = CGPoint(x: sw/2, y: sh/2)
            case .left:
                origin = CGPoint(x: sw*0.25, y: sh/2)
            case .right:
                origin = CGPoint(x: sw*0.75, y: sh/2)
            default:
                origin = nil
            }
            if let origin = origin {
                setCircleLayerLocationAt(origin)
            }
        }
    }

    open var ripplePercent: Float = 0.9 {
        didSet {
            if ripplePercent > 0 {
                let sw = superLayer.bounds.width
                let sh = superLayer.bounds.height
                let circleSize = CGFloat(max(sw, sh)) * CGFloat(ripplePercent)
                let circleCornerRadius = circleSize/2

                rippleLayer.cornerRadius = circleCornerRadius
                setCircleLayerLocationAt(CGPoint(x: sw/2, y: sh/2))
            }
        }
    }

    public init(superLayer: CALayer) {
        self.superLayer = superLayer

        let sw = superLayer.bounds.width
        let sh = superLayer.bounds.height

        // background layer
        backgroundLayer.frame = superLayer.bounds
        backgroundLayer.opacity = 0.0
        superLayer.addSublayer(backgroundLayer)

        // ripple layer
        let circleSize = CGFloat(max(sw, sh)) * CGFloat(ripplePercent)
        let rippleCornerRadius = circleSize/2

        rippleLayer.opacity = 0.0
        rippleLayer.cornerRadius = rippleCornerRadius
        setCircleLayerLocationAt(CGPoint(x: sw/2, y: sh/2))
        backgroundLayer.addSublayer(rippleLayer)

        // mask layer
        setMaskLayerCornerRadius(superLayer.cornerRadius)
        backgroundLayer.mask = maskLayer
    }

    open func superLayerDidResize() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        backgroundLayer.frame = superLayer.bounds
        setMaskLayerCornerRadius(superLayer.cornerRadius)
        CATransaction.commit()
        setCircleLayerLocationAt(CGPoint(x: superLayer.bounds.width/2, y: superLayer.bounds.height/2))
    }

    open func enableOnlyCircleLayer() {
        backgroundLayer.removeFromSuperlayer()
        superLayer.addSublayer(rippleLayer)
    }

    open func setBackgroundLayerColor(_ color: UIColor) {
        backgroundLayer.backgroundColor = color.cgColor
    }

    open func setCircleLayerColor(_ color: UIColor) {
        rippleLayer.backgroundColor = color.cgColor
    }

    open func didChangeTapLocation(_ location: CGPoint) {
        if rippleLocation == .tapLocation {
            setCircleLayerLocationAt(location)
        }
    }

    open func setMaskLayerCornerRadius(_ cornerRadius: CGFloat) {
        maskLayer.path = UIBezierPath(roundedRect: backgroundLayer.bounds, cornerRadius: cornerRadius).cgPath
    }

    open func enableMask(_ enable: Bool = true) {
        backgroundLayer.mask = enable ? maskLayer : nil
    }

    open func setBackgroundLayerCornerRadius(_ cornerRadius: CGFloat) {
        backgroundLayer.cornerRadius = cornerRadius
    }

    fileprivate func setCircleLayerLocationAt(_ center: CGPoint) {
        let bounds = superLayer.bounds
        let width = bounds.width
        let height = bounds.height
        let subSize = CGFloat(max(width, height)) * CGFloat(ripplePercent)
        let subX = center.x - subSize/2
        let subY = center.y - subSize/2

        // disable animation when changing layer frame
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        rippleLayer.cornerRadius = subSize / 2
        rippleLayer.frame = CGRect(x: subX, y: subY, width: subSize, height: subSize)
        CATransaction.commit()
    }

    // MARK - Animation
    open func animateScaleForCircleLayer(_ fromScale: Float, toScale: Float, timingFunction: MKTimingFunction, duration: CFTimeInterval) {
        let rippleLayerAnim = CABasicAnimation(keyPath: "transform.scale")
        rippleLayerAnim.fromValue = fromScale
        rippleLayerAnim.toValue = toScale

        let opacityAnim = CABasicAnimation(keyPath: "opacity")
        opacityAnim.fromValue = 1.0
        opacityAnim.toValue = 0.0

        let groupAnim = CAAnimationGroup()
        groupAnim.duration = duration
        groupAnim.timingFunction = timingFunction.function
        groupAnim.isRemovedOnCompletion = false
        groupAnim.fillMode = kCAFillModeForwards

        groupAnim.animations = [rippleLayerAnim, opacityAnim]

        rippleLayer.add(groupAnim, forKey: nil)
    }

    open func animateAlphaForBackgroundLayer(_ timingFunction: MKTimingFunction, duration: CFTimeInterval) {
        let backgroundLayerAnim = CABasicAnimation(keyPath: "opacity")
        backgroundLayerAnim.fromValue = 1.0
        backgroundLayerAnim.toValue = 0.0
        backgroundLayerAnim.duration = duration
        backgroundLayerAnim.timingFunction = timingFunction.function
        backgroundLayer.add(backgroundLayerAnim, forKey: nil)
    }

    open func animateSuperLayerShadow(_ fromRadius: CGFloat, toRadius: CGFloat, fromOpacity: Float, toOpacity: Float, timingFunction: MKTimingFunction, duration: CFTimeInterval) {
        animateShadowForLayer(superLayer, fromRadius: fromRadius, toRadius: toRadius, fromOpacity: fromOpacity, toOpacity: toOpacity, timingFunction: timingFunction, duration: duration)
    }

    open func animateMaskLayerShadow() {

    }

    fileprivate func animateShadowForLayer(_ layer: CALayer, fromRadius: CGFloat, toRadius: CGFloat, fromOpacity: Float, toOpacity: Float, timingFunction: MKTimingFunction, duration: CFTimeInterval) {
        let radiusAnimation = CABasicAnimation(keyPath: "shadowRadius")
        radiusAnimation.fromValue = fromRadius
        radiusAnimation.toValue = toRadius

        let opacityAnimation = CABasicAnimation(keyPath: "shadowOpacity")
        opacityAnimation.fromValue = fromOpacity
        opacityAnimation.toValue = toOpacity

        let groupAnimation = CAAnimationGroup()
        groupAnimation.duration = duration
        groupAnimation.timingFunction = timingFunction.function
        groupAnimation.isRemovedOnCompletion = false
        groupAnimation.fillMode = kCAFillModeForwards
        groupAnimation.animations = [radiusAnimation, opacityAnimation]

        layer.add(groupAnimation, forKey: nil)
    }
    
    open func removeAllAnimations() {
        self.backgroundLayer.removeAllAnimations()
        self.rippleLayer.removeAllAnimations()
    }
    
}
