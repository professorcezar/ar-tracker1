//
//  ViewController.swift
//  Tracker1
//
//  Created by Vladimir Cezar on 2021-02-15.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet var label: UILabel!
    
    var action = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.showsStatistics = true
         
        guard ARFaceTrackingConfiguration.isSupported else {
            fatalError("Face tracking is not supported on this device")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARFaceTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let faceMesh = ARSCNFaceGeometry(device: sceneView.device!)
        let node = SCNNode(geometry: faceMesh)
        node.geometry?.firstMaterial?.fillMode = .lines
        return node
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let faceAnchor = anchor as? ARFaceAnchor, let faceGeometry = node.geometry as? ARSCNFaceGeometry {
                faceGeometry.update(from: faceAnchor.geometry)
                expression(anchor: faceAnchor)
                
                DispatchQueue.main.async {
                    self.label.text = self.action
                }
                
            }
    }

    func expression(anchor: ARFaceAnchor) {
        let mouthSmileLeft = anchor.blendShapes[.mouthSmileLeft]
        let mouthSmileRight = anchor.blendShapes[.mouthSmileRight]
        let cheekPuff = anchor.blendShapes[.cheekPuff]
        let tongueOut = anchor.blendShapes[.tongueOut]
        let jawLeft = anchor.blendShapes[.jawLeft]
        let eyeSquintLeft = anchor.blendShapes[.eyeSquintLeft]
        
        
        self.action = "Waiting..."
     
        if ((mouthSmileLeft?.decimalValue ?? 0.0) + (mouthSmileRight?.decimalValue ?? 0.0)) > 0.9 {
            self.action = "You are smiling. "
        }
     
        if cheekPuff?.decimalValue ?? 0.0 > 0.1 {
            self.action = "Your cheeks are puffed. "
        }
     
        if tongueOut?.decimalValue ?? 0.0 > 0.1 {
            self.action = "Don't stick your tongue out! "
        }
        
        if jawLeft?.decimalValue ?? 0.0 > 0.1 {
            self.action = "You mouth is weird!"
        }
        
        if eyeSquintLeft?.decimalValue ?? 0.0 > 0.1 {
            self.action = "Are you flirting?"
        }
    }
}
