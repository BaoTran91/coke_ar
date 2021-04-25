//
//  ViewController.swift
//  ios_cv_n_ml
//
//  Created by Bao Tran on 2/19/19.
//  Copyright © 2019 Bao Tran. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ViewController: UIViewController {
    // video capture session
    let session = AVCaptureSession()
    // queue for processing video frames
    let captureQueue = DispatchQueue(label: "captureQueue")
    // preview layer
    var previewLayer: AVCaptureVideoPreviewLayer!
    // preview view - we'll add the previewLayer to this later
    @IBOutlet weak var previewView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // get hold of the default video camera
        guard let camera = AVCaptureDevice.default(for: .video) else {
            fatalError("No video camera available")
            //error handling needed
        }
    }


}

