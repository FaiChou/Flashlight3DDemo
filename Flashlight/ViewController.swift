import UIKit
import SceneKit

class ViewController: UIViewController {

    var sceneView: SCNView!
    var scene: SCNScene!
    var flashlight: SCNLight!
    var flashlightNode: SCNNode!
    var beamNode: SCNNode!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView = SCNView(frame: self.view.bounds)
        self.view.addSubview(sceneView)
        
        scene = SCNScene()
        sceneView.scene = scene
        sceneView.backgroundColor = .black
        
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)

        let plane = SCNPlane(width: 10, height: 10)
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = UIColor.darkGray
        plane.materials = [planeMaterial]
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3(0, 0, -2)
        scene.rootNode.addChildNode(planeNode)

        for x in -2...2 {
            for y in -2...2 {
                let box = SCNBox(width: 0.5, height: 0.5, length: 0.5, chamferRadius: 0)
                let boxMaterial = SCNMaterial()
                boxMaterial.diffuse.contents = UIColor.white
                box.materials = [boxMaterial]
                let boxNode = SCNNode(geometry: box)
                boxNode.position = SCNVector3(Float(x), Float(y), -1)
                scene.rootNode.addChildNode(boxNode)
            }
        }
        
        flashlight = SCNLight()
        flashlight.type = .spot
        flashlight.spotOuterAngle = 15
        flashlight.spotInnerAngle = 10
        flashlight.intensity = 0
        flashlight.castsShadow = true
        flashlight.shadowRadius = 8
        flashlight.shadowColor = UIColor.black.withAlphaComponent(0.8)
        
        flashlightNode = SCNNode()
        flashlightNode.light = flashlight
        flashlightNode.position = SCNVector3(0, 0, 3)
        scene.rootNode.addChildNode(flashlightNode)
        
         let beamHeight: CGFloat = 5.0
        let topRadius: CGFloat = 0.02
        let bottomRadius: CGFloat = 0.08
        let beam = SCNCone(topRadius: topRadius, bottomRadius: bottomRadius, height: beamHeight)
        let beamMaterial = SCNMaterial()
        beamMaterial.diffuse.contents = UIColor(red: 1.0, green: 0.4, blue: 0.7, alpha: 1.0)
        beamMaterial.transparency = 0.8
        beamMaterial.lightingModel = .constant
        beamMaterial.writesToDepthBuffer = false
        beamMaterial.readsFromDepthBuffer = false
        beam.materials = [beamMaterial]
        
        beamNode = SCNNode(geometry: beam)
        beamNode.rotation = SCNVector4(1, 0, 0, Float.pi / 2)
        beamNode.position = SCNVector3(0, 0, -beamHeight/2)
        beamNode.opacity = 0
        flashlightNode.addChildNode(beamNode)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        sceneView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: sceneView)
        
        let p = SCNVector3(Float(location.x) / Float(sceneView.bounds.width) * 2 - 1,
                          -Float(location.y) / Float(sceneView.bounds.height) * 2 + 1,
                          -1)
        
        let direction = SCNVector3(
            x: p.x * 2,
            y: p.y * 2,
            z: -1
        )
        
        let lookAt = SCNVector3(
            flashlightNode.position.x + direction.x,
            flashlightNode.position.y + direction.y,
            flashlightNode.position.z + direction.z
        )
        flashlightNode.look(at: lookAt)
        
        if gesture.state == .began || gesture.state == .changed {
            flashlight.intensity = 1500
            beamNode.opacity = 0.5
        } else {
            flashlight.intensity = 0
            beamNode.opacity = 0
        }
    }
}
