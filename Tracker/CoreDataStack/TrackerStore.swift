//
//  TrackerStore.swift
//  Tracker
//
//  Created by Pavel Seleznev on 4/22/25.
//

import CoreData

final class TrackerStore: NSObject {
    
    weak var delegate: TrackerStoreDelegate?
    private let context: NSManagedObjectContext
    private(set) var date: Date
    private(set) var text: String
    private(set) var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    
    convenience init(date: Date, text: String) {
        let context = CoreDataSource.persistentContainer.viewContext
        do {
            try self.init(context: context, date: date, text: text)
        } catch {
            fatalError("Initialization failed")
        }
    }
    
    init(context: NSManagedObjectContext, date: Date, text: String) throws {
        self.context = context
        self.date = date
        self.text = text
        super.init()
        
        guard let controller = createFetchedResultsController() else { return }
        
        fetchedResultsController = controller
        try fetchedResultsController?.performFetch()
    }
    
    var trackersCategories: [TrackerCategory] {
        var trackerCategories: [TrackerCategory] = []
        var trackerDictionary: [String: [Tracker]] = [:]
        
        guard let objects = fetchedResultsController?.fetchedObjects else {
            return []
        }
        
        for object in objects {
            guard let categoryTitle = object.category?.trackerCategoryTitle else {
                continue
            }
            let tracker = Tracker(
                trackerID: object.trackerID ?? UUID(),
                trackerName: object.trackerName ?? "",
                trackerColor: object.trackerColor ?? "Color selection 17",
                trackerEmoji: object.trackerEmoji ?? "",
                trackerSchedule: object.trackerSchedule?.components(separatedBy: ",").map { Weekdays(rawValue: $0) } ?? [],
                trackerDate: object.trackerDate
            )
            if var trackers = trackerDictionary[categoryTitle] {
                trackers.append(tracker)
                trackerDictionary[categoryTitle] = trackers
            } else {
                trackerDictionary[categoryTitle] = [tracker]
            }
        }
        
        for (categoryTitle, trackers) in trackerDictionary {
            let trackerCategory = TrackerCategory(trackerCategoryTitle: categoryTitle, trackerCategoryList: trackers)
            trackerCategories.append(trackerCategory)
        }
        
        return trackerCategories
    }
    
    func updateTracker(with date: Date, text: String?) {
        self.date = date
        self.text = text ?? ""
        fetchedResultsController?.fetchRequest.predicate = createPredicate()
        try? fetchedResultsController?.performFetch()
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
    
    private func createPredicate() -> NSPredicate {
        guard date != Date.distantPast else { return NSPredicate(value: true) }
        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: date)
        let filterWeekday = Weekdays.convertWeekDay(weekdayNumber)
        let weekdayPredicate = NSPredicate(format: "%K CONTAINS[c] %@", #keyPath(TrackerCoreData.trackerSchedule), filterWeekday)
        let datePredicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.trackerDate), date as CVarArg)
        var finalPredicate = NSCompoundPredicate(type: .or, subpredicates: [datePredicate, weekdayPredicate])
        
        if text != "" {
            let textPredicate = NSPredicate(format: "%K CONTAINS[c] %@", #keyPath(TrackerCoreData.trackerName), text)
            finalPredicate = NSCompoundPredicate(type: .and, subpredicates: [textPredicate, finalPredicate])
        }
        
        return finalPredicate
    }
    
    private func createFetchedResultsController() -> NSFetchedResultsController<TrackerCoreData>? {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = createPredicate()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.trackerName, ascending: true)
        ]
        
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        return controller
    }
    
    private func updateExistingTrackers(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        trackerCoreData.trackerID = tracker.trackerID
        trackerCoreData.trackerName = tracker.trackerName
        trackerCoreData.trackerColor = tracker.trackerColor
        trackerCoreData.trackerEmoji = tracker.trackerEmoji
        let scheduleDate = tracker.trackerSchedule.compactMap {
            $0?.rawValue }.joined(separator: ",")
        trackerCoreData.trackerSchedule = scheduleDate
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

extension TrackerStore: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.didUpdateTracker()
    }
}
