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
