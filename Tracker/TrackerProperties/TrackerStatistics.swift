//
//  TrackerStatistics.swift
//  Tracker
//
//  Created by Pavel Seleznev on 6/14/25.
//

import Foundation

struct TrackerStatistics {
    let id: UUID
    let schedule: [Weekdays?]
    let dateEvent: Date?
    let completedAt: [Date]
}
