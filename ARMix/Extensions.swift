//
//  Extensions.swift
//  ARMix
//
//  Created by Роман Васильев on 30.04.2023.
//

import UIKit
import SceneKit

extension SCNVector3 {
    static func +(lhs: SCNVector3, rhs: SCNVector3) -> SCNVector3 {
        return SCNVector3(lhs.x + rhs.x, lhs.y + rhs.y, lhs.z + rhs.z)
    }
}

extension SCNNode {
     func createCubeNode() -> SCNNode {
        let cube = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.003)
        let cubeNode = SCNNode(geometry: cube)
        cubeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        return cubeNode
    }
    
     func createColoredCubeNode(color: UIColor) -> SCNNode {
        let cubeGeometry = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0.003)
        cubeGeometry.firstMaterial?.diffuse.contents = color
        
        let cubeNode = SCNNode(geometry: cubeGeometry)
        cubeNode.name = Nodes.cubeNode.name
        
        return cubeNode
    }
     func changeCubeColor(cubeNode: SCNNode, color: UIColor) {
        cubeNode.geometry?.firstMaterial?.diffuse.contents = color
    }
    
    func hasChildNodes() -> Bool {
        return !childNodes.isEmpty
    }
    
    func moveChildNodes(direction: SCNVector3) {
        for childNode in childNodes {
            let currentPosition = childNode.position
            childNode.position = currentPosition + direction
        }
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
