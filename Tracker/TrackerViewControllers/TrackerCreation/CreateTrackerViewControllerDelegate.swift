//
//  CreateTrackerViewControllerDelegate.swift
//  Tracker
//
//  Created by Pavel Seleznev on 6/4/25.
//

import Foundation

protocol CreateTrackerViewControllerDelegate: AnyObject {
    func addNewTracker(newTracker: TrackerCategory)
}
