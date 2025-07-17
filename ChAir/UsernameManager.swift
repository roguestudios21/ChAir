//
//  UsernameManager.swift
//  ChAir
//
//  Created by Atharv  on 13/07/25.
//


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
            let newName = "\(adjectives.randomElement()!)\(animals.randomElement()!)"
            username = newName
            UserDefaults.standard.set(newName, forKey: "username")
        }
    }
}
