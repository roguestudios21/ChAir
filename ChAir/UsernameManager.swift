import Foundation

class UsernameManager {
    static let shared = UsernameManager()
    
    private let adjectives = ["Blue", "Red", "Swift", "Happy", "Lucky", "Silent"]
    private let animals = ["Tiger", "Eagle", "Panda", "Lion", "Dolphin", "Fox"]
    
    private(set) var username: String
    
    private init() {
        if let saved = UserDefaults.standard.string(forKey: "username") {
            username = saved
        } else {
            let adjective = adjectives.randomElement()!
            let animal = animals.randomElement()!
            let number = Int.random(in: 100...999)
            let newName = "\(adjective)\(animal)\(number)"
            username = newName
            UserDefaults.standard.set(newName, forKey: "username")
        }
    }
}
