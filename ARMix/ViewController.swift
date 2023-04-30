import UIKit
import SceneKit
import ARKit

enum Nodes: String {
    case cubeNode
    var name: String { return self.rawValue }
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
        
        configureViews()
        configureGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addARSCNViewConfiguration()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    // MARK: - Configure Views
    
    private func configureViews() {
        view.addSubview(sceneView)
        view.addSubview(controlPanel)
        
        sceneView.equalToSuperview()
        sceneView.delegate = self
        controlPanel.delegate = self
        addARSCNViewConfiguration()
    }
    
    private func configureGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        sceneView.addGestureRecognizer(tapGesture)
        sceneView.addGestureRecognizer(longPressGesture)
        sceneView.scene.rootNode.addChildNode(cubesNode)
    }
    
    private func addARSCNViewConfiguration() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        addAmbientLight(for: &sceneView)
    }
    
    private func addAmbientLight(for scene: inout ARSCNView) {
        
        // here we use the illumination estimation to adjust the virtual lighting in the scene
        guard let lightEstimation = scene.session.currentFrame?.lightEstimate else { return }
        
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = lightEstimation.ambientIntensity
        ambientLight.temperature = lightEstimation.ambientColorTemperature
        
        scene.scene.rootNode.light = ambientLight
        scene.scene.rootNode.categoryBitMask = 1
    }
    
    @objc func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        // Check if there are still cubes left
        defer { if cubesNode.hasChildNodes() { controlPanel.isHided = false } }  // Hiding the cube control buttons
        
        
        // Determining the touch position on the screen
        let location = gestureRecognizer.location(in: sceneView)
        
        // Define the nodes that the user clicked on
        let hitTestResults = sceneView.hitTest(location, options: [:])
        
        var hitCube = false
        
        // Check if there is a cube among them
        for hitTestResult in hitTestResults {
            if hitTestResult.node.name == Nodes.cubeNode.name {
                
                cubesNode.changeCubeColor(cubeNode: hitTestResult.node, color: UIColor.randomColor())
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
                let cubeNode = cubesNode.createColoredCubeNode(color: UIColor.randomColor())
                cubeNode.position = SCNVector3(position.x, position.y, position.z)
                cubesNode.addChildNode(cubeNode)
                
            }
        }
    }
    
    @objc func handleLongPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        // Check if there are still cubes left
        defer { if !cubesNode.hasChildNodes() { controlPanel.isHided = true } } // Hiding the cube control buttons
        
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
    
//    func createCubeNode() -> SCNNode {
//        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.003)
//        let cubeNode = SCNNode(geometry: cube)
//        cubeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
//        return cubeNode
//    }
//
//    func createColoredCubeNode(color: UIColor) -> SCNNode {
//        let cubeGeometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.003)
//        cubeGeometry.firstMaterial?.diffuse.contents = color
//
//        let cubeNode = SCNNode(geometry: cubeGeometry)
//        cubeNode.name = Nodes.cubeNode.name
//
//        return cubeNode
//    }
//    func changeCubeColor(cubeNode: SCNNode, color: UIColor) {
//        cubeNode.geometry?.firstMaterial?.diffuse.contents = color
//    }
//
//    func hasCubes() -> Bool {
//        return !cubesNode.childNodes.isEmpty
//    }
//
//    func moveCube(direction: SCNVector3) {
//        for cube in cubesNode.childNodes {
//            let currentPosition = cube.position
//            cube.position = currentPosition + direction
//        }
//    }
    
}

extension ViewController: ControlPanelViewDelegate {
    
    func leftButtonPressed() {
        cubesNode.moveChildNodes(direction: SCNVector3(-0.30, 0, 0))
    }
    
    func rightButtonPressed() {
        cubesNode.moveChildNodes(direction: SCNVector3(0.30, 0, 0))
    }
    
    func forwardButtonPressed() {
        cubesNode.moveChildNodes(direction: SCNVector3(0, 0, -0.30))
    }
    
}

