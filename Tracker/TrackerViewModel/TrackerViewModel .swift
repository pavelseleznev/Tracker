//
//  TrackerViewModel .swift
//  Tracker
//
//  Created by Pavel Seleznev on 5/20/25.
//

import Foundation

typealias Binding<T> = (T) -> Void

final class TrackerViewModel {
    
    // MARK: - Public Property
    var categoriesBinding: Binding<[TrackerCategory]>?
    
    // MARK: - Private Properties
    private var isCategoriesEmptyBinding: Binding<Bool>?
    private var currentDate = Date().createDateForTracker()
    private var text = ""
    private var trackerStore = TrackerStore(date: Date.distantPast, text: "")
    private var trackerRecordStore = TrackerRecordStore()
    private var completedFilter: Bool?
    private let analyticsService = AnalyticsService()
    
    private(set) var trackerCategory: [TrackerCategory] = [] {
        didSet {
            categoriesBinding?(trackerCategory)
        }
    }
    
    init() {
        trackerStore.delegate = self
        trackerCategory = getTrackerCategoriesStore()
    }
    
    // MARK: - Methods
    func addNewTracker(_ tracker: Tracker, with category: TrackerCategory) {
        try? trackerStore.addNewTracker(tracker, with: category)
    }
    
    func togglePin(_ tracker: Tracker) {
        try? trackerStore.togglePin(tracker)
    }
    
    func completedDays(for id: UUID) -> (number: Int, completed: Bool)? {
        let days = try? trackerRecordStore.fetchRequestDays(for: id)
        let number = days?.count ?? 0
        
        guard let currentDate = currentDate else { return nil }
        guard let trackerDate = Date().createDateForTracker() else {
            return (number, false)
        }
        
        let completed = (days?.contains(currentDate) ?? false) && currentDate <= trackerDate
        return (number, completed)
    }
    
    
    func completedTrackers(trackerID: UUID, date: Date) {
        analyticsService.report(event: "click", params: ["screen" : "main", "item" : "track"])
        do {
            try trackerRecordStore.loadCurrentTracker(trackerID: trackerID, trackerDate: date)
        } catch {
            print("[completeTracker]: Failed to save a modified tracker \(error.localizedDescription)")
        }
    }
    
    func updateCategories(with date: Date, text: String, completedFilter: Bool?) {
        currentDate = date
        self.text = text
        guard let currentDate = currentDate else { return }
        trackerStore.updateTracker(with: currentDate, text: self.text, completedFilter: completedFilter)
        trackerCategory = getTrackerCategoriesStore()
    }
    
    func deleteTracker(_ tracker: Tracker) {
        analyticsService.report(event: "click", params: ["screen" : "main", "item" : "delete"])
        try? trackerStore.deleteTracker(tracker)
    }
    
    func availableTracker(for date: Date) -> Bool {
        do {
            return try trackerStore.availableTrackers(for: date)
        } catch {
            return false
        }
    }
    
    func screenDidAppearAnalytics() {
        analyticsService.report(event: "open", params: ["screen" : "main"])
    }
    
    func screenDidDisappearAnalytics() {
        analyticsService.report(event: "close", params: ["screen" : "main"])
    }
    
    func createNewTrackerAnalytics() {
        analyticsService.report(event: "click", params: ["screen" : "main", "item" : "add_track"])
    }
    
    func completeTrackerAnalytics() {
        analyticsService.report(event: "click", params: ["screen" : "main", "item" : "track"])
    }
    
    func filterButtonTappedAnalytics() {
        analyticsService.report(event: "click", params: ["screen" : "main", "item" : "filter"])
    }
    
    func showEditingViewControllerAnalytics() {
        analyticsService.report(event: "click", params: ["screen" : "main", "item" : "edit"])
    }
    
    func deleteTrackerTappedAnalytics() {
        analyticsService.report(event: "click", params: ["screen" : "main", "item" : "delete"])
    }
    
    private func getTrackerCategoriesStore() -> [TrackerCategory] {
        trackerStore.trackersCategories
    }
}

// MARK: - TrackerViewModel TrackerStoreDelegate
extension TrackerViewModel: TrackerStoreDelegate {
    func didUpdateTracker() {
        guard let unwrappedDate = currentDate else { return }
        updateCategories(with: unwrappedDate, text: text, completedFilter: completedFilter)
    }
}
