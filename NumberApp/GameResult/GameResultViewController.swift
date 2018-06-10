//
//  GameResultViewController.swift
//  NumberApp
//
//  Created by ちゅーたつ on 2018/06/10.
//  Copyright © 2018年 ちゅーたつ. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class GameResultViewController: UIViewController {
    
    private var baseView = GameResultView()
    private var replayButton: UIButton { return baseView.replayButton }
    private var tableView: UITableView { return baseView.tableView }
    
    override func loadView() {
        view = baseView
    }
    
    private let bag = DisposeBag()

    override func viewDidLoad() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        
        replayButton.rx.tap
            .bind(to: replayGame)
            .disposed(by: bag)
    }
    
    private var replayGame: AnyObserver<Void> {
        return Binder(self) { controller, _ in
            let c = StartViewController()
            controller.present(c, animated: false, completion: nil)
        }.asObserver()
    }
}

extension GameResultViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return GameManager.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let result = GameManager.results[indexPath.row]
        cell.textLabel?.text = " 正解 \(result.target), あなた \(result.answer)"
        cell.contentView.backgroundColor = .white
        return cell
    }
}

