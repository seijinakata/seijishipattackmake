//
//  GameViewController.swift
//  shipattack
//
//  Created by Owner on 6/27/1399 AP.
//  Copyright © 1399 AP Owner. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let scene = SCNScene()

        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 18, z: 20)
        cameraNode.rotation = SCNVector4(x: 1, y: 0, z: 0,w:-0.4)
        cameraNode.camera?.zFar = 300

        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .spot
        lightNode.light?.color = UIColor.white
        lightNode.light?.spotOuterAngle = 180
        lightNode.light?.castsShadow = true
        lightNode.position = SCNVector3(x: 0, y: 50, z: 0)
        lightNode.rotation = SCNVector4(x: 1, y: 0, z: 0,w:-3.14/2.0)

        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.gray
        scene.rootNode.addChildNode(ambientLightNode)
        
        //floor
        let floorGround = SCNFloor();
        floorGround.firstMaterial?.diffuse.contents = UIColor.orange
        let floorNode = SCNNode();
        floorNode.geometry = floorGround
        floorNode.position = SCNVector3(x: 0, y: 0, z: 0)
        floorNode.name = "groundFloor"
        floorNode.physicsBody = SCNPhysicsBody.static()
        scene.rootNode.addChildNode(floorNode)
                
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene

        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 1.0, alpha: 1.0)
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            let hitresultNode = result.node
            
            //floortouch
            if(hitresultNode.name == "groundFloor"){
                removeship()
                createShip()
            }
            //shiptouch
            if(hitresultNode.name == "shipMesh"){
                takeOffship()
            }
        }else{
            removeBoxNode()
            createManyBoxNode()
        }
    }
    //戦闘機配置
    func createShip(){
        // create a new scene
        let shipload = SCNScene(named: "art.scnassets/ship.scn")!
        // retrieve the ship node
        let ship = shipload.rootNode.childNode(withName: "ship", recursively: true)!
        ship.position = SCNVector3(x: 0, y: 10, z: 0)
        ship.rotation = SCNVector4(x: 0, y: 1, z: 0,w:3.14)
        ship.name = "shipMesh"
        ship.physicsBody = SCNPhysicsBody.dynamic()
        let scnView = self.view as! SCNView
        scnView.scene?.rootNode.addChildNode(ship)
        // animate the 3d object
        //ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
    }
    //戦闘機削除
    func removeship(){
        let scnView = self.view as! SCNView
        let ship = scnView.scene?.rootNode.childNode(withName: "shipMesh", recursively: true)
        if(ship != nil){
            ship?.removeFromParentNode()
        }
    }
    //戦闘機発射
    func takeOffship(){
        let scnView = self.view as! SCNView
        let ship = scnView.scene?.rootNode.childNode(withName: "shipMesh", recursively: true)!
        ship?.physicsBody?.applyForce(SCNVector3(x: 0, y: 15, z: -80), asImpulse: true)
    }
    //壁配置
    func createManyBoxNode(){
        
        let startPx:Double = -22.5
        let startPy:Double = 0.0
        let stepPx:Double = 2.5
        let stepPy:Double = 1.5
        
        for px in 0..<20{
            for py in 0..<10{
                let boxPx = startPx + stepPx * Double(px)
                let boxPy = startPy + stepPy * Double(py)
                
                createBoxNode(vector3: SCNVector3(boxPx, boxPy, -50))

            }
        }
        
        
    }
    //壁生成
    func createBoxNode(vector3:SCNVector3){
        let boxGeometory = SCNBox(width: 2.5, height: 1.5, length: 4.5, chamferRadius: 0.0)
        boxGeometory.firstMaterial?.diffuse.contents = UIColor(red: randomColorNumber(), green: randomColorNumber(), blue: randomColorNumber(), alpha: 1.0)
        
        let boxGeometoryNode = SCNNode(geometry: boxGeometory)
        boxGeometoryNode.position = vector3
        boxGeometoryNode.name = "boxGeometory"
        boxGeometoryNode.physicsBody = SCNPhysicsBody.dynamic()
        //できるだけ軽く上に積み上げるため
        boxGeometoryNode.physicsBody?.mass = 0.01
        boxGeometoryNode.physicsBody?.restitution = 0.2
        
        let scnView = self.view as! SCNView
        scnView.scene?.rootNode.addChildNode(boxGeometoryNode)
    }
    //色ランダム
    func randomColorNumber()->CGFloat{
        let colorNumber = CGFloat(arc4random_uniform(100))
        return colorNumber/200.0 + 0.5
    }
    //壁削除
    func removeBoxNode(){
        let scnView = self.view as! SCNView
        
        while(scnView.scene?.rootNode.childNode(withName: "boxGeometory", recursively: true) != nil){
            let boxGeometoryNode = scnView.scene?.rootNode.childNode(withName: "boxGeometory", recursively: true)!
            boxGeometoryNode?.removeFromParentNode()
            
        }

    }
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

}
