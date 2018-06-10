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
        tableView.delegate = self
        tableView.separatorStyle = .none
        addSubview(tableView)
        addSubview(replayButton)
    }
    
    override func initializeConstraints() {
        tableView.chura.layout.top(100).left(10).right(-10).height(300)
        replayButton.chura.layout.bottom(-40).height(50).left(50).right(-50)
    }
}

extension GameResultView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return GameResultTableViewCell.height
    }
}


class GameResultTableViewCell: BaseTableViewCell {
    
    static let height: CGFloat = 60
    
    private var targetLabel = UILabel()
    private var answerLabel = UILabel()
    private var resultLabel = UILabel()
    
    override func initializeView() {
        contentView.addSubview(targetLabel)
        contentView.addSubview(answerLabel)
        contentView.addSubview(resultLabel)
        
        [targetLabel, answerLabel, resultLabel].forEach {
            $0.textAlignment = .center
            $0.textColor = .lightGray
        }
    }
    
    override func initializeConstraints() {
        
        targetLabel.chura.layout
            .width(200).height(20).left(10).top(5)
        
        answerLabel.chura.layout
            .width(200).height(20).left(10).bottom(-5)
        
        resultLabel.chura.layout
            .right(-20).width(80).height(20).centerY(0)
    }
    
    func configure(result: (target: String, answer: String)) {
        targetLabel.text = result.target
        
        if result.answer == "pass" {
            answerLabel.text = "-"
            resultLabel.text = "pass"
        } else {
            answerLabel.attributedText = .hilightTwoStringDiff(result.answer, with: result.target)
            let success = result.target == result.answer
            resultLabel.text = success ? "success" : "failed"
            resultLabel.textColor = success ? .pink : .lightBlue
        }
    }
}
