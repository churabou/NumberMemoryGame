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
    func passButtonTapped()
    func clearButtonTapped()
    func viewDidLoad()
}

protocol MemoryGameViewModelOutputs {
    var targetString: Observable<String> { get }
    var inAnswerString: Observable<String> { get }
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
        _inAnswerString.accept(_inAnswerString.value + "\(num)")
        if _inAnswerString.value.count >= GameManager.current.numberOfDigits {
            gudgeResultThenNext()
        }
    }
    
    func passButtonTapped() { //強制的に判定に
        gudgeResultThenNext()
    }
    
    func clearButtonTapped() {
        let answer = _inAnswerString.value
        if !answer.isEmpty {
            _inAnswerString.accept(String(answer.prefix(answer.count-1)))
        }
    }
    
    func viewDidLoad() {
        GameManager.startNewGame()
        targetStrings = GameManager.current.newTargets
        //問題を見せる -> 1秒後に回答を受け付けるイベントを流す。
        Observable<MemoryGameState>.concat(.just(.showTarget),
                                           Observable.just(.trySolving).delay(1, scheduler: MainScheduler.instance))
            .subscribe(onNext: { [weak self] state in
                self?.gameStateTriger.onNext(state)
            })
            .disposed(by: bag)
    }
    
    //Outputs
    var targetString: Observable<String>
    var inAnswerString: Observable<String>
    var result: Observable<GudgeResult>
    var tapEnabled: Observable<Bool>
    var gameFinished: Observable<Void>
    
    init() {
        targetString = _targetString.asObservable()
        inAnswerString = _inAnswerString.asObservable().share(replay: 1)
        result = resultTriger.asObservable()
        tapEnabled = tapEnableTriger.asObservable()
        gameFinished = gameFinishTriger.asObservable()
        
        gameState = gameStateTriger.asObserver().share(replay: 1)
        //stateに応じて画面タップを制限する。
        gameState
            .map { $0 == .trySolving }
            .bind(to: tapEnableTriger)
            .disposed(by: bag)
        
        gameState
            .subscribe(onNext: { [weak self] state in
                self?.updateState(to: state)
            })
            .disposed(by: bag)
    }
    
    private var _targetString: BehaviorRelay<String> = BehaviorRelay(value: "")
    private var _inAnswerString: BehaviorRelay<String> = BehaviorRelay(value: "")
    private var resultTriger: PublishSubject<GudgeResult> = PublishSubject()
    private var tapEnableTriger: PublishSubject<Bool> = PublishSubject()
    private var gameFinishTriger: PublishSubject<Void> = PublishSubject()
    private var bag = DisposeBag()
    private var targetStrings: [String] = []
    private let gameStateTriger = PublishSubject<MemoryGameState>()
    private let gameState: Observable<MemoryGameState>
    
    private func gudgeResultThenNext() {
        
        if targetStrings.isEmpty {
            gameStateTriger.onNext(.gudgeResult)
            Observable<Int>.interval(1, scheduler: MainScheduler.instance)
                .take(1)
                .map { _ in }
                .bind(to: gameFinishTriger)
                .disposed(by: bag)
        } else {
            //判定する -> 1秒後に次の問題を見せる -> さらに1秒後に入力を受け付ける。
            Observable<MemoryGameState>.concat(.just(.gudgeResult),
                                               Observable.just(.showTarget).delay(1, scheduler: MainScheduler.instance),
                                               Observable.just(.trySolving).delay(1, scheduler: MainScheduler.instance)
                )
                .subscribe(onNext: { [weak self] state in
                    self?.gameStateTriger.onNext(state)
                })
                .disposed(by: bag)
        }
    }
    
    private func updateState(to: MemoryGameState) {
        switch to {
        case .showTarget:
            if let target = targetStrings.popLast() { //ここは強制あんラップでも良い。
                _targetString.accept(target)
            }
        case .trySolving:
            _inAnswerString.accept("")
        case .gudgeResult:
            //パス
            if _inAnswerString.value.count < _targetString.value.count {
                resultTriger.onNext(.incorrect(NSAttributedString(string: "pass")))
                GameManager.current.results.append((target: _targetString.value, answer: "pass"))
                return
            }
            //判定
            if _inAnswerString.value == _targetString.value {
                resultTriger.onNext(.currect)
            } else {
                //入力された数字と問題の数字の違っている部分がハイライトされた文字列。
                let attrText: NSAttributedString = .hilightTwoStringDiff(_inAnswerString.value, with: _targetString.value)
                resultTriger.onNext(.incorrect(attrText))
            }
            //結果を保存。
            GameManager.current.results.append((target: _targetString.value, answer: _inAnswerString.value))
        }
    }
}

