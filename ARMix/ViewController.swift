import UIKit
import SceneKit
import ARKit

extension SCNVector3 {
    static func +(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        return SCNVector3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }
}

class ViewController: UIViewController, ARSCNViewDelegate {
    
    let sceneView: ARSCNView = {
        let view = ARSCNView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let cubesNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(sceneView)
        
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration)
        sceneView.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        sceneView.addGestureRecognizer(tapGesture)
        sceneView.scene.rootNode.addChildNode(cubesNode)
        
        let leftButton = UIButton(type: .system)
        leftButton.tintColor = .white
        leftButton.setImage(UIImage(named: "left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        leftButton.addTarget(self, action: #selector(leftButtonPressed), for: .touchUpInside)
        view.addSubview(leftButton)
        
        let rightButton = UIButton(type: .system)
        rightButton.tintColor = .white
        rightButton.setImage(UIImage(named: "right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        rightButton.addTarget(self, action: #selector(rightButtonPressed), for: .touchUpInside)
        view.addSubview(rightButton)
        
        let forwardButton = UIButton(type: .system)
        forwardButton.tintColor = .white
        forwardButton.setImage(UIImage(named: "forward")?.withRenderingMode(.alwaysTemplate), for: .normal)
        forwardButton.addTarget(self, action: #selector(forwardButtonPressed), for: .touchUpInside)
        view.addSubview(forwardButton)
        
        leftButton.isHidden = true
        rightButton.isHidden = true
        forwardButton.isHidden = true
        
        view.addSubview(leftButton)
        view.addSubview(rightButton)
        view.addSubview(forwardButton)
        leftButton.translatesAutoresizingMaskIntoConstraints = false
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        forwardButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            leftButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            leftButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            leftButton.heightAnchor.constraint(equalToConstant: 60),
            leftButton.widthAnchor.constraint(equalToConstant: 60),
            
            forwardButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            forwardButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            forwardButton.widthAnchor.constraint(equalToConstant: 60),
            forwardButton.heightAnchor.constraint(equalToConstant: 60),
            
            rightButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            rightButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            rightButton.heightAnchor.constraint(equalToConstant: 60),
            rightButton.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc func leftButtonPressed() {
            moveCube(direction: SCNVector3(-0.30, 0, 0))
        }
        
        @objc func rightButtonPressed() {
            moveCube(direction: SCNVector3(0.30, 0, 0))
        }
        
        @objc func forwardButtonPressed() {
            moveCube(direction: SCNVector3(0, 0, -0.30))
        }
    
    func moveCube(direction: SCNVector3) {
        print("change direction")
        
        for cube in cubesNode.childNodes {
            let currentPosition = cube.position
              cube.position = currentPosition + direction
          }
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
        guard let lightEstimation = sceneView.session.currentFrame?.lightEstimate else { return }
        
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = lightEstimation.ambientIntensity
        ambientLight.temperature = lightEstimation.ambientColorTemperature
        
        sceneView.scene.rootNode.light = ambientLight
        sceneView.scene.rootNode.categoryBitMask = 1
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        let results = sceneView.hitTest(location, types: [.existingPlaneUsingExtent, .estimatedHorizontalPlane])
        if let hitTestResult = results.first {
            let position = hitTestResult.worldTransform.columns.3
            let cubeNode = createCubeNode()
            cubeNode.position = SCNVector3(position.x, position.y, position.z)
            cubesNode.addChildNode(cubeNode)
          //  sceneView.scene.rootNode.addChildNode(cubeNode)
            view.subviews.forEach { $0.isHidden = false }
        }
    }
    
    
    func createCubeNode() -> SCNNode {
        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.0)
        let cubeNode = SCNNode(geometry: cube)
        cubeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        return cubeNode
    }

}

