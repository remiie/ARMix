//
//  UIColor.swift
//  ARMix
//
//  Created by Роман Васильев on 30.04.2023.
//

import UIKit

extension UIColor {
    static func randomColor() -> UIColor {
        let red = CGFloat(arc4random_uniform(255)) / 255.0
        let green = CGFloat(arc4random_uniform(255)) / 255.0
        let blue = CGFloat(arc4random_uniform(255)) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

