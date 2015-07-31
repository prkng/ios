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
    let previewViewOverlay = UIView()
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
    
    var timer : NSTimer?
    
    var notesVC: NotesModalViewController?
    
    var delegate: ReportViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.clipsToBounds = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.startUpdatingLocation()
        
        setupSubviews()
        setupConstraints()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
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
        
        previewViewOverlay.backgroundColor = Styles.Colors.transparentBackground
        previewViewOverlay.hidden = true
        view.addSubview(previewViewOverlay)
        
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
        
        previewViewOverlay.snp_makeConstraints { (make) -> () in
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
            if (device.isFlashModeSupported(.Auto)) {
                device.flashMode = .Auto
            }
            device.unlockForConfiguration()
        }
        
    }
    
    func cameraPermissionError() {
        
        self.navigationController?.popViewControllerAnimated(true)
        
        let authStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        switch authStatus {
        case .Denied:
            self.alertToEnableCamera()
            break
        case .Restricted:
            self.alertToEnableCamera()
            break
            // this case in handled in beginsession since it only happens the first time
            //            case .NotDetermined:
            //                AVCaptureDevice.requestAccessForMediaType(mediaType, completionHandler: { (granted) -> Void in
            //                    if(granted){
            //                        NSLog("Granted access to %@", mediaType);
            //                    } else {
            //                        NSLog("Not granted access to %@", mediaType);
            //                        self.alertPromptToAllowCameraAccessViaSetting()
            //                    }
            //                })
            //                break
        default: break
        }
    }
    
    func alertToEnableCamera() {
        var alert = UIAlertController(title: "camera".localizedString, message: "enable_camera_message".localizedString, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "cancel".localizedString, style: .Default, handler: nil))
        
        alert.addAction(UIAlertAction(title: "allow".localizedString, style: .Cancel, handler: { (alert) -> Void in
            UIApplication.sharedApplication().openURL(NSURL(string: UIApplicationOpenSettingsURLString)!)
        }))
        
        self.navigationController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    func beginSession() {
        
        configureDevice()
        
        var err : NSError? = nil
        
        if (captureDevice == nil) {
            self.navigationController?.popViewControllerAnimated(true)
            return
        }
        
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted) -> Void in
            
            dispatch_async(dispatch_get_main_queue()) {
                
                if let input = AVCaptureDeviceInput(device: self.captureDevice, error: &err) {
                    self.captureSession.addInput(input)
                }
                
                if err != nil || !granted {
                    //                println("error: \(err?.localizedDescription)")
                    self.cameraPermissionError()
                    return
                }
                
                self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                self.previewView.layer.addSublayer(self.previewLayer)
                
                let width =  self.view.frame.height * (768.0 / 1024.0)
                self.previewLayer?.frame = CGRectMake((self.view.frame.width - width) / 2, 0, width, self.view.frame.height)
                self.captureSession.startRunning()
                
                self.stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
                if self.captureSession.canAddOutput(self.stillImageOutput) {
                    self.captureSession.addOutput(self.stillImageOutput)
                }
            }
        })

    }
    
    
    func takePicture() {
        
        if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) {
            
            if !(captureDevice!.adjustingWhiteBalance || captureDevice!.adjustingExposure ) {
                
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
                                
                                self.timer = nil
                            })
                            
                        }
                }
                
            } else {
                timer?.invalidate()
                timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("takePicture"), userInfo: nil, repeats: false)
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
        
        if notesVC == nil {
            showNotes()
            return
        }
        
        SVProgressHUD.setBackgroundColor(UIColor.clearColor())
        SVProgressHUD.showWithMaskType(.Clear)
        
        let resized = ImageUtil.resizeImage(capturedImage!, targetSize: CGSizeMake(1024, 768))
        
        SpotOperations.reportParkingRule(resized, location: location!.coordinate, notes: notesVC?.textView.text ?? "", spotId: spotId, completion: { (completed) -> Void in
            
            if (completed) {
                SVProgressHUD.dismiss()
                self.delegate?.reportDidEnd(true)
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
        
        dismissNotes()
    }
    
    func showNotes() {
        
        UIView.animateWithDuration(0.15, animations: { () -> Void in
            self.previewViewOverlay.alpha = 1.0
            }, completion: { (completed) -> Void in
                self.previewViewOverlay.hidden = false
        })
        
        self.view.bringSubviewToFront(previewViewOverlay)
        self.view.bringSubviewToFront(cancelButton)
        self.view.bringSubviewToFront(sendButton)
        
        notesVC = NotesModalViewController()
        
        self.addChildViewController(notesVC!)
        self.view.addSubview(notesVC!.view)
        notesVC!.didMoveToParentViewController(self)
        
        notesVC!.view.snp_makeConstraints({ (make) -> () in
            make.edges.equalTo(self.view)
        })
        
        notesVC!.view.alpha = 0.0
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.notesVC!.view.alpha = 1.0
        })
        
        self.view.bringSubviewToFront(cancelButton)
        self.view.bringSubviewToFront(sendButton)
                
    }
    
    func dismissNotes() {
        
        if let carShareingInfo = self.notesVC {
            
            UIView.animateWithDuration(0.15, animations: { () -> Void in
                self.previewViewOverlay.alpha = 0.0
                }, completion: { (completed) -> Void in
                    self.previewViewOverlay.hidden = true
            })

            UIView.animateWithDuration(0.2, animations: { () -> Void in
                carShareingInfo.view.alpha = 0.0
                }, completion: { (finished) -> Void in
                    carShareingInfo.removeFromParentViewController()
                    carShareingInfo.view.removeFromSuperview()
                    carShareingInfo.didMoveToParentViewController(nil)
                    self.notesVC = nil
            })
            
        }
        
        
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
    
}

protocol ReportViewControllerDelegate {
    func reportDidEnd(success: Bool)
}