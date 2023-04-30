//
//  ControlPanel.swift
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

final class ControlPanel: UIStackView, ControlPanelView {
    
    var isHided: Bool {
        get { return isHidden }
        set {
            arrangedSubviews.forEach { $0.isHidden = newValue }
            isHidden = newValue
        }
    }
    
    var delegate: ControlPanelViewDelegate?
    
     let leftButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setImage(UIImage(named: "left")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.widthAnchor.constraint(equalToConstant: 60).isActive = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return button
    }()
    
     let rightButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setImage(UIImage(named: "right")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.widthAnchor.constraint(equalToConstant: 60).isActive = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return button
    }()
    
     let forwardButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setImage(UIImage(named: "forward")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.widthAnchor.constraint(equalToConstant: 60).isActive = true
        button.heightAnchor.constraint(equalToConstant: 60).isActive = true
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let superview = superview else { return }
        NSLayoutConstraint.activate([
            
            leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: 16),
            trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -16),
            bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -16)

        ])
    }
    
    private func setup() {
        isHided = true
        axis = .horizontal
        distribution = .equalSpacing
        alignment = .center
        spacing = 10
        addArrangedSubview(leftButton)
        addArrangedSubview(forwardButton)
        addArrangedSubview(rightButton)
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        leftButton.addTarget(self, action: #selector(leftAction), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(rightAction), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(forwardAction), for: .touchUpInside)
    }
    
}

extension ControlPanel {
    @objc func leftAction() {
        delegate?.leftButtonPressed()
        }
        
        @objc func rightAction() {
            delegate?.rightButtonPressed()
        }
        
        @objc func forwardAction() {
            delegate?.forwardButtonPressed()
        }
}
