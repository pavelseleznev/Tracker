//
//  UserDefaultsService.swift
//  Tracker
//
//  Created by Pavel Seleznev on 6/10/25.
//

import Foundation

final class UserDefaultsService {
    static let shared = UserDefaultsService()
    private let defaults = UserDefaults.standard
    
    private init() {}
    
    private enum Key {
        static let hasLaunchedBefore = "hasLaunchedBefore"
    }
    
    var hasLaunchedBefore: Bool {
        get { defaults.bool(forKey: Key.hasLaunchedBefore) }
        set { defaults.set(newValue, forKey: Key.hasLaunchedBefore) }
    }
}
