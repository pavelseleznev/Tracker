//
//  TrackerStore.swift
//  Tracker
//
//  Created by Pavel Seleznev on 4/22/25.
//

import CoreData

final class TrackerStore: NSObject {
    
    weak var delegate: NSFetchedResultsControllerDelegate? {
        didSet {
            fetchedResultsController?.delegate = delegate
        }
    }
    
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    
    private let context: NSManagedObjectContext
    
    convenience override init() {
        let context = CoreDataSource.persistentContainer.viewContext
        do {
            try self.init(context: context)
        } catch {
            fatalError("Initialization failed")
        }
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
    }
    
    func addNewTracker(_ tracker: Tracker, with category: TrackerCategory) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        updateExistingTrackers(trackerCoreData, with: tracker)
        
        if let existingCategory = try fetchTrackerCategory(with: category.trackerCategoryTitle) {
            existingCategory.addToTracker(trackerCoreData)
        } else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.trackerCategoryTitle = category.trackerCategoryTitle
            newCategory.addToTracker(trackerCoreData)
        }
        try context.save()
    }
    
    private func updateExistingTrackers(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        guard let (colorName, _) = AppColor.colorSelection.first(where: { $0.value == tracker.trackerColor }) else { return }
        trackerCoreData.trackerID = tracker.trackerID
        trackerCoreData.trackerName = tracker.trackerName
        trackerCoreData.trackerColor = colorName
        trackerCoreData.trackerEmoji = tracker.trackerEmoji
        trackerCoreData.trackerSchedule = DaysValueTransformer().transformedValue(tracker.trackerSchedule) as? NSObject
        trackerCoreData.trackerDate = tracker.trackerDate
    }
    
    private func fetchTrackerCategory(with trackerCategoryTitle: String) throws -> TrackerCategoryCoreData? {
        let trackerCategory: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        trackerCategory.predicate = NSPredicate(format: "trackerCategoryTitle == %@", trackerCategoryTitle)
        
        do {
            let result = try context.fetch(trackerCategory)
            return result.first
        } catch {
            throw error
        }
    }
}
