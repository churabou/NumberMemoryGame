import Foundation

struct GameManager {
    
    typealias Result = (target: String, answer: String)
    static var current = GameManager()
    private init() {}
    
    static func startNewGame() {
        current = GameManager()
    }
    
    var questionCount = 5 //問題数
    var numberOfDigits = 8 //問題の桁数
    var results: [Result] = []
    
    var newTargets: [String] {
        return (0..<questionCount).map { _ in createRandomNumber() }
    }
    
    private func createRandomNumber() -> String {
        return (0..<numberOfDigits).map { _ in "\(arc4random_uniform(10))" }.joined()
    }
}
