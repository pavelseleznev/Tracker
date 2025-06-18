//
//  ScheduleViewControllerDelegate.swift
//  Tracker
//
//  Created by Pavel Seleznev on 6/4/25.
//

import Foundation

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectWeekdays(_ weekdays: [Weekdays])
}
