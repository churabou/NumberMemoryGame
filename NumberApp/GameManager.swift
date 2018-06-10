import Foundation

let questionLength = 2
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
    
    typealias Result = (target: String, answer: String)
    
    static var results: [Result] = []
    
}
