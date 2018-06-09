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
    private (set) var answerButton = UIButton()
    private (set) var clearButton = UIButton()
    private (set) var numberButtons: [UIButton] = []
    
    override func initializeView() {
        
        backgroundColor = .white
        
        label.backgroundColor = .black
        label.textColor = .white
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
                b.backgroundColor = row % 2 == 0 ? .red : .blue
                b.setTitleColor(.white, for: .normal)
                
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
        let alpha: CGFloat = active ? 1 : 0.5
        numberButtons.forEach { $0.alpha = alpha }
        answerButton.alpha = alpha
        clearButton.alpha = alpha
    }
}

