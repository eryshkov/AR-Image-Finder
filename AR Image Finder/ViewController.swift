//
//  ViewController.swift
//  AR Image Finder
//
//  Created by Evgeniy Ryshkov on 20.09.2018.
//  Copyright © 2018 Evgeniy Ryshkov. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var moneyCount: Int = 0
    var anchorsArray = [ARAnchor]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        let referenceImages =
            ARReferenceImage.referenceImages(inGroupNamed: "AR Resources",
                                             bundle: nil)!
        
        configuration.detectionImages = referenceImages
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        
        //        print(#function, "Найдена картинка \(imageAnchor.referenceImage.name ?? "")")
        
        switch anchor {
        case let imageAnchor as ARImageAnchor:
            nodeAdded(node, for: imageAnchor)
        case let planeAnchor as ARPlaneAnchor:
            nodeAdded(node, for: imageAnchor)
        default:
            print("Нашли якорь, но это не плоскость и не картинка")
        }
    }
    
    func nodeAdded(_ node: SCNNode, for imageAnchor: ARImageAnchor) {
        let referenceImage = imageAnchor.referenceImage
        
        let plane = SCNPlane(width: referenceImage.physicalSize.width,
                             height: referenceImage.physicalSize.height)
        
        plane.firstMaterial?.diffuse.contents = UIColor.blue
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.opacity = 0.25
        planeNode.eulerAngles.x = -Float.pi / 2
        
        if isCoordsEqual(element: imageAnchor, accuracy: 0.001, array: anchorsArray) {
            sceneView.session.remove(anchor: imageAnchor)
        }else{
            moneyCount += 1
            anchorsArray.append(imageAnchor)
            planeNode.name = "\(moneyCount) \(referenceImage.name ?? "")"
            node.addChildNode(planeNode)
        }
        print("moneyCount=\(moneyCount)")
        print("anchors=\(anchorsArray.count)")
    }
    
    func isCoordsEqual(element: ARAnchor, accuracy: Float, array: [ARAnchor]) -> Bool {
        for item in array {
//                        let x = element.transform.columns.3.x - item.transform.columns.3.x
//                        let y = element.transform.columns.3.y - item.transform.columns.3.y
//                        let z = element.transform.columns.3.z - item.transform.columns.3.z
//                        let length = x*x + y*y + z*z
//
//                        if length <= accuracy*accuracy {return true}
            if simd_almost_equal_elements_relative(element.transform, item.transform, accuracy) {return true}
            
        }
        return false
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
