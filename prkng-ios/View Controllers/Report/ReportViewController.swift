//
//  ReportViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 03/06/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit
import AVFoundation

class ReportViewController: AbstractViewController, CLLocationManagerDelegate {
    
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var captureDevice : AVCaptureDevice?
    var stillImageOutput = AVCaptureStillImageOutput()
    var capturedImage : UIImage?
    
    let overlayView = ReportOverlayView()
    let previewView = UIView()
    let imageView = UIImageView()
    let captureButton = UIButton()
    let sendButton = UIButton()
    let backButton = UIButton()
    let cancelButton = UIButton()
    
    let locationManager = CLLocationManager()
    var streetName : String?
    var location : CLLocation?
    var updatingLocation : Bool = false
    
    var spotId : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.clipsToBounds = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.startUpdatingLocation()
        
        setupSubviews()
        setupConstraints()
        
        // Do any additional setup after loading the view, typically from a nib.
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        println("Capture device found")
                        beginSession()
                    }
                }
            }
        }
        
        
    }
    
    func setupSubviews() {
        
        view.addSubview(previewView)
        
        view.addSubview(overlayView)
        
        imageView.hidden = true
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        view.addSubview(imageView)
        
        cancelButton.setImage(UIImage(named:"btn_report_cancel"), forState: UIControlState.Normal)
        cancelButton.addTarget(self, action: "cancelButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(cancelButton)
        
        sendButton.setImage(UIImage(named:"btn_sendreport"), forState: UIControlState.Normal)
        sendButton.addTarget(self, action: "sendButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(sendButton)
        
        backButton.setImage(UIImage(named:"btn_back"), forState: UIControlState.Normal)
        backButton.addTarget(self, action: "backButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(backButton)
        
        captureButton.setImage(UIImage(named:"btn_takeashot"), forState: UIControlState.Normal)
        captureButton.addTarget(self, action: "captureButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        view.addSubview(captureButton)
    }
    
    func setupConstraints() {
        
        previewView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }
        
        overlayView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }
        
        imageView.snp_makeConstraints { (make) -> () in
            make.edges.equalTo(self.view)
        }
        
        cancelButton.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.view).multipliedBy(0.33)
            make.size.equalTo(CGSizeMake(24, 24))
            make.bottom.equalTo(self.view).with.offset(-38.5)
        }
        
        
        sendButton.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.view)
            make.size.equalTo(CGSizeMake(60, 60))
            make.bottom.equalTo(self.view).with.offset(-20)
        }
        
        
        backButton.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.view).multipliedBy(0.33)
            make.size.equalTo(CGSizeMake(24, 24))
            make.bottom.equalTo(self.view).with.offset(-38.5)
        }
        
        captureButton.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.view)
            make.size.equalTo(CGSizeMake(60, 60))
            make.bottom.equalTo(self.view).with.offset(-20)
        }
    }
    
    
    func configureDevice() {
        if let device = captureDevice {
            device.lockForConfiguration(nil)
            device.focusMode = .AutoFocus
            device.exposureMode = .ContinuousAutoExposure
            device.flashMode = .Auto
            device.unlockForConfiguration()
        }
        
    }
    
    
    
    
    func beginSession() {
        
        configureDevice()
        
        var err : NSError? = nil
        captureSession.addInput(AVCaptureDeviceInput(device: captureDevice, error: &err))
        
        if err != nil {
            println("error: \(err?.localizedDescription)")
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewView.layer.addSublayer(previewLayer)
        
        let width =  self.view.frame.height * (768.0 / 1024.0)
        previewLayer?.frame = CGRectMake((self.view.frame.width - width) / 2, 0, width, self.view.frame.height)
        captureSession.startRunning()
    }
    
    
    func takePicture() {
        stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }
        
        if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) {
            
            if (captureDevice!.adjustingWhiteBalance || captureDevice!.adjustingExposure ) {
                
                stillImageOutput.captureStillImageAsynchronouslyFromConnection(stillImageOutput.connectionWithMediaType(AVMediaTypeVideo))
                    { (imageDataSampleBuffer, error) -> Void in
                        
                        if error == nil {
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                
                                self.capturedImage = UIImage(data: AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer))
                                
                                
                                self.imageView.image = self.capturedImage
                                
                                self.imageView.hidden = false
                                self.backButton.hidden = true
                                self.captureButton.hidden = true
                                
                                self.cancelButton.hidden = false
                                self.sendButton.hidden = false
                            })
                            
                        }
                        
                }
                
            }
        }
    }
    
    
    //MARK: Button Events
    
    func captureButtonTapped(sender : UIButton) {
        
        if !self.overlayView.hidden {
            
            UIView.animateWithDuration(0.15, animations: { () -> Void in
                self.overlayView.alpha = 0.0
                }, completion: { (completed) -> Void in
                    self.overlayView.hidden = true
            })
            
            
        } else if capturedImage == nil {
            
            self.takePicture()
            
        } else {
            
        }
        
        
    }
    
    
    func sendButtonTapped(sender : UIButton) {
        
        SVProgressHUD.showWithMaskType(.Clear)
        
        let resized = resizeImage(capturedImage!, targetSize: CGSizeMake(768, 1024))
        
        SpotOperations.reportParkingRule(resized, location: location!.coordinate, spotId: spotId, completion: { (completed) -> Void in
            
            
            
            if (completed) {
                SVProgressHUD.showSuccessWithStatus("report_sent_thanks".localizedString)
                self.navigationController?.popViewControllerAnimated(true)
            } else {
                SVProgressHUD.dismiss()
                let alert = UIAlertView()
                alert.message = "report_error".localizedString
                alert.addButtonWithTitle("OK")
                alert.show()
            }
            
        })
        
    }
    
    func backButtonTapped(sender : UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    func cancelButtonTapped(sender : UIButton) {
        
        captureSession.startRunning()
        
        self.capturedImage = nil
        self.imageView.hidden = true
        self.backButton.hidden = false
        self.captureButton.hidden = false
        self.cancelButton.hidden = true
        self.sendButton.hidden = true
    }
    
    
    
    
    //MARK: CLLocationManagerDelegate
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        if streetName == nil && !updatingLocation {
            
            updatingLocation = true
            let location = locations.last as! CLLocation
            self.location = location
            
            SearchOperations.getStreetName(location.coordinate, completion: { (result) -> Void in
                self.streetName = result
                self.overlayView.streetNameLabel.text = self.streetName
            })
            
            
        }
        
    }
    
    
    //MARK : Helpers
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
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
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.drawInRect(rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
}
