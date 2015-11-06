//
//  ImageUtil.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 15/06/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

extension UIImage {
    
    func resizeImage(targetSize: CGSize) -> UIImage {
        let size = self.size
        
        let widthRatio  = targetSize.width  / self.size.width
        let heightRatio = targetSize.height / self.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSizeMake(size.width * heightRatio, size.height * heightRatio)
        } else {
            newSize = CGSizeMake(size.width * widthRatio,  size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRectMake(0, 0, newSize.width, newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, Settings.screenScale)
        self.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, Settings.screenScale)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    class func getRoundedRectImageFromImage(image: UIImage, rect:CGRect, cornerRadius:CGFloat) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, Settings.screenScale)
        UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
        image.drawInRect(rect)
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return finalImage
    }
    
    class func transparentImageWithSize(size: CGSize) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(size, false, Settings.screenScale)
        let viewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return viewImage
        
    }

    class func imageFromView(view: UIView) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, Settings.screenScale)
        view.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let viewImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return viewImage

    }
    
    class func screenshot(viewController: UIViewController?) -> UIImage {

        let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let root = viewController ?? delegate.window?.rootViewController
        let bounds = CGRect(x: 0, y: 0, width: root!.view.bounds.width, height: root!.view.bounds.height)
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: root!.view.bounds.width, height: root!.view.bounds.height),
            true, Settings.screenScale)
        root!.view.drawViewHierarchyInRect(bounds,
            afterScreenUpdates: true)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return screenshot
    }
    
    func addText(text: String, color: UIColor, font: UIFont) -> UIImage {
        
        let drawRect = CGRectMake(0, 0, self.size.width, self.size.height)
        let label = UILabel(frame: drawRect)
        label.text = text
        label.font = font
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, Settings.screenScale)
        self.drawInRect(drawRect)
        label.drawTextInRect(drawRect)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
        
    }

    func addText(attributedText: NSAttributedString, labelRect: CGRect?) -> UIImage {
        
        let drawRect = CGRectMake(0, 0, self.size.width, self.size.height)
        let labelDrawRect = labelRect ?? CGRectMake(0, 0, self.size.width, self.size.height)
        let label = UILabel(frame: drawRect)
        label.attributedText = attributedText
        label.textAlignment = NSTextAlignment.Center
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, Settings.screenScale)
        self.drawInRect(drawRect)
        label.drawTextInRect(labelDrawRect)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
        
    }
    
    func addText(attributedText: NSAttributedString, color: UIColor?, bottomOffset: CGFloat = 0) -> UIImage {
        
        let drawRect = CGRectMake(0, 0, self.size.width, self.size.height)
        let labelDrawRect = CGRectMake(0, 0, self.size.width, self.size.height - bottomOffset)
        let label = UILabel(frame: drawRect)
        label.attributedText = attributedText
        if color != nil {
            label.textColor = color!
        }
        label.textAlignment = NSTextAlignment.Center

        UIGraphicsBeginImageContextWithOptions(self.size, false, Settings.screenScale)
        self.drawInRect(drawRect)
        label.drawTextInRect(labelDrawRect)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
        
    }
    
    static func imageFromGradient(size: CGSize, fromColor: UIColor, toColor: UIColor) -> UIImage {
        
        let layer = CAGradientLayer()
        layer.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: size)
        layer.colors = [fromColor.CGColor, toColor.CGColor]
        
        UIGraphicsBeginImageContext(size)
        layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return image
    }

    func redrawImageInRect(drawRect: CGRect) -> UIImage {

        let scale = UIScreen.mainScreen().scale
        let scaledDrawRect = CGRect(x: drawRect.origin.x * scale, y: drawRect.origin.y * scale, width: drawRect.size.width * scale, height: drawRect.size.height * scale)
        let croppedImage = CGImageCreateWithImageInRect(self.CGImage, scaledDrawRect)
        return UIImage(CGImage: croppedImage!, scale: scale, orientation: self.imageOrientation) ?? UIImage()
    }

    
}

