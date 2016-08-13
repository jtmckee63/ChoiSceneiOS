//
//  CameraViewController.swift
//  ChoiScene
//
//  Created by Cameron Eubank on 8/13/16.
//  Copyright © 2016 AustiNight. All rights reserved.
//

import UIKit
import CoreImage
import QuartzCore
import UIKit
import GLKit
import AVFoundation

class CameraViewController: UIViewController{
    
    var captureSession : AVCaptureSession?
    var stillImageOutput : AVCaptureStillImageOutput?
    var previewLayer : AVCaptureVideoPreviewLayer?
    var cameraView = UIView()
    var tempImageView = UIImageView()
    var backImageView = UIImageView()
    var didTakePhoto = Bool()
    var instructionLabel = UILabel()
    
    
    @IBOutlet var discardButton: UIButton!
    @IBOutlet var postButton: UIButton!
    
    var postCheck:Bool?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.width)
        cameraView.center = view.center
        view.addSubview(cameraView)
        
        instructionLabel.frame = CGRect(x: 0, y: self.view.frame.height - 50, width: self.view.frame.width, height: 50)
        instructionLabel.textAlignment = .Center
        instructionLabel.text = "Shake to flip cameras!"
        instructionLabel.alpha = 0.35
        instructionLabel.textColor = UIColor.whiteColor()
        view.addSubview(instructionLabel)
        
        tempImageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.width)
        tempImageView.center = view.center
        view.addSubview(tempImageView)
        
        //scale correctly
        cameraView.contentMode = UIViewContentMode.ScaleAspectFill
        tempImageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        cameraView.clipsToBounds = true
        tempImageView.clipsToBounds = true
        
        
        backImageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        backImageView.center = view.center
        view.addSubview(backImageView)
        
        var blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        var blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        backImageView.addSubview(blurEffectView)
        
        
        backImageView.layer.zPosition = 0
        blurEffectView.layer.zPosition = 1
        
        cameraView.layer.zPosition = 2
        tempImageView.layer.zPosition = 2
        
        discardButton.layer.zPosition = 3
        postButton.layer.zPosition = 3
        
        // post and discard buttons
        self.discardButton.hidden = true
        self.postButton.hidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        previewLayer?.frame = cameraView.bounds
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        postButton.hidden = true
        discardButton.hidden = true
        
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = AVCaptureSessionPreset1920x1080
        
        let backCamera = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        
        var error : NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: backCamera)
            tempImageView.transform = CGAffineTransformMakeScale(1, 1)
        } catch let error1 as NSError {
            error = error1
            input = nil
        }
        
        if (error == nil && captureSession?.canAddInput(input) != nil){
            
            captureSession?.addInput(input)
            
            stillImageOutput = AVCaptureStillImageOutput()
            stillImageOutput?.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
            
            if (captureSession?.canAddOutput(stillImageOutput) != nil){
                captureSession?.addOutput(stillImageOutput)
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer?.connection.videoOrientation = AVCaptureVideoOrientation.Portrait
                cameraView.layer.addSublayer(previewLayer!)
                backImageView.image = tempImageView.image
                
                captureSession?.startRunning()
            }
        }
    }
    
    func didPressTakePhoto(){
        
        if let videoConnection = stillImageOutput?.connectionWithMediaType(AVMediaTypeVideo){
            videoConnection.videoOrientation = AVCaptureVideoOrientation.Portrait
            stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {
                (sampleBuffer, error) in
                
                if sampleBuffer != nil {
                    
                    var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(sampleBuffer)
                    var dataProvider  = CGDataProviderCreateWithCFData(imageData)
                    var cgImageRef = CGImageCreateWithJPEGDataProvider(dataProvider, nil, true, CGColorRenderingIntent.RenderingIntentDefault)
                    var image = UIImage(CGImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.Right)
                    
                    
                    
                    self.tempImageView.image = image
                    self.tempImageView.hidden = false
                    
                    self.backImageView.image = self.tempImageView.image
                    
                    self.discardButton.hidden = false
                    self.postButton.hidden = false
                    
                }
            })
        }
        
        
    }
    
    func didPressTakeAnother(){
        if didTakePhoto == true{
            tempImageView.hidden = true
            didTakePhoto = false
            
        }
        else{
            captureSession?.startRunning()
            didTakePhoto = true
            didPressTakePhoto()
        }
    }
    
    func cameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        for device in devices {
            print(device)
            if device.position == position {
                return device as? AVCaptureDevice
            }
        }
        return nil
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        didPressTakeAnother()
        
        //discad and post buttons
        
        if postCheck == true {
            
            self.discardButton.hidden = true
            self.postButton.hidden = true
            
        }
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake{
            if let sess = captureSession {
                let currentCameraInput: AVCaptureInput = sess.inputs[0] as! AVCaptureInput
                sess.removeInput(currentCameraInput)
                var newCamera: AVCaptureDevice
                if (currentCameraInput as! AVCaptureDeviceInput).device.position == .Front {
                    newCamera = self.cameraWithPosition(.Back)!
                } else {
                    newCamera = self.cameraWithPosition(.Front)!
                }
                
                do
                {
                    let captureDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
                    let input = try AVCaptureDeviceInput(device: newCamera)
                    captureSession!.sessionPreset = AVCaptureSessionPresetHigh
                    captureSession!.addInput(input)
                    tempImageView.transform = CGAffineTransformMakeScale(-1, 1)
                }
                catch let error as NSError {
                    print(error)
                }
            }
        }
    }
    
    @IBAction func discardTouch(sender: AnyObject) {
        didPressTakeAnother()
        
        //discad and post buttons
        self.discardButton.hidden = true
        self.postButton.hidden = true
    }
    @IBAction func postTouch(sender: AnyObject) {
        postCheck = true
        print(postCheck)
        
        postButton.hidden = true
        discardButton.hidden = true
        
        var ant = tempImageView.image
        self.performSegueWithIdentifier("showPost", sender: self)
    }
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "showPost") {
            guard let postViewController = segue.destinationViewController as? PostViewController else{
                return
            }
            postViewController.image = tempImageView.image!
        }
    }
    
    
    
}