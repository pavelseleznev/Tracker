//
//  ExtensionDate.swift
//  Tracker
//
//  Created by Pavel Seleznev on 4/26/25.
//

import Foundation

extension Date {
    func createDateForTracker() -> Date? {
        let date = self
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        
        if let createdDate = calendar.date(from: dateComponents) {
            return createdDate
        } else {
            return nil
        }
    }
}
