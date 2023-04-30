//
//  ControlPanelProtocols.swift
//  ARMix
//
//  Created by Роман Васильев on 30.04.2023.
//

import UIKit

protocol ControlPanelView: UIStackView {
    var leftButton: UIButton { get }
    var rightButton: UIButton { get }
    var forwardButton: UIButton { get }
    var delegate: ControlPanelViewDelegate? { get set }
    var isHided: Bool { get set }
}

protocol ControlPanelViewDelegate {
    func leftButtonPressed()
    func rightButtonPressed()
    func forwardButtonPressed()
}
