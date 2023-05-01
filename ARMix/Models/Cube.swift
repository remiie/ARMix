//
//  Cube.swift
//  ARMix
//
//  Created by Роман Васильев on 01.05.2023.
//

import Foundation

enum Nodes: String {
    case cubeNode
    var name: String { return self.rawValue }
}
enum CubeSpeed: Float {
    case normal = 0.10
    case fast = 0.20
    
    var value: Float { return self.rawValue }
}
