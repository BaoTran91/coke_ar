//
//  ViewController.swift
//  Gesture-Recognition-101-CoreML-ARKit
//
//  Created by Hanley Weng on 10/22/17.
//  Copyright © 2017 Emerging Interactions. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision
import AVKit
import AVFoundation
import CoreMedia

class ViewController: UIViewController, ARSCNViewDelegate {
    var vid: String?
    var topPredictionName: String?
    var first: Bool?
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var debugTextView: UITextView!
    @IBOutlet weak var textOverlay: UITextField!
    @IBOutlet weak var imageLayer: UIImageView!
    var player: AVPlayer!
    var avpController = AVPlayerViewController()
    
    var workItem: DispatchWorkItem = DispatchWorkItem.init(block: {print("init")})
    var visionRequests = [VNRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print(error)
        }
        
    
        // --- ML & VISION ---
        
        // Setup Vision Model
        guard let selectedModel = try? VNCoreMLModel(for: coke().model) else {
            fatalError("Could not load model. Ensure model has been drag and dropped (copied) to XCode Project. Also ensure the model is part of a target (see: https://stackoverflow.com/questions/45884085/model-is-not-part-of-any-target-add-the-model-to-a-target-to-enable-generation ")
        }
        
        // Set up Vision-CoreML Request
        let classificationRequest = VNCoreMLRequest(model: selectedModel, completionHandler: classificationCompleteHandler)
        classificationRequest.imageCropAndScaleOption = VNImageCropAndScaleOption.centerCrop // Crop from centre of images and scale to appropriate size.
        visionRequests = [classificationRequest]
        
    }
    
    
    
    private func makeDinosaurVideo(size: CGSize) -> SCNNode? {
        // 1
        guard let videoURL = Bundle.main.url(forResource: "coke",
                                             withExtension: "mp4") else {
                                                return nil
        }
        
        // 2
        let avPlayerItem = AVPlayerItem(url: videoURL)
        let avPlayer = AVPlayer(playerItem: avPlayerItem)
        avPlayer.play()
        
        // 3
        NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: nil,
            queue: nil) { notification in
                avPlayer.seek(to: .zero)
                avPlayer.play()
        }
        
        // 4
        let avMaterial = SCNMaterial()
        avMaterial.diffuse.contents = avPlayer
        
        // 5
        let videoPlane = SCNPlane(width: size.width, height: size.height)
        videoPlane.materials = [avMaterial]
        
        // 6
        let videoNode = SCNNode(geometry: videoPlane)
        videoNode.eulerAngles.x = -.pi / 2
        return videoNode
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("view will appear")
        topPredictionName = "NA"
        
        // --- ARKIT ---
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("view did appear")
        first = true
        
        // Begin Loop to Update CoreML
        loopCoreMLUpdate()
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
        }
    }
    
    private func handleFoundImage(_ node: SCNNode) {

        //let size = imageAnchor.referenceImage.physicalSize
        let size = CGSize(width: 20, height: 30)
        if let videoNode = makeDinosaurVideo(size: size) {
            node.addChildNode(videoNode)
            node.opacity = 1
        }
    }
    
    // MARK: - MACHINE LEARNING
    
    func loopCoreMLUpdate() {
        // Continuously run CoreML whenever it's ready. (Preventing 'hiccups' in Frame Rate)
        workItem = DispatchWorkItem(block: { // Set the work item with the block you want to execute
            if self.first! {
                usleep(200000)
                self.first = false
            }
            // 1. Run Update.
            self.updateCoreML()
            // 2. Loop this function.
            self.loopCoreMLUpdate()
                
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: workItem)
    }
    
    func updateCoreML() {
        // Get Camera Image as RGB
        let pixbuff : CVPixelBuffer? = (sceneView.session.currentFrame?.capturedImage)
        if pixbuff == nil { return }
        let ciImage = CIImage(cvPixelBuffer: pixbuff!)
        
        // Prepare CoreML/Vision Request
        let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])
        
        // Run Vision Image Request
        do {
            try imageRequestHandler.perform(self.visionRequests)
        } catch {
            print(error)
        }
    }
    
    func classificationCompleteHandler(request: VNRequest, error: Error?) {
        // Catch Errors
        if error != nil {
            print("Error: " + (error?.localizedDescription)!)
            return
        }
        guard let observations = request.results else {
            print("No results")
            return
        }
        
        // Get Classifications
        let classifications = observations[0...2] // top 3 results
            .compactMap({ $0 as? VNClassificationObservation })
            .map({ "\($0.identifier) \(String(format:" : %.2f", $0.confidence))" })
            .joined(separator: "\n")
        
        // Render Classifications
        DispatchQueue.main.async {
            // Print Classifications
                // print(classifications)
                // print("-------------")
            
            // Display Debug Text on screen
            self.debugTextView.text = "TOP 3 PROBABILITIES: \n" + classifications
            
            // Display Top Symbol
            let topPrediction = classifications.components(separatedBy: "\n")[0]
            self.topPredictionName = topPrediction.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespaces)
            // Only display a prediction if confidence is above 1%
            let topPredictionScore:Float? = Float(topPrediction.components(separatedBy: ":")[1].trimmingCharacters(in: .whitespaces))
            if (topPredictionScore != nil && topPredictionScore! > 0.8) {
                
                if (self.topPredictionName == "coke") {
                        self.workItem.cancel()
                        self.vid = "coke"
                        //topPredictionName = "NA"
                        self.performSegue(withIdentifier: "playVideo", sender: self)
                    }
                    if (self.topPredictionName == "fresca") {
                        self.imageLayer.image = #imageLiteral(resourceName: "fresca")
                    }
                    if (self.topPredictionName == "fanta") {
                        self.workItem.cancel()
                        self.vid = "fanta"
                        //topPredictionName = "NA"
                        self.performSegue(withIdentifier: "playVideo", sender: self)
                    }
                    if (self.topPredictionName == "none") {
                        self.imageLayer.image = #imageLiteral(resourceName: "q")
                    }
                }
            //self.textOverlay.text = symbol
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "playVideo") {
            let vc = segue.destination as! VideoPlayer
            vc.vid = self.vid
        }
    }
    
    // MARK: - HIDE STATUS BAR
    override var prefersStatusBarHidden : Bool { return true }
}
