//
//  ReportViewController.swift
//  prkng-ios
//
//  Created by Cagdas Altinkaya on 03/06/15.
//  Copyright (c) 2015 PRKNG. All rights reserved.
//

import UIKit
import AVFoundation

class ReportViewController: AbstractViewController, NotesModalViewControllerDelegate, CLLocationManagerDelegate {
    

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
    
    var timer : Timer?
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices! {
            // Make sure this particular device supports video
            if ((device as AnyObject).hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if((device as AnyObject).position == AVCaptureDevicePosition.back) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        print("Capture device found")
                        beginSession()
                    }
                }
            }
        }
    }
    
    func setupSubviews() {
        
        previewView.backgroundColor = Styles.Colors.white

        view.addSubview(previewView)
        
        previewViewOverlay.backgroundColor = Styles.Colors.transparentBackground
        previewViewOverlay.isHidden = true
        view.addSubview(previewViewOverlay)
        
        view.addSubview(overlayView)
        
        imageView.isHidden = true
        imageView.contentMode = UIViewContentMode.scaleAspectFill
        view.addSubview(imageView)
        
        cancelButton.setImage(UIImage(named:"btn_report_cancel"), for: UIControlState())
        cancelButton.addTarget(self, action: #selector(ReportViewController.cancelButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        view.addSubview(cancelButton)
        
        sendButton.setImage(UIImage(named:"btn_sendreport"), for: UIControlState())
        sendButton.addTarget(self, action: #selector(ReportViewController.sendButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        view.addSubview(sendButton)
        
        backButton.setImage(UIImage(named:"btn_back"), for: UIControlState())
        backButton.addTarget(self, action: #selector(ReportViewController.backButtonTapped(_:)), for: UIControlEvents.touchUpInside)
        view.addSubview(backButton)
        
        captureButton.setImage(UIImage(named:"btn_takeashot"), for: UIControlState())
        captureButton.addTarget(self, action: #selector(ReportViewController.captureButtonTapped(_:)), for: UIControlEvents.touchUpInside)
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
            make.size.equalTo(CGSize(width: 24, height: 24))
            make.bottom.equalTo(self.view).offset(-38.5)
        }
        
        
        sendButton.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.view)
            make.size.equalTo(CGSize(width: 60, height: 60))
            make.bottom.equalTo(self.view).offset(-20)
        }
        
        
        backButton.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.view).multipliedBy(0.33)
            make.size.equalTo(CGSize(width: 24, height: 24))
            make.bottom.equalTo(self.view).offset(-38.5)
        }
        
        captureButton.snp_makeConstraints { (make) -> () in
            make.centerX.equalTo(self.view)
            make.size.equalTo(CGSize(width: 60, height: 60))
            make.bottom.equalTo(self.view).offset(-20)
        }
    }
    
    
    func configureDevice() {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
            } catch _ {
            }
            if (device.isFlashModeSupported(.auto)) {
                device.flashMode = .auto
            }
            device.unlockForConfiguration()
        }
        
    }
    
    func cameraPermissionError() {
        
        self.navigationController?.popViewController(animated: true)
        
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch authStatus {
        case .denied:
            self.alertToEnableCamera()
            break
        case .restricted:
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
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: "camera".localizedString, message: "enable_camera_message".localizedString, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "cancel".localizedString, style: .default, handler: nil))
            
            alert.addAction(UIAlertAction(title: "allow".localizedString, style: .cancel, handler: { (alert) -> Void in
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            }))
            self.navigationController?.present(alert, animated: true, completion: nil)
        } else {
            // Fallback on earlier versions
            //TODO: PUT SOMETHING HERE FOR IOS 7
        }
        
    }
    
    func beginSession() {
        
        configureDevice()
        
        var err : NSError? = nil
        
        if (captureDevice == nil) {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted) -> Void in
            
            DispatchQueue.main.async {
                
                do {
                    let input = try AVCaptureDeviceInput(device: self.captureDevice)
                    self.captureSession.addInput(input)
                } catch let error as NSError {
                    err = error
                } catch {
                    fatalError()
                }
                
                if err != nil || !granted {
                    //                println("error: \(err?.localizedDescription)")
                    self.cameraPermissionError()
                    return
                }
                
                self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                if self.previewLayer != nil {
                    self.previewView.layer.addSublayer(self.previewLayer!)
                }
                
                let width =  self.view.frame.height * (768.0 / 1024.0)
                self.previewLayer?.frame = CGRect(x: (self.view.frame.width - width) / 2, y: 0, width: width, height: self.view.frame.height)
                self.captureSession.startRunning()
                
                self.stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
                if self.captureSession.canAddOutput(self.stillImageOutput) {
                    self.captureSession.addOutput(self.stillImageOutput)
                }
            }
        })

    }
    
    
    func takePicture() {
        
        if let _ = stillImageOutput.connection(withMediaType: AVMediaTypeVideo) {
            
            if !(captureDevice!.isAdjustingWhiteBalance || captureDevice!.isAdjustingExposure ) {
                
                stillImageOutput.captureStillImageAsynchronously(from: stillImageOutput.connection(withMediaType: AVMediaTypeVideo))
                    { (imageDataSampleBuffer, error) -> Void in
                        
                        if error == nil {
                            
                            DispatchQueue.main.async(execute: { () -> Void in
                                
                                self.capturedImage = UIImage(data: AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer))
                                
                                
                                self.imageView.image = self.capturedImage
                                
                                self.imageView.isHidden = false
                                self.backButton.isHidden = true
                                self.captureButton.isHidden = true
                                
                                self.cancelButton.isHidden = false
                                self.sendButton.isHidden = false
                                
                                self.timer = nil
                            })
                            
                        }
                }
                
            } else {
                timer?.invalidate()
                timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ReportViewController.takePicture), userInfo: nil, repeats: false)
            }
        }
    }
    
    
    //MARK: Button Events
    
    func captureButtonTapped(_ sender : UIButton) {
        
        if !self.overlayView.isHidden {
            
            UIView.animate(withDuration: 0.15, animations: { () -> Void in
                self.overlayView.alpha = 0.0
                }, completion: { (completed) -> Void in
                    self.overlayView.isHidden = true
            })
            
            
        } else if capturedImage == nil {
            self.takePicture()
        } else {
            
        }
        
    }
    
    
    func sendButtonTapped(_ sender : UIButton?) {
        
        if notesVC == nil {
            showNotes()
            return
        }
        
        sendButton.isEnabled = false
        
        SVProgressHUD.setBackgroundColor(UIColor.clear)
        SVProgressHUD.show()
        
        let resized = capturedImage!.resizeImage(CGSize(width: 1024, height: 768))
        
        SpotOperations.reportParkingRule(resized, location: location!.coordinate, notes: notesVC?.textField.text ?? "", spotId: spotId, completion: { (completed) -> Void in
            
            if (completed) {
                self.sendButton.isEnabled = true
                SVProgressHUD.dismiss()
//                GiFHUD.dismiss()
                self.delegate?.reportDidEnd(true)
                self.navigationController?.popViewController(animated: true)
            } else {
                self.sendButton.isEnabled = true
                SVProgressHUD.dismiss()
//                GiFHUD.dismiss()
                let alert = UIAlertView()
                alert.message = "report_error".localizedString
                alert.addButton(withTitle: "OK")
                alert.show()
            }
            
        })
        
    }
    
    func backButtonTapped(_ sender : UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    func cancelButtonTapped(_ sender : UIButton) {
        
        captureSession.startRunning()
        
        self.capturedImage = nil
        self.imageView.isHidden = true
        self.backButton.isHidden = false
        self.captureButton.isHidden = false
        self.cancelButton.isHidden = true
        self.sendButton.isHidden = true
        
        dismissNotes()
    }
    
    func showNotes() {
        
        UIView.animate(withDuration: 0.15, animations: { () -> Void in
            self.previewViewOverlay.alpha = 1.0
            }, completion: { (completed) -> Void in
                self.previewViewOverlay.isHidden = false
        })
        
        self.view.bringSubview(toFront: previewViewOverlay)
        self.view.bringSubview(toFront: cancelButton)
        self.view.bringSubview(toFront: sendButton)
        
        notesVC = NotesModalViewController()
        notesVC!.delegate = self
        
        self.addChildViewController(notesVC!)
        self.view.addSubview(notesVC!.view)
        notesVC!.didMove(toParentViewController: self)
        
        notesVC!.view.snp_makeConstraints(closure: { (make) -> () in
            make.edges.equalTo(self.view)
        })
        
        notesVC!.view.alpha = 0.0
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            self.notesVC!.view.alpha = 1.0
        })
        
        self.view.bringSubview(toFront: cancelButton)
        self.view.bringSubview(toFront: sendButton)
                
    }
    
    func dismissNotes() {
        
        if let carShareingInfo = self.notesVC {
            
            UIView.animate(withDuration: 0.15, animations: { () -> Void in
                self.previewViewOverlay.alpha = 0.0
                }, completion: { (completed) -> Void in
                    self.previewViewOverlay.isHidden = true
            })

            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                carShareingInfo.view.alpha = 0.0
                }, completion: { (finished) -> Void in
                    carShareingInfo.removeFromParentViewController()
                    carShareingInfo.view.removeFromSuperview()
                    carShareingInfo.didMove(toParentViewController: nil)
                    self.notesVC = nil
            })
            
        }
        
        
    }

    //MARK: CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if streetName == nil && !updatingLocation {
            
            updatingLocation = true
            let location = locations.last as CLLocation!
            self.location = location
            
            SearchOperations.getStreetName(location.coordinate, completion: { (result) -> Void in
                self.streetName = result
                self.overlayView.streetNameLabel.text = self.streetName
            })
            
            
        }
        
    }
    
    //MARK: NotesModalViewControllerDelegate
    func didFinishWritingNotes() {
        sendButtonTapped(nil)
    }
    
}

protocol ReportViewControllerDelegate {
    func reportDidEnd(_ success: Bool)
}
