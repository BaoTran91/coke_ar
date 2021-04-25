/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import SceneKit
import ARKit
import CoreMedia

class ViewController: UIViewController {
  @IBOutlet var sceneView: ARSCNView!
  @IBOutlet weak var instructionLabel: UILabel!

  // Add configuration variables here:
  private var imageConfiguration: ARImageTrackingConfiguration?
  private var worldConfiguration: ARWorldTrackingConfiguration?

  lazy var audioSource: SCNAudioSource = {
    let source = SCNAudioSource(fileNamed: "dinosaur.wav")!
    source.loops = true
    source.load()
    return source
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    sceneView.delegate = self

    // Uncomment to show statistics such as fps and timing information
    //sceneView.showsStatistics = true

    let scene = SCNScene()
    sceneView.scene = scene

    setupImageDetection()
    
    //setupObjectDetection()
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    if let configuration = imageConfiguration {
      sceneView.session.run(configuration)
    }
    
    /*
    if let configuration = worldConfiguration {
      sceneView.debugOptions = .showFeaturePoints
      sceneView.session.run(configuration)
    }
 */
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    sceneView.session.pause()
  }

  // MARK: - Configuration functions to fill out

  private func setupImageDetection() {
    imageConfiguration = ARImageTrackingConfiguration()

    guard let referenceImages = ARReferenceImage.referenceImages(
      inGroupNamed: "AR Images", bundle: nil) else {
        fatalError("Missing expected asset catalog resources.")
    }
    imageConfiguration?.trackingImages = referenceImages
  }

  private func setupObjectDetection() {
    worldConfiguration = ARWorldTrackingConfiguration()

    guard let referenceObjects = ARReferenceObject.referenceObjects(
      inGroupNamed: "AR Objects", bundle: nil) else {
        fatalError("Missing expected asset catalog resources.")
    }

    worldConfiguration?.detectionObjects = referenceObjects

    guard let referenceImages = ARReferenceImage.referenceImages(
      inGroupNamed: "AR Images", bundle: nil) else {
        fatalError("Missing expected asset catalog resources.")
    }
    worldConfiguration?.detectionImages = referenceImages
  }

}

// MARK: -
extension ViewController: ARSessionDelegate {
  func session(_ session: ARSession, didFailWithError error: Error) {
    guard
      let error = error as? ARError,
      let code = ARError.Code(rawValue: error.errorCode)
      else { return }
    instructionLabel.isHidden = false
    switch code {
    case .cameraUnauthorized:
      instructionLabel.text = "Camera tracking is not available. Please check your camera permissions."
    default:
      instructionLabel.text = "Error starting ARKit. Please fix the app and relaunch."
    }
  }

  func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    switch camera.trackingState {
    case .limited(let reason):
      instructionLabel.isHidden = false
      switch reason {
      case .excessiveMotion:
        instructionLabel.text = "Too much motion! Slow down."
      case .initializing, .relocalizing:
        instructionLabel.text = "ARKit is doing it's thing. Move around slowly for a bit while it warms up."
      case .insufficientFeatures:
        instructionLabel.text = "Not enough features detected, try moving around a bit more or turning on the lights."
      }
    case .normal:
      instructionLabel.text = "Point the camera at image."
    case .notAvailable:
      instructionLabel.isHidden = false
      instructionLabel.text = "Camera tracking is not available."
    }
  }
}

// MARK: -
extension ViewController: ARSCNViewDelegate {
  func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
    DispatchQueue.main.async { self.instructionLabel.isHidden = true }
    if let imageAnchor = anchor as? ARImageAnchor {
      handleFoundImage(imageAnchor, node)
    
    } else if let objectAnchor = anchor as? ARObjectAnchor {
      handleFoundObject(objectAnchor, node)
    }
 
  }

  private func handleFoundImage(_ imageAnchor: ARImageAnchor, _ node: SCNNode) {
    let name = imageAnchor.referenceImage.name!
    print("you found a \(name) image")

    let size = imageAnchor.referenceImage.physicalSize
    if let videoNode = makeDinosaurVideo(size: size) {
      node.addChildNode(videoNode)
      node.opacity = 1
    }
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

  private func handleFoundObject(_ objectAnchor: ARObjectAnchor, _ node: SCNNode) {
    // 1
    let name = objectAnchor.referenceObject.name!
    print("You found a \(name) object")

    // 2
    if let facts = DinosaurFact.facts(for: name) {
      // 3
      let titleNode = createTitleNode(info: facts)
      node.addChildNode(titleNode)

      // 4
      let bullets = facts.facts.map { "• " + $0 }.joined(separator: "\n")

      // 5
      let factsNode = createInfoNode(facts: bullets)
      node.addChildNode(factsNode)
    }

    node.addAudioPlayer(SCNAudioPlayer(source: audioSource))
  }

  private func createTitleNode(info: DinosaurFact) -> SCNNode {
    let title = SCNText(string: info.name, extrusionDepth: 0.6)
    let titleNode = SCNNode(geometry: title)
    titleNode.scale = SCNVector3(0.005, 0.005, 0.01)
    titleNode.position = SCNVector3(info.titlePosition.x, info.titlePosition.y, 0)
    return titleNode
  }

  private func createInfoNode(facts: String) -> SCNNode {
    // 1
    let textGeometry = SCNText(string: facts, extrusionDepth: 0.7)
    let textNode = SCNNode(geometry: textGeometry)
    textNode.scale = SCNVector3(0.003, 0.003, 0.01)
    textNode.position = SCNVector3(0.02, 0.01, 0)

    // 2
    let material = SCNMaterial()
    material.diffuse.contents = UIColor.blue
    textGeometry.materials = [material]

    // 3
    let billboardConstraints = SCNBillboardConstraint()
    textNode.constraints = [billboardConstraints]
    return textNode
  }
}

