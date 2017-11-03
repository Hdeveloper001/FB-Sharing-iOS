//
//  CameraViewController.swift
//  Sharescore
//
//  Created by iOSpro on 3/12/17.
//  Copyright © 2017 iOSpro. All rights reserved.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var btn_TakePhoto: UIButton!
    @IBOutlet weak var btn_Next: UIButton!
    
    var captureSession = AVCaptureSession()
    var stillImageOutput = AVCaptureStillImageOutput()
    var error: NSError?
    var captureDevice : AVCaptureDevice?
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    var photoTaken : Bool = false
    var selectedImage : UIImage? = nil
    
    //MARK: - Life cycle functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(backToHomeNavigationViewController), name: NSNotification.Name(rawValue: "BackToHomeNavigationView"), object: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        captureSession.sessionPreset = AVCaptureSessionPresetLow
        
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapToFocus))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.numberOfTouchesRequired = 1
        cameraView.addGestureRecognizer(tapGesture)
    }
    
    func tapToFocus(sender: UITapGestureRecognizer){
        let touchPoint: CGPoint = sender.location(in: self.cameraView)
        let convertedPoint: CGPoint = previewLayer!.captureDevicePointOfInterest(for: touchPoint)
        
        if let device = captureDevice {
            if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(AVCaptureFocusMode.autoFocus) {
                do {
                    try device.lockForConfiguration()
                    device.focusPointOfInterest = convertedPoint
                    device.focusMode = AVCaptureFocusMode.autoFocus
                    device.exposurePointOfInterest = convertedPoint
                    device.exposureMode = AVCaptureExposureMode.continuousAutoExposure
                    device.unlockForConfiguration()
                    self.drawFocusBoxAtPointOfInterest(point: touchPoint)
                } catch {
                    print("unable to focus")
                }
            }
        }
    }
    
    func drawFocusBoxAtPointOfInterest(point: CGPoint){
        let focusBox: CALayer = CALayer()
        focusBox.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        focusBox.position = point
        focusBox.borderWidth = 1
        
        focusBox.borderColor = UIColor.yellow.cgColor
        focusBox.opacity = 0
        previewLayer?.addSublayer(focusBox)
        self.addAdjustingAnimation(to: focusBox, removeAnimation: true)
    }
    
    func addAdjustingAnimation(to layer: CALayer, removeAnimation remove: Bool) {
        if remove {
            layer.removeAnimation(forKey: "animateOpacity")
        }
        if layer.animation(forKey: "animateOpacity") == nil {
            layer.isHidden = false
            let opacityAnimation = CABasicAnimation(keyPath: "opacity")
            opacityAnimation.duration = 0.3
            opacityAnimation.repeatCount = 1.0
            opacityAnimation.autoreverses = true
            opacityAnimation.fromValue = Int(1.0)
            opacityAnimation.toValue = Int(0.0)
            layer.add(opacityAnimation, forKey: "animateOpacity")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.btn_Next.setTitle("", for: .normal)
        
        self.captureSession = AVCaptureSession()
        photoTaken = false
        stillImageOutput = AVCaptureStillImageOutput()
        selectedImage = nil
    }
    
    func focusTo(value : Float) {
        //        let device = captureDevice
        //        if device != nil {
        //            do{
        //                if((try device?.lockForConfiguration()) != nil) {
        //                    device?.setFocusModeLockedWithLensPosition(value, completionHandler: { (time) -> Void in
        //                        //
        //                    })
        //                    device?.unlockForConfiguration()
        //                }
        //
        //            }catch{
        //                abort()
        //            }
        //        }

    }
    
    let screenWidth = UIScreen.main.bounds.size.width
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let anyTouch = touches.first! as UITouch
        let touchPercent = anyTouch.location(in: self.view).x / screenWidth
        focusTo(value: Float(touchPercent))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let anyTouch = touches.first! as UITouch
        let touchPercent = anyTouch.location(in: self.view).x / screenWidth
        focusTo(value: Float(touchPercent))
    }
    
    func configureDevice() {
        if let device = captureDevice {
            do{
                try device.lockForConfiguration()
                device.focusMode = .autoFocus
                device.unlockForConfiguration()
                
            }catch{
                abort()
            }
            
        }
        
    }
    
    func beginSession() {
        
        configureDevice()
        
        let err : NSError? = nil
        do{
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
        }catch{
            if err != nil {
                print("error: \(err?.localizedDescription)")
            }
            abort()
        }
        
        captureSession.sessionPreset = AVCaptureSessionPresetPhoto
        
        stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
        if captureSession.canAddOutput(stillImageOutput) {
            captureSession.addOutput(stillImageOutput)
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.cameraView.layer.addSublayer(previewLayer!)
        
        var rect: CGRect = self.cameraView.layer.frame
        rect.origin.y = 0
        previewLayer?.frame = rect
        captureSession.startRunning()
    }
    
    //MARK: - Buttons' Events
    @IBAction func click_btn_Cancel(_ sender: Any) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func click_btn_Next(_ sender: Any) {
        
        if photoTaken{
            
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SharePhotoViewController") as! SharePhotoViewController
            viewController.img_Avatar = self.selectedImage
            self.navigationController?.pushViewController(viewController, animated: true)
        }
        else { // for test
            
            let viewController = self.storyboard?.instantiateViewController(withIdentifier: "SharePhotoViewController") as! SharePhotoViewController
           
            viewController.img_Avatar = UIImage(named: "defaultAvatar")
            self.navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    @IBAction func click_btn_TakePhoto(_ sender: Any) {
        
        if photoTaken {return}
        
        if let videoConnection = stillImageOutput.connection(withMediaType: AVMediaTypeVideo) {
            stillImageOutput.captureStillImageAsynchronously(from: videoConnection) {
                (imageDataSampleBuffer, error) -> Void in
                
                let jpegData: Data? = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer)
                var takenImage: UIImage? = UIImage(data: jpegData!)
                
                let outputRect: CGRect = self.previewLayer!.metadataOutputRectOfInterest(for: self.previewLayer!.bounds)
                let takenCGImage: CGImage? = takenImage?.cgImage
                let width: CGFloat = CGFloat(takenCGImage!.width)
                let height: CGFloat = CGFloat(takenCGImage!.height)
                let cropRect = CGRect(x: CGFloat(outputRect.origin.x * width), y: CGFloat(outputRect.origin.y * height), width: CGFloat(outputRect.size.width * width), height: CGFloat(outputRect.size.height * height))
                let cropCGImage: CGImage = takenCGImage!.cropping(to: cropRect)!
                takenImage = UIImage(cgImage: cropCGImage, scale: 1, orientation: (takenImage?.imageOrientation)!)

                if (takenImage == nil){
                    // Retake photo
                }
                else {
                    if let compressedData = UIImageJPEGRepresentation(takenImage!, 0.2) {
                        let jpgImage: UIImage? = UIImage(data: compressedData)
                        self.selectedImage = self.resizeImage(image: jpgImage!, newWidth: 500)
                    }
                }
                self.captureSession.stopRunning()
                
                // save image temporary
//                UIImageWriteToSavedPhotosAlbum(imageTake.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
                //UIImageWriteToSavedPhotosAlbum(self.selectedImage!, self, nil, nil)

                
                self.photoTaken = true
                self.btn_Next.setTitle("Next", for: .normal)
            }
        }
    }
    
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        //let scale = newWidth / image.size.width
        //let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width:newWidth, height: newWidth))
        image.draw(in: CGRect(x:0, y:0, width:newWidth, height: newWidth))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    // MARK: - PopUp to ProfileView after sharing
    func backToHomeNavigationViewController(){
        _ = self.navigationController?.popViewController(animated: false)
        _ = self.navigationController?.popViewController(animated: false)
    }
}
