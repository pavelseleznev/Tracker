//
//  TrackerCellDelegate.swift
//  Tracker
//
//  Created by Pavel Seleznev on 6/4/25.
//

import Foundation

protocol TrackerCellDelegate: AnyObject {
    func completeTracker(trackerID: UUID, at indexPath: IndexPath)
}
