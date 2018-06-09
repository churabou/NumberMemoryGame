import RxSwift
import RxCocoa

enum GudgeResult {
    case currect
    case incorrect(String)
}

enum MemoryGameState {
    case showTarget //問題を表示する。
    case trySolving //解答する
    case gudgeResult //答え合わせをする。
}

protocol MemoryGameViewModelInput {
    func numButtonDidTap(num: Int)
    func answerButtonDidTap()
    func clearButtonDidTap()
    func updateState(to: MemoryGameState)
}

protocol MemoryGameViewModelOutput {
    var nextTargetString: Observable<String> { get set }
    var currentAnswerString: Observable<String> { get set }
    var result: Observable<GudgeResult> { get }
    var tapEnabled: Observable<Bool> { get }
}

protocol MemoryGameViewModelType {
    var input: MemoryGameViewModelInput { get }
    var output: MemoryGameViewModelOutput { get }
}

let questionLength = 5
let targetNumberLength = 8

struct GameManager {
    
    static let questionLength = 5 //問題数
    static let targetNumberLength = 8 //問題の桁数
    
    static var newTargets: [String] {
        
//        let createRandomNumber: ((Swift.Void) -> String) = { _ in
//            return (0..<targetNumberLength).map { _ in "\(arc4random_uniform(10))" }.joined()
//        }
        return (0..<questionLength).map { _ in createRandomNumber() }
    }
    
    static func createRandomNumber() -> String {
        return (0..<targetNumberLength).map { _ in "\(arc4random_uniform(10))" }.joined()
    }
}

class MemoryGameViewModel: MemoryGameViewModelType, MemoryGameViewModelInput, MemoryGameViewModelOutput {
    
    var input: MemoryGameViewModelInput { return self }
    var output: MemoryGameViewModelOutput { return self }
    
    //Input
    func numButtonDidTap(num: Int) {
        _currentAnswerString.accept(_currentAnswerString.value + "\(num)")
    }
    
    func answerButtonDidTap() {
        //判定
        tapEnableSubject.onNext(false)
        if _currentAnswerString.value == _nextTargetString.value {
            resultSubject.onNext(.currect)
        } else {
            resultSubject.onNext(.incorrect("aaaa"))
        }
    }
    
    func clearButtonDidTap() {
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
                resultSubject.onNext(.incorrect("aaaa"))
            }
            //結果を保存。
        }
    }
    
    //Output
    var nextTargetString: Observable<String>
    var currentAnswerString: Observable<String>
    var result: Observable<GudgeResult>
    var tapEnabled: Observable<Bool>
    
    init() {
        nextTargetString = _nextTargetString.asObservable()
        currentAnswerString = _currentAnswerString.asObservable().share(replay: 1)
        result = resultSubject.asObservable()
        tapEnabled = tapEnableSubject.asObserver()
        
        targetStrings = GameManager.newTargets
    }
    
    private var _nextTargetString: BehaviorRelay<String> = BehaviorRelay(value: "")
    private var _currentAnswerString: BehaviorRelay<String> = BehaviorRelay(value: "")
    private var resultSubject: PublishSubject<GudgeResult> = PublishSubject()
    private var tapEnableSubject: PublishSubject<Bool> = PublishSubject()
    private var bag = DisposeBag()
    
    private var targetStrings: [String]
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

