
import UIKit

class AnchorShortcut {
    
    var base: UIView
    init (_ base: UIView) {
        self.base = base
    }
}

extension AnchorShortcut {
    
    var right: NSLayoutXAxisAnchor {
        return base.rightAnchor
    }
    
    var left: NSLayoutXAxisAnchor {
        return base.leftAnchor
    }
    
    var top: NSLayoutYAxisAnchor {
        return base.topAnchor
    }
    
    var bottom: NSLayoutYAxisAnchor {
        return base.bottomAnchor
    }
    
    var width: NSLayoutDimension {
        return base.widthAnchor
    }
    
    var height: NSLayoutDimension {
        return base.heightAnchor
    }
    
    var centerX: NSLayoutXAxisAnchor {
        return base.centerXAnchor
    }
    
    var centerY: NSLayoutYAxisAnchor {
        return base.centerYAnchor
    }
}


// left, right, centerX
protocol HorizontalConstraints {
}

// top, bottom, centerY
protocol VerticalConstraints {
}

// width, height
protocol DimensionalConstraints {
}



extension NSLayoutXAxisAnchor: HorizontalConstraints {
}
extension NSLayoutYAxisAnchor: VerticalConstraints {
}
extension NSLayoutDimension: DimensionalConstraints {
}


typealias ConstraintsTarget = HorizontalConstraints & VerticalConstraints & DimensionalConstraints

extension Int: ConstraintsTarget {}
extension CGFloat: ConstraintsTarget {}
extension UIView: ConstraintsTarget {}




//LayoutAnchor + 10
class AnchorCalculable<T> {
    
    var target: T
    var amount: CGFloat
    
    init(target: T, amount: CGFloat) {
        self.target = target
        self.amount = amount
    }
}

//この2つも多分共通化できるはず。
extension NSLayoutXAxisAnchor {
    
    static func +(lhd: NSLayoutXAxisAnchor, rhd: CGFloat) -> AnchorCalculable<NSLayoutXAxisAnchor> {
        return AnchorCalculable(target: lhd, amount: rhd)
    }
    
    static func -(lhd: NSLayoutXAxisAnchor, rhd: CGFloat) -> AnchorCalculable<NSLayoutXAxisAnchor> {
        return AnchorCalculable(target: lhd, amount: -rhd)
    }
}

extension NSLayoutYAxisAnchor {
    
    static func +(lhd: NSLayoutYAxisAnchor, rhd: CGFloat) -> AnchorCalculable<NSLayoutYAxisAnchor> {
        return AnchorCalculable(target: lhd, amount: rhd)
    }
    
    static func -(lhd: NSLayoutYAxisAnchor, rhd: CGFloat) -> AnchorCalculable<NSLayoutYAxisAnchor> {
        return AnchorCalculable(target: lhd, amount: -rhd)
    }
}

extension NSLayoutDimension {
    
    static func +(lhd: NSLayoutDimension, rhd: CGFloat) -> AnchorCalculable<NSLayoutDimension> {
        return AnchorCalculable(target: lhd, amount: rhd)
    }
    
    static func -(lhd: NSLayoutDimension, rhd: CGFloat) -> AnchorCalculable<NSLayoutDimension> {
        return AnchorCalculable(target: lhd, amount: -rhd)
    }
}


extension AnchorCalculable: HorizontalConstraints where T == NSLayoutXAxisAnchor {
}

extension AnchorCalculable: VerticalConstraints where T == NSLayoutYAxisAnchor {
}

extension AnchorCalculable: DimensionalConstraints where T == NSLayoutDimension {
}

fileprivate extension NSLayoutConstraint {
    
    func activate() {
        isActive = true
    }
}


enum LayoutTarget {
    
    enum XAxis {
        case left, right, centerX
    }
    
    enum YAxis {
        case top, bottom, centerY
    }
    
    enum Dimension {
        case width, height
    }
}

extension UIView {
    
    func layoutAnchor(_ target: LayoutTarget.XAxis) -> NSLayoutXAxisAnchor {
        switch target {
        case .left: return leftAnchor
        case .right: return rightAnchor
        case .centerX: return centerXAnchor
        }
    }
    
    func layoutAnchor(_ target: LayoutTarget.YAxis) -> NSLayoutYAxisAnchor {
        switch target {
        case .top: return topAnchor
        case .bottom: return bottomAnchor
        case .centerY: return centerYAnchor
        }
    }
    
    func layoutAnchor(_ target: LayoutTarget.Dimension) -> NSLayoutDimension {
        switch target {
        case .width: return widthAnchor
        case .height: return heightAnchor
        }
    }
}


class LayoutMaker {
    
