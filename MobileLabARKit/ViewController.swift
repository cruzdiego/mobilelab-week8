//
//  ViewController.swift
//  MobileLabARKit
//
//  Created by Nien Lam on 3/21/18.
//  Copyright © 2018 Mobile Lab. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

enum LaserCutterModel: String {
    case notReserved = "plane"
    case reserved = "orange"
    case reservedByMe = "box"
    
    var name: String {
        return self.rawValue
    }
}

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    var mainScene: SCNScene!
    var modelAssetScene: SCNScene!
    var notReservedNode: SCNNode?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.showsStatistics = false

        // Main scene of project.
        mainScene = SCNScene(named: "art.scnassets/main_scene.scn")!
        // Set the scene to the view
        sceneView.scene = mainScene
        // Scene for model assets.
        modelAssetScene = SCNScene(named: "art.scnassets/model_asset_scene.scn")!
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("ARKit not supported")
        }

        // Start the view's AR session with a configuration that uses the rear camera,
        // device position and orientation tracking, and plane detection.
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        sceneView.session.run(configuration)
        
        // Prevent the screen from being dimmed after a while as users will likely
        // have long periods of interaction without touching the screen or buttons.
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's session
        sceneView.session.pause()
    }

    //MARK: - Actions
    @IBAction func insertLaserCutterReservedObjectPressed(_ sender: UIButton) {
        placeModelInPlace(.reserved)
    }
    
    @IBAction func insertLaserCutterNotReservedObjectPressed(_ sender: UIButton) {
        placeModelInPlace(.notReserved)
    }
    
    @IBAction func reserveLaserCutterPressed(_ sender: UIButton) {
        guard let notReservedNode = notReservedNode else {
            return
        }
        
        replaceNode(notReservedNode, with: .reservedByMe)
    }
    
    private func placeModelInPlace(_ model: LaserCutterModel){
        if let node =  node(for: model){
            placeNodeInPlace(node)
            
            if model == .notReserved {
                notReservedNode = node
            }
        }
    }
    
    private func replaceNode(_ replacingNode:SCNNode,with model: LaserCutterModel) {
        guard let newNode = node(for: model) else {
            return
        }
        
        newNode.position = replacingNode.position
        replacingNode.removeFromParentNode()
        sceneView.scene.rootNode.addChildNode(newNode)
    }
    
    private func node(for model:LaserCutterModel) -> SCNNode?{
        return modelAssetScene.rootNode.childNode(withName: model.name, recursively: true)
    }
    
    private func placeNodeInPlace(_ node: SCNNode) {
        guard let currentFrame = sceneView.session.currentFrame else {
            return
        }
        
        var translation = matrix_identity_float4x4
        translation.columns.3.z = -0.1
        
        let currentScale = node.simdScale
        node.simdTransform = matrix_multiply(currentFrame.camera.transform, translation)
        node.simdScale = currentScale
        
        sceneView.scene.rootNode.addChildNode(node)
    }
}
