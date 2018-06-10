import Foundation

let questionLength = 2
let targetNumberLength = 8

struct GameManager {
    
    typealias Result = (target: String, answer: String)
    static var current: GameManager = GameManager()
    
    var questionLength = 5 //問題数
    var targetNumberLength = 8 //問題の桁数

   
    var results: [Result] = []
    
    private init() {}
    
    static func startNewGame() {
        current = GameManager()
    }
    
    var newTargets: [String] {
        return (0..<questionLength).map { _ in createRandomNumber() }
    }
    
    private func createRandomNumber() -> String {
        return (0..<targetNumberLength).map { _ in "\(arc4random_uniform(10))" }.joined()
    }
    
}
