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

class ViewController: UIViewController {

    
    private let bag = DisposeBag()
    private let baseView = MemoryGameView()
    private var label: UILabel { return baseView.label }
    private var numberButtons: [UIButton] { return baseView.numberButtons }
    private var answerButton: UIButton { return baseView.answerButton }
    private var clearButton: UIButton { return baseView.clearButton }
    
    override func loadView() {
        self.view = baseView
    }
    
    let viewModel: MemoryGameViewModel = MemoryGameViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.outputs.currentAnswerString
            .observeOn(MainScheduler.asyncInstance) //警告にあったので追加。
            .filter { $0.count >= targetNumberLength }
            .subscribe(onNext: { [weak self] _ in
                print("8文字")
                self?.viewModel.inputs.answerButtonDidTap()
            }).disposed(by: bag)
        
        viewModel.outputs
            .currentAnswerString
            .bind(to: label.rx.text)
            .disposed(by: bag)
        
        viewModel.outputs
            .nextTargetString
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
        
        
        numberButtons.forEach { button in
            button.rx.tap.subscribe(onNext: { [weak self] _ in
                self?.viewModel.inputs.numButtonDidTap(num: button.tag)
            }).disposed(by: bag)
        }
        
        answerButton.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.viewModel.inputs.answerButtonDidTap()
        }).disposed(by: bag)
        
        clearButton.rx.tap.subscribe(onNext: { [weak self] _ in
            self?.viewModel.inputs.clearButtonDidTap()
        }).disposed(by: bag)
        
        
    }
    
    var showTargetNumberForWhile: AnyObserver<String> {
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
    
    //正解ならCorrect、不正解なら間違ったところをハイライトして表示する。
    var showResultThenRequest: AnyObserver<GudgeResult> {
        return Binder(self) { `self`, result in
            switch result {
            case .currect: //表示非表示、をして
                self.label.backgroundColor = .blue
            case .incorrect(_):
                self.label.backgroundColor = .red
            }
            //1秒後に処理をしたい。
            Observable<Int>.interval(1.0, scheduler: MainScheduler.instance)
                .debug("interval")
                .take(1)
                .subscribe(onNext: { [weak self] _ in
                    self?.label.backgroundColor = .black
//                    self?.viewModel.input.requestNext()
                    self?.viewModel.updateState(to: .showTarget)
                }).disposed(by: self.bag)
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
