//
//  ViewController.swift
//  3DRulerAppiOS13-14
//
//  Created by Sonali Patel on 12/28/20.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var dotNode = [SCNNode]()
    var textNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont(name: "Marker Felt", size: 20.0)!]
               self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0, green: 0.5690457821, blue: 0.5746168494, alpha: 1)
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if dotNode.count == 2 {
            for node in dotNode {
                node.removeFromParentNode()
            }
            
            dotNode.removeAll()
        }
        
        guard let touch = touches.first else {
            return
        }
        let touchLocation = touch.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchLocation, options: [SCNHitTestOption.searchMode : 1])
        if let result = hitTestResult.first {
            self.addDot(at: result)
        }
    }

    func addDot(at hitResultLocation: SCNHitTestResult) {
        print(hitResultLocation.simdWorldCoordinates.x)
        
        let dotGeometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        dotGeometry.materials = [material]
        
        let dotNode = SCNNode()
        dotNode.geometry = dotGeometry
        
        dotNode.position = SCNVector3(
            hitResultLocation.simdWorldCoordinates.x,
            hitResultLocation.simdWorldCoordinates.y,
            hitResultLocation.simdWorldCoordinates.z
        )
        
        sceneView.scene.rootNode.addChildNode(dotNode)
        
        self.dotNode.append(dotNode)

        if self.dotNode.count > 1 {
            self.calculateDistance()
        }
    }
    
    func calculateDistance() {
        let startNode = dotNode[0]
        let endNode = dotNode[1]
        
        let a = endNode.position.x - startNode.position.x
        let b = endNode.position.y - startNode.position.y
        let c = endNode.position.z - startNode.position.z
        
        let aSquared = pow(a, 2)
        let bSquared = pow(b, 2)
        let cSquared = pow(c, 2)
        
        let distance = sqrt(aSquared + bSquared + cSquared)
        self.updateText(text: "\(abs(distance))", atPosition: endNode.position)
    }
    
    func updateText(text: String, atPosition position: SCNVector3) {
        textNode.removeFromParentNode()
        let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        textGeometry.materials = [material]
        
        textNode = SCNNode(geometry: textGeometry)
        
        textNode.position = SCNVector3(position.x, position.y, position.z)
        
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)

    }
    
}
