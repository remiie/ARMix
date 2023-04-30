//
//  SCNVector.swift
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
