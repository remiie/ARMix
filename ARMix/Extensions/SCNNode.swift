//
//  SCNNode.swift
//  ARMix
//
//  Created by Роман Васильев on 30.04.2023.
//

import SceneKit
import Foundation

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
