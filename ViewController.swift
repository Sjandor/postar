//
//  ViewController.swift
//  Postar
//
//  Created by Sander Huite Jan Nieuwenhuis on 15/12/2023.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Enable default lighting
        sceneView.autoenablesDefaultLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        
        // Set the AR reference images
        if let imageToTrack = ARReferenceImage.referenceImages(inGroupNamed: "Posters", bundle: Bundle.main) {
            
            configuration.trackingImages = imageToTrack
            configuration.maximumNumberOfTrackedImages = 2
            
            print("AR Markers Added!")
        }

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    // MARK: - ARSCNViewDelegate

    // Get the first child node inside a scene
    private func getPosterNode(posterName: String) -> SCNNode? {
        
        if let posterScene = SCNScene(named: "art.scnassets/\(posterName)_scene.scn") {
            
            if let posterNode = posterScene.rootNode.childNodes.first {
                print("first node found \(posterName)")
                return posterNode
                
            }
        }
        print("first node not found \(posterName)")
        return nil
    }
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
    
        // Perform tasks on the background thread
        DispatchQueue.global().async { [weak self] in
            
            // Check if the detected anchor is an ARImageAnchor
            if let imageAnchor = anchor as? ARImageAnchor {
                
                // Creating a plane geometry
                let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
                plane.firstMaterial?.diffuse.contents = UIColor(white: 1, alpha: 0.3)
                
                // Creating a plane node
                let planeNode = SCNNode(geometry: plane)
                
                // Rotate the plane node 90 degrees counter clockwise
                planeNode.eulerAngles.x = -.pi / 2
                
                // Add the 3D model
                if let posterName = imageAnchor.referenceImage.name {
                    
                    print(posterName)
                    if let posterNode = self?.getPosterNode(posterName: posterName) {
                        
                        // Rotate the node 90 degrees clockwise
                        posterNode.eulerAngles.x = .pi / 2
                        
                        // Adding nodes on the main thread
                        DispatchQueue.main.async {
                            
                            planeNode.addChildNode(posterNode)
                            node.addChildNode(planeNode)
                        }
                    }
                }
            }
        }
        
        return node
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
