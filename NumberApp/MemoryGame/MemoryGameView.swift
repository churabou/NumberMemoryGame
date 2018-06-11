//
//  MemoryView.swift
//  NumberApp
//
//  Created by ちゅーたつ on 2018/06/08.
//  Copyright © 2018年 ちゅーたつ. All rights reserved.
//

import UIKit

final class MemoryGameView: BaseView {
    
    private (set) var label = UILabel()
    private (set) var passButton = UIButton()
    private (set) var clearButton = UIButton()
    private (set) var numberButtons: [UIButton] = []
    
    private var stackView = UIStackView()
    private let buttonS: CGFloat = 80
    
    override func initializeView() {
        
        backgroundColor = .white
        
        label.backgroundColor = .white
        label.textColor = .lightGray
        label.font = .boldSystemFont(ofSize: 30)
        label.textAlignment = .center
        addSubview(label)
        
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        
        (0..<4).forEach { row in
            
            let wrapperView = UIStackView()
            wrapperView.axis = .horizontal
            wrapperView.distribution = .fillEqually
            wrapperView.spacing = 10
            
            (row*3+1...row*3+3).forEach { num in
                let b = UIButton()
                b.addTarget(self, action: #selector(actionAnimation), for: .touchUpInside)
                b.layer.cornerRadius = buttonS / 2
                b.setTitleColor(.cyan, for: .normal)
                b.layer.borderWidth = 2
                b.layer.borderColor = UIColor.cyan.cgColor
                
                if num == 10 {
                    b.setTitle("clear", for: .normal)
                    clearButton = b
                } else if num == 12 {
                    b.setTitle("pass", for: .normal)
                    passButton = b
                } else {
                    let num = num == 11 ? 0 : num
                    b.tag = num
                    b.setTitle("\(num)", for: .normal)
                    numberButtons.append(b)
                }
                wrapperView.addArrangedSubview(b)
            }
            stackView.addArrangedSubview(wrapperView)
        }
        addSubview(stackView)
    }
    
    override func initializeConstraints() {
        
        stackView.chura.layout
            .top(label.anchor.bottom+40)
            .width(buttonS*3+20)
            .height(buttonS*4+30)
            .centerX(0)
        
        label.chura.layout
            .top(100).width(buttonS*3+20).height(50).centerX(0)
    }
    
    func update(active: Bool) {
        
        isUserInteractionEnabled = active
        let alpha: CGFloat = active ? 1 : 0.3
        numberButtons.forEach { $0.alpha = alpha }
        passButton.alpha = alpha
        clearButton.alpha = alpha
    }
    
    @objc private func actionAnimation(_ sender: UIButton) {
        CATransaction.begin()
        
        CATransaction.setCompletionBlock {
            sender.layer.removeAnimation(forKey: "KEY_COLOR_ANIMATION")
        }
        
        let anim = CABasicAnimation(keyPath: "backgroundColor")
        anim.fromValue = UIColor.lightBlue.cgColor
        anim.toValue = UIColor.clear.cgColor
        anim.duration = 0.2
        sender.layer.add(anim, forKey: "KEY_COLOR_ANIMATION")
        
        CATransaction.commit()
    }
}
