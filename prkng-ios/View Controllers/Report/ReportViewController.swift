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
    let backButon = UIButton()

    let locationManager = CLLocationManager()
    var streetName : String?
    var location : CLLocation?
    var updatingLocation : Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.startUpdatingLocation()
        
        setupSubviews()
        setupConstraints()
        
        // Do any additional setup after loading the view, typically from a nib.
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
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
        view.addSubview(imageView)
        
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
        previewLayer?.frame = self.view.bounds
        captureSession.startRunning()
    }
    
    
    func takePicture() {
        stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }
        var videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)
        
        if videoConnection != nil {
            stillImageOutput.captureStillImageAsynchronouslyFromConnection(stillImageOutput.connectionWithMediaType(AVMediaTypeVideo))
                { (imageDataSampleBuffer, error) -> Void in
                    self.imageView.hidden = false
                    self.imageView.image = UIImage(data: AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer))
            }}
    }
    
    
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
    
    
    //MARK : CLLocationManagerDelegate
    
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
