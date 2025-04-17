//
//  Tracker.swift
//  Tracker
//
//  Created by Pavel Seleznev on 4/7/25.
//

import UIKit

struct Tracker {
    let trackerID: UUID
    let trackerName: String
    let trackerColor: UIColor
    let trackerEmoji: String
    let trackerSchedule: [Weekdays?]
    let trackerDate: Date?
}
