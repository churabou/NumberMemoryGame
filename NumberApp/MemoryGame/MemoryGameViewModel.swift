import RxSwift
import RxCocoa

enum GudgeResult {
    case currect
    case incorrect(NSAttributedString)
}

enum MemoryGameState {
    case showTarget //問題を表示する。
    case trySolving //解答する
    case gudgeResult //答え合わせをする。
}

protocol MemoryGameViewModelInputs {
    func numberTapped(num: Int)
    func skipButtonTapped()
    func clearButtonTapped()
    func updateState(to: MemoryGameState)
}

protocol MemoryGameViewModelOutputs {
    var nextTargetString: Observable<String> { get set }
    var currentAnswerString: Observable<String> { get set }
    var result: Observable<GudgeResult> { get }
    var tapEnabled: Observable<Bool> { get }
    var gameFinished: Observable<Void> { get }
}

protocol MemoryGameViewModelType {
    var inputs: MemoryGameViewModelInputs { get }
    var outputs: MemoryGameViewModelOutputs { get }
}

final class MemoryGameViewModel: MemoryGameViewModelType, MemoryGameViewModelInputs, MemoryGameViewModelOutputs {
    
    var inputs: MemoryGameViewModelInputs { return self }
    var outputs: MemoryGameViewModelOutputs { return self }
    
    //Inputs
    func numberTapped(num: Int) {
        _currentAnswerString.accept(_currentAnswerString.value + "\(num)")
    }
    
    func skipButtonTapped() {
        //判定
        tapEnableSubject.onNext(false)
        resultSubject.onNext(.incorrect(NSAttributedString(string: "pass")))
        GameManager.results.append((target: _currentAnswerString.value, answer: "pass"))
    }
    
    func clearButtonTapped() {
        let answer = _currentAnswerString.value
        if !answer.isEmpty {
            _currentAnswerString.accept(String(answer.prefix(answer.count-1)))
        }
    }
    
    func updateState(to: MemoryGameState) {
        switch to {
        case .showTarget:
            
            if let target = targetStrings.popLast() {
                tapEnableSubject.onNext(false)
                _nextTargetString.accept(target)
            } else {
                //ゲーム終了
                print("game over")
                gameFinishTriger.onNext(())
            }
        case .trySolving:
            tapEnableSubject.onNext(true)
            _currentAnswerString.accept("")
        case .gudgeResult:
            //判定
            tapEnableSubject.onNext(false)
            if _currentAnswerString.value == _nextTargetString.value {
                resultSubject.onNext(.currect)
            } else {
                
                //入力された数字と問題の数字の違っている部分がハイライトされた文字列。
                let attrText = hilightTowStringDiff(_currentAnswerString.value, with: _nextTargetString.value)
                resultSubject.onNext(.incorrect(attrText))
            }
             GameManager.results.append((target: _nextTargetString.value, answer: _currentAnswerString.value))
            //結果を保存。
        }
    }
    
    //Outputs
    var nextTargetString: Observable<String>
    var currentAnswerString: Observable<String>
    var result: Observable<GudgeResult>
    var tapEnabled: Observable<Bool>
    var gameFinished: Observable<Void>
    
    init() {
        targetStrings = GameManager.newTargets
        
        nextTargetString = _nextTargetString.asObservable()
        currentAnswerString = _currentAnswerString.asObservable().share(replay: 1)
        result = resultSubject.asObservable()
        tapEnabled = tapEnableSubject.asObservable()
        gameFinished = gameFinishTriger.asObservable()
    }
    
    private var _nextTargetString: BehaviorRelay<String> = BehaviorRelay(value: "")
    private var _currentAnswerString: BehaviorRelay<String> = BehaviorRelay(value: "")
    private var resultSubject: PublishSubject<GudgeResult> = PublishSubject()
    private var tapEnableSubject: PublishSubject<Bool> = PublishSubject()
    private var gameFinishTriger: PublishSubject<Void> = PublishSubject()
    private var bag = DisposeBag()
    private var targetStrings: [String]
    
    
    //二つの文字列の差分をハイライトしたAttributedString
    private func hilightTowStringDiff(_ target: String, with: String) -> NSAttributedString {

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

//⚠️ Reentrancy anomaly was detected.
//    > Debugging: To debug this issue you can set a breakpoint in /Users/chuutatsu/xcode/NumberApp/Pods/RxSwift/RxSwift/Rx.swift:97 and observe the call stack.
//> Problem: This behavior is breaking the observable sequence grammar. `next (error | completed)?`
//This behavior breaks the grammar because there is overlapping between sequence events.
//Observable sequence is trying to send an event before sending of previous event has finished.
//> Interpretation: This could mean that there is some kind of unexpected cyclic dependency in your code,
//or that the system is not behaving in the expected way.
//> Remedy: If this is the expected behavior this message can be suppressed by adding `.observeOn(MainScheduler.asyncInstance)`
//or by enqueing sequence events in some other way.
//
//8文字
