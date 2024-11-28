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
        
        // 设置 SCNView 并确保覆盖整个屏幕
        sceneView = SCNView(frame: self.view.bounds)
        self.view.addSubview(sceneView)
        
        // 创建场景
        scene = SCNScene()
        sceneView.scene = scene
        sceneView.backgroundColor = .black
        
        // 添加相机
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 5)

        // 添加一个背景平面用于hit testing
        let plane = SCNPlane(width: 10, height: 10)
        let planeMaterial = SCNMaterial()
        planeMaterial.diffuse.contents = UIColor.darkGray
        plane.materials = [planeMaterial]
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3(0, 0, -2)
        scene.rootNode.addChildNode(planeNode)

        // 添加一些立方体作为场景物体
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
        
        // 创建手电筒 (Spotlight)
        flashlight = SCNLight()
        flashlight.type = .spot
        flashlight.spotOuterAngle = 15  // 减小光照角度
        flashlight.spotInnerAngle = 10
        flashlight.intensity = 0
        flashlight.castsShadow = true
        flashlight.shadowRadius = 8
        flashlight.shadowColor = UIColor.black.withAlphaComponent(0.8)
        
        flashlightNode = SCNNode()
        flashlightNode.light = flashlight
        flashlightNode.position = SCNVector3(0, 0, 3)
        scene.rootNode.addChildNode(flashlightNode)
        
        // 创建光束效果
        let beamHeight: CGFloat = 5.0
        let topRadius: CGFloat = 0.02  // 更细的顶部
        let bottomRadius: CGFloat = 0.08  // 适中的底部宽度
        let beam = SCNCone(topRadius: topRadius, bottomRadius: bottomRadius, height: beamHeight)
        let beamMaterial = SCNMaterial()
        beamMaterial.diffuse.contents = UIColor(red: 1.0, green: 0.4, blue: 0.7, alpha: 1.0)  // 粉色
        beamMaterial.transparency = 0.8  // 更透明
        beamMaterial.lightingModel = .constant
        beamMaterial.writesToDepthBuffer = false
        beamMaterial.readsFromDepthBuffer = false
        beam.materials = [beamMaterial]
        
        beamNode = SCNNode(geometry: beam)
        beamNode.rotation = SCNVector4(1, 0, 0, Float.pi / 2)
        beamNode.position = SCNVector3(0, 0, -beamHeight/2)
        beamNode.opacity = 0
        flashlightNode.addChildNode(beamNode)
        
        // 只使用 Pan 手势识别器
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        sceneView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: sceneView)
        
        // 将2D点转换为3D射线
        let p = SCNVector3(Float(location.x) / Float(sceneView.bounds.width) * 2 - 1,
                          -Float(location.y) / Float(sceneView.bounds.height) * 2 + 1,
                          -1)
        
        // 计算手电筒朝向
        let direction = SCNVector3(
            x: p.x * 2,
            y: p.y * 2,
            z: -1
        )
        
        // 更新手电筒朝向
        let lookAt = SCNVector3(
            flashlightNode.position.x + direction.x,
            flashlightNode.position.y + direction.y,
            flashlightNode.position.z + direction.z
        )
        flashlightNode.look(at: lookAt)
        
        // 当正在触摸时打开手电筒
        if gesture.state == .began || gesture.state == .changed {
            flashlight.intensity = 1500
            beamNode.opacity = 0.5  // 更低的不透明度
        } else {
            flashlight.intensity = 0
            beamNode.opacity = 0
        }
    }
}
