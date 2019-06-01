//
//  MerchantQRCodeReaderViewController.swift
//  Example
//
//  Created by Cristiano Matte on 24/10/16.
//  Copyright © 2016 4all. All rights reserved.
//

import UIKit
import AVFoundation

class MerchantQRCodeReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    @IBOutlet weak var previewView: UIView!
    
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var transactionString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func closeButtonTouched(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        captureSession = AVCaptureSession()
        let captureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        let input = try! AVCaptureDeviceInput(device: captureDevice)
        captureSession.addInput(input)
        
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureMetadataOutput)
        
        let dispatchQueue = DispatchQueue(label: "myQueue", attributes: [])
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatchQueue)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        videoPreviewLayer.frame = previewView.layer.bounds
        previewView.layer.addSublayer(videoPreviewLayer)
        
        captureSession.startRunning()
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        if metadataObjects.count > 0 {
            let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            transactionString = metadataObj.stringValue
            
            DispatchQueue.main.async(execute: {
                self.captureSession.stopRunning()
                self.videoPreviewLayer.removeFromSuperlayer()
                self.performSegue(withIdentifier: "offlinePaymentSegue", sender: nil)
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "offlinePaymentSegue" {
            let vc = segue.destination as! MerchantOfflinePaymentViewController
            vc.transactionString = transactionString
        }
    }
}
