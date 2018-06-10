//
//  GameResultView.swift
//  NumberApp
//
//  Created by ちゅーたつ on 2018/06/10.
//  Copyright © 2018年 ちゅーたつ. All rights reserved.
//

import UIKit

final class GameResultView: BaseView {
    
    private (set) var tableView = UITableView()
    private (set) lazy var replayButton: UIButton = {
        let b = UIButton()
        b.backgroundColor = .lightBlue
        b.setTitle("もう1度プレイ", for: .normal)
        b.setTitleColor(.white, for: .normal)
        b.layer.cornerRadius = 25
        return b
    }()
    
    override func initializeView() {
        backgroundColor = .white
        addSubview(tableView)
        addSubview(replayButton)
    }
    
    override func initializeConstraints() {
        tableView.chura.layout.top(100).left(10).right(-10).height(300)
        replayButton.chura.layout.bottom(-40).height(50).left(50).right(-50)
    }
}
