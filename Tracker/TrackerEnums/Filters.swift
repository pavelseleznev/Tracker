//
//  Filters.swift
//  Tracker
//
//  Created by Pavel Seleznev on 6/14/25.
//

import Foundation

enum Filters: String, CaseIterable {
    case allTrackers
    case todayTrackers
    case completedTrackers
    case notCompletedTrackers
}
