import UIKit
import SceneKit
import ARKit

extension SCNVector3 {
    static func +(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        return SCNVector3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }
}

extension UIColor {
    static func randomColor() -> UIColor {
        let red = CGFloat(arc4random_uniform(255)) / 255.0
        let green = CGFloat(arc4random_uniform(255)) / 255.0
        let blue = CGFloat(arc4random_uniform(255)) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
}

extension UIView {
    public func equalToSuperview() {
        translatesAutoresizingMaskIntoConstraints = false
        if let superview = superview {
            leftAnchor.constraint(equalTo: superview.leftAnchor).isActive = true
            rightAnchor.constraint(equalTo: superview.rightAnchor).isActive = true
            topAnchor.constraint(equalTo: superview.topAnchor).isActive = true
            bottomAnchor.constraint(equalTo: superview.bottomAnchor).isActive = true
        }
    }
}

enum Nodes: String {
    case cubeNode
    var name: String {
        return self.rawValue
    }
}

class ViewController: UIViewController, ARSCNViewDelegate {
    
     lazy var sceneView: ARSCNView = {
        let view = ARSCNView()
        return view
    }()
    
    let cubesNode = SCNNode()
    let controlPanel: ControlPanelView = {
        let view = ControlPanel()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(sceneView)
        view.addSubview(controlPanel)
        sceneView.equalToSuperview()
        controlPanel.delegate = self
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration)
        sceneView.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        sceneView.addGestureRecognizer(tapGesture)
        sceneView.addGestureRecognizer(longPressGesture)
        sceneView.scene.rootNode.addChildNode(cubesNode)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // here we use the illumination estimation to adjust the virtual lighting in the scene
        
        guard let lightEstimation = sceneView.session.currentFrame?.lightEstimate else { return }
        
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = lightEstimation.ambientIntensity
        ambientLight.temperature = lightEstimation.ambientColorTemperature
        
        sceneView.scene.rootNode.light = ambientLight
        sceneView.scene.rootNode.categoryBitMask = 1
    }
    
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        // Check if there are still cubes left
        defer { if hasCubes() { controlPanel.isHided = false } }  // Hiding the cube control buttons
        
        
        // Determining the touch position on the screen
        let location = gestureRecognizer.location(in: sceneView)
        
        // Define the nodes that the user clicked on
        let hitTestResults = sceneView.hitTest(location, options: [:])
        
        var hitCube = false
        
        // Check if there is a cube among them
        for hitTestResult in hitTestResults {
            if hitTestResult.node.name == Nodes.cubeNode.name {
                changeCubeColor(cubeNode: hitTestResult.node, color: UIColor.randomColor())
                // Changing the color of the cube
                hitCube = true
                break
            }
        }
        // If the user did not hit the cube, then create a new cube
        if !hitCube {
            let results = sceneView.hitTest(location, types: [.existingPlaneUsingExtent, .estimatedHorizontalPlane])
            if let hitTestResult = results.first {
                let position = hitTestResult.worldTransform.columns.3
                let cubeNode = createColoredCubeNode(color: UIColor.randomColor())
                cubeNode.position = SCNVector3(position.x, position.y, position.z)
                cubesNode.addChildNode(cubeNode)
                
            }
        }
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        // Check if there are still cubes left
        defer { if !hasCubes() { controlPanel.isHided = true } } // Hiding the cube control buttons
        
        if gestureRecognizer.state == .began {
            // Determining the touch position on the screen
            let location = gestureRecognizer.location(in: sceneView)
            
            // Define the nodes that the user clicked on
            let hitTestResults = sceneView.hitTest(location, options: [:])
            
            // Check if there is a cube among them
            for hitTestResult in hitTestResults {
                if hitTestResult.node.name == Nodes.cubeNode.name {
                    // Removing the cube
                    hitTestResult.node.removeFromParentNode()
                }
            }
        }
    }
    
    func createCubeNode() -> SCNNode {
        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.0)
        let cubeNode = SCNNode(geometry: cube)
        cubeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        return cubeNode
    }
    
    func createColoredCubeNode(color: UIColor) -> SCNNode {
        let cubeGeometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        cubeGeometry.firstMaterial?.diffuse.contents = color
        
        let cubeNode = SCNNode(geometry: cubeGeometry)
        cubeNode.name = Nodes.cubeNode.name
        
        return cubeNode
    }
    func changeCubeColor(cubeNode: SCNNode, color: UIColor) {
        cubeNode.geometry?.firstMaterial?.diffuse.contents = color
    }
    
    func hasCubes() -> Bool {
        return !cubesNode.childNodes.isEmpty
    }
    
    func moveCube(direction: SCNVector3) {
        for cube in cubesNode.childNodes {
            let currentPosition = cube.position
            cube.position = currentPosition + direction
        }
    }
    
}

extension ViewController: ControlPanelViewDelegate {
    
    func leftButtonPressed() {
        moveCube(direction: SCNVector3(-0.30, 0, 0))
    }
    
    func rightButtonPressed() {
        moveCube(direction: SCNVector3(0.30, 0, 0))
    }
    
    func forwardButtonPressed() {
        moveCube(direction: SCNVector3(0, 0, -0.30))
    }
    
}