    var base: UIView
    init (_ base: UIView) {
        self.base = base
        base.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func activateLayoutAnchorXAxis(_ constrain: HorizontalConstraints, target: LayoutTarget.XAxis) {
        
        let anchor = base.layoutAnchor(target)
        
        if let constrain = constrain as? AnchorCalculable<NSLayoutXAxisAnchor> {
            anchor.constraint(equalTo: constrain.target, constant: constrain.amount).activate()
        }
        else if let constrain = constrain as? NSLayoutXAxisAnchor {
            anchor.constraint(equalTo: constrain).activate()
        }
        else if let view = constrain as? UIView {
            anchor.constraint(equalTo: view.layoutAnchor(target)).activate()
        }
        else if let constrain = constrain as? CGFloat {
            anchor.constraint(equalTo: base.superview!.layoutAnchor(target), constant: constrain).activate()
        }
        else if let constrain = constrain as? Int {
            anchor.constraint(equalTo: base.superview!.layoutAnchor(target), constant: CGFloat(constrain)).activate()
        }
    }
    
    func activateLayoutAnchorYAxis(_ constrain: VerticalConstraints, target: LayoutTarget.YAxis) {
        
        let anchor = base.layoutAnchor(target)
        
        if let constrain = constrain as? AnchorCalculable<NSLayoutYAxisAnchor> {
            anchor.constraint(equalTo: constrain.target, constant: constrain.amount).activate()
        }
        else if let constrain = constrain as? NSLayoutYAxisAnchor {
            anchor.constraint(equalTo: constrain).activate()
        }
        else if let view = constrain as? UIView {
            anchor.constraint(equalTo: view.layoutAnchor(target)).activate()
        }
        else if let constrain = constrain as? CGFloat {
            anchor.constraint(equalTo: base.superview!.layoutAnchor(target), constant: constrain).activate()
        }
        else if let constrain = constrain as? Int {
            anchor.constraint(equalTo: base.superview!.layoutAnchor(target), constant: CGFloat(constrain)).activate()
        }
    }
    
    
    func activateLayoutAnchorDimension(_ constrain: DimensionalConstraints, target: LayoutTarget.Dimension) {
        
        let anchor = base.layoutAnchor(target)
        if let constrain = constrain as? AnchorCalculable<NSLayoutDimension> {
            anchor.constraint(equalTo: constrain.target, multiplier: 1, constant: constrain.amount).activate()
        }
        else if let constrain = constrain as? NSLayoutDimension {
            anchor.constraint(equalTo: constrain).activate()
        }
        else if let view = constrain as? UIView {
            anchor.constraint(equalTo: view.layoutAnchor(target), multiplier: 1).activate()
        }
        else if let constant = constrain as? CGFloat {
            anchor.constraint(equalToConstant: constant).activate()
        }
        else if let constant = constrain as? Int {
            anchor.constraint(equalToConstant: CGFloat(constant)).activate()
        }
    }
}


extension LayoutMaker {
    
    @discardableResult
    func width(_ width: DimensionalConstraints) -> LayoutMaker {
        activateLayoutAnchorDimension(width, target: .width)
        return self
    }
    
    @discardableResult
    func height(_ height: DimensionalConstraints) -> LayoutMaker {
        activateLayoutAnchorDimension(height, target: .height)
        return self
    }
}

extension LayoutMaker {
    
    @discardableResult
    func left(_ left: HorizontalConstraints) -> LayoutMaker {
        activateLayoutAnchorXAxis(left, target: .left)
        return self
    }
    
    @discardableResult
    func right(_ right: HorizontalConstraints) -> LayoutMaker {
        activateLayoutAnchorXAxis(right, target: .right)
        return self
    }
    
    @discardableResult
    func centerX(_ centerX: HorizontalConstraints) -> LayoutMaker {
        activateLayoutAnchorXAxis(centerX, target: .centerX)
        return self
    }
}

extension LayoutMaker {
    
    @discardableResult
    func top(_ top: VerticalConstraints) -> LayoutMaker {
        activateLayoutAnchorYAxis(top, target: .top)
        return self
    }
    
    @discardableResult
    func bottom(_ bottom: VerticalConstraints) -> LayoutMaker {
        activateLayoutAnchorYAxis(bottom, target: .bottom)
        return self
    }
    
    @discardableResult
    func centerY(_ centerY: VerticalConstraints) -> LayoutMaker {
        activateLayoutAnchorYAxis(centerY, target: .centerY)
        return self
    }
}


class ChuraLayout {
    
    var target: UIView
    
    init (_ target: UIView) {
        self.target = target
    }
    
    func constrainWith(_ view1: UIView, _ view2: UIView, closure: ((LayoutMaker, AnchorShortcut, AnchorShortcut)->Swift.Void)) {
        closure(LayoutMaker(target), AnchorShortcut(view1), AnchorShortcut(view2))
    }
    
    var layout: LayoutMaker {
        return LayoutMaker(target)
    }
}

extension UIView {
    
    var chura: ChuraLayout {
        return ChuraLayout(self)
    }
    
    var anchor: AnchorShortcut {
        return AnchorShortcut(self)
    }
}

