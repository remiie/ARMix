import UIKit
import SceneKit
import ARKit

enum Nodes: String {
    case cubeNode
    var name: String { return self.rawValue }
}

class ARViewController: UIViewController, ARSCNViewDelegate {
    
    private var sceneView = ARSCNView()
    private var cubesNode = SCNNode()
    private let controlPanel: ControlPanelView = ControlPanel()
    
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
        
        let scene = SCNScene()
        sceneView.scene = scene
        
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
        guard let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "Markers", bundle: Bundle.main) else { print("No available images"); return }
        configuration.detectionImages = trackingImages
        configuration.maximumNumberOfTrackedImages = 1
        sceneView.session.run(configuration)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        if let imageAnchor = anchor as? ARImageAnchor {
            let imageSize = imageAnchor.referenceImage.physicalSize
            let plane = SCNPlane(width: imageSize.width, height: imageSize.height)
            plane.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.1)
            
            let planeNode = SCNNode(geometry: plane)
            planeNode.eulerAngles.x = -.pi / 2
            
            let crystal = createCrystalNode()
            crystal.position = SCNVector3Zero
            crystal.position.z = 0.1
           
            planeNode.addChildNode(crystal)
            node.addChildNode(planeNode)
        }
        return node
    }

    func createCrystalNode() -> SCNNode {
        let node = SCNNode()
        guard let crystalScene = SCNScene(named: "CrystalScene.scn") else { fatalError("Failed to load scene") }
        
        for childNode in crystalScene.rootNode.childNodes { node.addChildNode(childNode) }
        return node
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
    
    // MARK: - Gesture Handlers
    
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
                print("hit")
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
}

// MARK: - Delegate
extension ARViewController: ControlPanelViewDelegate {
    
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




