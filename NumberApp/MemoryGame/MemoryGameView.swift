//
//  MemoryView.swift
//  NumberApp
//
//  Created by ちゅーたつ on 2018/06/08.
//  Copyright © 2018年 ちゅーたつ. All rights reserved.
//

import UIKit

extension UIColor {
    static var pink: UIColor {
        return UIColor(displayP3Red: 255/255, green: 192/255, blue: 203/255, alpha: 1.0)
    }
    
    static var lightBlue: UIColor {
        return UIColor.cyan.withAlphaComponent(0.9)
    }
}

final class MemoryGameView: BaseView {
    
    
    private (set) var label = UILabel()
    private (set) var answerButton = UIButton()
    private (set) var clearButton = UIButton()
    private (set) var numberButtons: [UIButton] = []
    
    override func initializeView() {
        
        backgroundColor = .white
        
        label.backgroundColor = .white
        label.textColor = .lightGray
        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        addSubview(label)
        
        let buttonS: CGFloat = 80
        let stackView = UIStackView()
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
                b.layer.cornerRadius = buttonS / 2
                b.setTitleColor(.cyan, for: .normal)
                b.layer.borderWidth = 2
                b.layer.borderColor = UIColor.cyan.cgColor
                
                if num == 10 {
                    b.setTitle("clear", for: .normal)
                    clearButton = b
                } else if num == 12 {
                    b.setTitle("ok", for: .normal)
                    answerButton = b
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
        stackView.chura.layout.width(buttonS*3+20).height(buttonS*4+30).centerY(0).centerX(0)
        label.chura.layout.width(260).height(50).centerX(0).top(100)
    }
    
    func update(active: Bool) {
        
        isUserInteractionEnabled = active
        let alpha: CGFloat = active ? 1 : 0
        numberButtons.forEach { $0.alpha = alpha }
        answerButton.alpha = alpha
        clearButton.alpha = alpha
    }
}

