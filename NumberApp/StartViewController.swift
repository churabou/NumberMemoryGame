//
//  StartViewController.swift
//  NumberApp
//
//  Created by ちゅーたつ on 2018/06/10.
//  Copyright © 2018年 ちゅーたつ. All rights reserved.
//

import UIKit
import RxSwift

class StartViewController: UIViewController {
    
    private lazy var label: UILabel = {
        let l = UILabel()
        l.text = "Start"
        l.textColor = .white
        l.textAlignment = .center
        l.font = .boldSystemFont(ofSize: 36)
        return l
    }()
    
    override func viewDidLoad() {
        view.backgroundColor = .lightBlue
        view.addSubview(label)
        label.chura.layout.width(300).height(300).centerX(0).centerY(0)
        
        
//        let menuButton = UIButton()
//        menuButton.backgroundColor = .white
//        menuButton.layer.cornerRadius = 30
//        view.addSubview(menuButton)
//        
//        menuButton.chura.layout.width(60).height(60).right(-20).bottom(-20)
//        
//        menuButton.rx.tap.asDriver().drive(onNext: { _ in
//            
//            let c = SettingView()
//            c.modalTransitionStyle = .crossDissolve
//            c.modalPresentationStyle = .overCurrentContext
//            self.present(c, animated: true, completion: nil)
//        }).disposed(by: bag)
    }
    
    var isTapped = false
    
    private let bag = DisposeBag()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isTapped { return }
        isTapped = true
        
        label.text = "3"
        Observable<Int>.interval(1, scheduler: MainScheduler.instance)
            .take(3)
            .subscribe(onNext: {
                if $0 == 2 {
                    let c = MemoryGameViewController()
                    self.present(c, animated: false, completion: nil)
                } else {
                    self.label.text = "\(2-$0)"
                }
            }).disposed(by: bag)
    }
}



class SettingView: UIViewController {
    
    private let bag = DisposeBag()
    
    override func viewDidLoad() {
        
        view.backgroundColor = .clear
        
        let contentView = UIStackView()
        contentView.distribution = .fillEqually
        contentView.axis = .vertical
        view.addSubview(contentView)
        contentView.chura.layout.width(300).height(300).centerX(0).centerY(0)

        ["問題数", "桁数", "表示時間"].forEach { target in
            
            let wrapperView = UIView()
            wrapperView.backgroundColor = .white
            let label = UILabel()
            label.textColor = UIColor.black
            label.text = ""
            let slider = UISlider()
            wrapperView.addSubview(label)
            wrapperView.addSubview(slider)
            contentView.addArrangedSubview(wrapperView)
            
            slider.rx.value
                .map { "\(target): \($0)" }
                .bind(to: label.rx.text)
                .disposed(by: bag)
            
            label.chura.layout.left(50).right(-50).top(0).height(50)
            slider.chura.layout.left(50).right(-50).bottom(0).height(50)
        }
    }
}

