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
    
//percentToMoveIntoImage is how much you wish it to be overlayed. so 0 means that you would have 2 boxes, where one's upper right corner touches the other's bottom left corner.
    func addImageToTopRight(imageToAdd: UIImage, valueToMoveIntoImage: CGFloat) -> UIImage {
        let denominator = 1/(valueToMoveIntoImage == 0 ? 0.001 : valueToMoveIntoImage)
        let bigDrawRect = CGRectMake(0, 0, self.size.width+imageToAdd.size.width/denominator, self.size.height+imageToAdd.size.height/denominator)
        let imageDrawRect = CGRectMake(0, imageToAdd.size.height/denominator, self.size.width, self.size.height)
        let imageToAddDrawRect = CGRectMake(bigDrawRect.width-imageToAdd.size.width, 0, imageToAdd.size.width, imageToAdd.size.height)
        
        UIGraphicsBeginImageContextWithOptions(bigDrawRect.size, false, Settings.screenScale)
        self.drawInRect(imageDrawRect)
        imageToAdd.drawInRect(imageToAddDrawRect)
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage
    }

    func extendHeight(heightExtension: CGFloat, andWidth widthExtension: CGFloat) -> UIImage {
        let extendedSize = CGSize(width: self.size.width + widthExtension, height: self.size.height + heightExtension)
        UIGraphicsBeginImageContextWithOptions(extendedSize, false, Settings.screenScale)
        self.drawInRect(CGRect(x: 0, y: heightExtension, width: self.size.width, height: self.size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    

    //tints white to the given color (CGBlendMode.Multiply)
    func imageTintedWithColor(color: UIColor, blendMode: CGBlendMode) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        let rect = CGRect(origin: CGPointZero, size: self.size)
        
        //tint the image
        self.drawInRect(rect)
        color.set()
        UIRectFillUsingBlendMode(rect, blendMode)
        
        //restore alpha channel
        self.drawInRect(rect, blendMode: CGBlendMode.DestinationIn, alpha: 1)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }

    private func convertToGrayScaleNoAlpha() -> CGImageRef {
        let colorSpace = CGColorSpaceCreateDeviceGray();
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.None.rawValue)
        let context = CGBitmapContextCreate(nil, Int(size.width*scale), Int(size.height*scale), 8, 0, colorSpace, bitmapInfo.rawValue)
        CGContextDrawImage(context, CGRectMake(0, 0, size.width*scale, size.height*scale), self.CGImage)
        return CGBitmapContextCreateImage(context)!
    }
    
    func convertToGrayScale() -> UIImage {
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.Only.rawValue)
        let context = CGBitmapContextCreate(nil, Int(size.width*scale), Int(size.height*scale), 8, 0, nil, bitmapInfo.rawValue)
        CGContextDrawImage(context, CGRectMake(0, 0, size.width*scale, size.height*scale), self.CGImage);
        let mask = CGBitmapContextCreateImage(context)
        return UIImage(CGImage: CGImageCreateWithMask(convertToGrayScaleNoAlpha(), mask)!, scale: scale, orientation:imageOrientation)
    }

}

