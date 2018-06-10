//
//  ViewController.swift
//  NumberApp
//
//  Created by ちゅーたつ on 2018/06/08.
//  Copyright © 2018年 ちゅーたつ. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MemoryGameViewController: UIViewController {

    //View
    private let baseView = MemoryGameView()
    private var label: UILabel { return baseView.label }
    private var numberButtons: [UIButton] { return baseView.numberButtons }
    private var passButton: UIButton { return baseView.passButton }
    private var clearButton: UIButton { return baseView.clearButton }
    
    override func loadView() {
        self.view = baseView
    }
    
    private let bag = DisposeBag()
    private let viewModel: MemoryGameViewModel = MemoryGameViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.outputs
            .inAnswerString
            .bind(to: label.rx.text)
            .disposed(by: bag)
        
        viewModel.outputs
            .targetString
            .bind(to: showTargetNumberForWhile)
            .disposed(by: bag)
        
        viewModel.outputs
            .result
            .bind(to: showResultThenRequest)
            .disposed(by: bag)
        
        viewModel.outputs
            .tapEnabled
            .bind(to: baseView.rx.isActive)
            .disposed(by: bag)
        
        viewModel.outputs
            .gameFinished
            .bind(to: showGameResultVC)
            .disposed(by: bag)
        
        numberButtons.forEach { button in
            button.rx.tap.subscribe(onNext: { [weak self] _ in
                self?.viewModel.inputs.numberTapped(num: button.tag)
            }).disposed(by: bag)
        }
        
        passButton.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.viewModel.inputs.passButtonTapped()
        }).disposed(by: bag)
        
        clearButton.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.viewModel.inputs.clearButtonTapped()
        }).disposed(by: bag)
        
        viewModel.inputs.viewDidLoad()
    }
    
    private var showTargetNumberForWhile: AnyObserver<String> {
        return Binder(self) { `self`, target in
            self.label.text = target
            //1秒後に処理をしたい。
            Observable<Int>.interval(1.0, scheduler: MainScheduler.instance)
                .take(1)
                .subscribe(onNext: { _ in
                    self.viewModel.updateState(to: .trySolving)
                }).disposed(by: self.bag)
            
        }.asObserver()
    }
    
    //正解ならCorrect、不正解なら間違ったところをハイライトして表示する。1秒後に次の問題を表示する
    private var showResultThenRequest: AnyObserver<GudgeResult> {
        return Binder(self) { `self`, result in
            switch result {
            case .currect: //表示非表示、をして
                self.label.text = "correct"
            case .incorrect(let hilightedText):
                self.label.attributedText = hilightedText
            }
            //1秒後に処理をしたい。
            Observable<Int>.interval(1.0, scheduler: MainScheduler.instance)
                .take(1)
                .subscribe(onNext: { [weak self] _ in
                    self?.viewModel.updateState(to: .showTarget)
                }).disposed(by: self.bag)
            }.asObserver()
    }

}

extension MemoryGameViewController {
    
    private var showGameResultVC: AnyObserver<Void> {
        return Binder(self) { controller, _ in
            let c = GameResultViewController()
            controller.present(c, animated: true, completion: nil)
        }.asObserver()
    }
}

fileprivate extension Reactive where Base: MemoryGameView {
 
    var isActive: Binder<Bool> {
        return Binder(base) { view, active in
            view.update(active: active)
        }
    }
}
