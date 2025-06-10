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
    
    private(set) var trackerCategory: [TrackerCategory] = [] {
        didSet {
            categoriesBinding?(trackerCategory)
        }
    }
    private(set) var isCategoriesEmpty: Bool = false {
        didSet {
            isCategoriesEmptyBinding?(isCategoriesEmpty)
        }
    }
    
    init() {
        trackerStore.delegate = self
        trackerCategory = getTrackerCategoriesStore()
        isCategoriesEmpty = trackerCategory.isEmpty
    }
    
    // MARK: - Internal Methods
    func updateTrackerStore(with date: Date, text: String) {
        currentDate = date
        self.text = text
        guard let currentDate = currentDate else { return }
        trackerStore.updateTracker(with: currentDate, text: self.text)
        trackerCategory = getTrackerCategoriesStore()
    }
    
    func addNewTracker(_ tracker: Tracker, with category: TrackerCategory) {
        try? trackerStore.addNewTracker(tracker, with: category)
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
        do {
            try trackerRecordStore.loadCurrentTracker(trackerID: trackerID, trackerDate: date)
        } catch {
            print("[completeTracker]: Failed to save a modified tracker \(error.localizedDescription)")
        }
    }
    
    // MARK: - Private Methods
    private func getTrackerCategoriesStore() -> [TrackerCategory] {
        return trackerStore.trackersCategories
    }
    
    private func reloadVisibleCategories(text: String?, date: Date) {
        trackerStore.updateTracker(with: date, text: text)
    }
}

// MARK: - TrackerViewModel TrackerStoreDelegate
extension TrackerViewModel: TrackerStoreDelegate {
    func didUpdateTracker() {
        guard let unwrappedDate = currentDate else { return }
        updateTrackerStore(with: unwrappedDate, text: text)
    }
}
