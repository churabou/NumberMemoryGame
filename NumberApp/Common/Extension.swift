//
//  Extension.swift
//  NumberApp
//
//  Created by ちゅーたつ on 2018/06/11.
//  Copyright © 2018年 ちゅーたつ. All rights reserved.
//

import UIKit

extension NSAttributedString {
    //二つの文字列の差分をハイライトしたAttributedString
    static func hilightTwoStringDiff(_ target: String, with: String) -> NSAttributedString {
        
        let lhd = target.map { String($0) }
        let rhd = with.map { String($0) }
        let attrText = NSMutableAttributedString(string: target)
        //        if answer.count != target.count { return } //起きる可能性はない。
        for i in 0..<lhd.count {
            if lhd[i] != rhd[i] {
                attrText.addAttribute(.foregroundColor, value: UIColor.pink, range: NSMakeRange(i, 1))
            }
        }
        return attrText
    }
}

extension UIColor {
    static var pink: UIColor {
        return UIColor(displayP3Red: 255/255, green: 192/255, blue: 203/255, alpha: 1.0)
    }
    
    static var lightBlue: UIColor {
        return UIColor.cyan.withAlphaComponent(0.9)
    }
}
