//
//  ExtensionInt.swift
//  Tracker
//
//  Created by Pavel Seleznev on 4/13/25.
//

import UIKit

extension Int {
    func days() -> String {
        let remainder10 = self % 10
        let remainder100 = self % 100
        
        if remainder10 == 1 && remainder100 != 11 {
            return "\(self) день"
        } else if remainder10 >= 2 && remainder10 <= 4 && (remainder100 < 10 || remainder100 >= 20) {
            return "\(self) дня"
        } else {
            return "\(self) дней"
        }
    }
}
