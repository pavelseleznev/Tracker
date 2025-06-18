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
    private(set) var completedFilter: Bool?
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
        var pinnedTrackers: [Tracker] = []
        
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
            
            if object.isPinned {
                pinnedTrackers.append(tracker)
            } else {
                if var trackers = trackerDictionary[categoryTitle] {
                    trackers.append(tracker)
                    trackerDictionary[categoryTitle] = trackers
                } else {
                    trackerDictionary[categoryTitle] = [tracker]
                }
            }
        }
        
        if !pinnedTrackers.isEmpty {
            let pinnedCategoryTitle = NSLocalizedString("pinned.title", comment: "Title for pinned trackers category")
            trackerCategories.append(TrackerCategory(trackerCategoryTitle: pinnedCategoryTitle, trackerCategoryList: pinnedTrackers))
        }
        
        let sortedCategories = trackerDictionary.keys.sorted().compactMap { categoryTitle in
            if let trackers = trackerDictionary[categoryTitle] {
                return TrackerCategory(trackerCategoryTitle: categoryTitle, trackerCategoryList: trackers)
            }
            return nil
        }
        
        trackerCategories += sortedCategories
        
        return trackerCategories
    }

    func updateTracker(with date: Date, text: String?, completedFilter: Bool?) {
        self.date = date
        self.text = text ?? ""
        self.completedFilter = completedFilter
        fetchedResultsController?.fetchRequest.predicate = createPredicate()
        try? fetchedResultsController?.performFetch()
    }
    
    func addNewTracker(_ tracker: Tracker, with category: TrackerCategory) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        createOrUpdateTracker(trackerCoreData, with: tracker)
        
        if let existingCategory = try fetchTrackerCategory(with: category.trackerCategoryTitle) {
            existingCategory.addToTracker(trackerCoreData)
        } else {
            let newCategory = TrackerCategoryCoreData(context: context)
            newCategory.trackerCategoryTitle = category.trackerCategoryTitle
            newCategory.addToTracker(trackerCoreData)
        }
        do {
            try context.save()
        } catch {
            print("[addNewTracker]: Failed to save a tracker \(error.localizedDescription)")
        }
    }
    
    func deleteTracker(_ tracker: Tracker) throws {
        do {
            let trackerCoreData = try fetchTracker(by: tracker.trackerID)
            if let records = trackerCoreData.record as? Set<TrackerRecordCoreData> {
                for record in records {
                    context.delete(record)
                }
            }
            context.delete(trackerCoreData)
            try context.save()
            
        } catch {
            throw error
        }
    }
    
    func togglePin(_ tracker: Tracker) throws {
        let trackerCoreData = try fetchTracker(by: tracker.trackerID)
        trackerCoreData.isPinned.toggle()
        try context.save()
    }
    
    func availableTrackers(for date: Date) throws -> Bool {
        self.date = date
        let fetchRequest = NSFetchRequest<NSNumber>(entityName: "TrackerCoreData")
        fetchRequest.resultType = .countResultType
        fetchRequest.predicate = createDatePredicate()
        let result = try context.fetch(fetchRequest)
        return (result.first?.intValue ?? 0) > 0
    }
    
    private func createPredicate() -> NSPredicate {
        var finalPredicate = createDatePredicate()
        
        if let completedFilter = completedFilter {
            let filterPredicate: NSPredicate
            
            if completedFilter {
                filterPredicate = NSPredicate(format: "SUBQUERY(record, $record, $record.trackerDate == %@).@count > 0", date as CVarArg)
            } else {
                filterPredicate = NSPredicate(format: "SUBQUERY(record, $record, $record.trackerDate == %@).@count == 0", date as CVarArg)
            }
            
            finalPredicate = NSCompoundPredicate(type: .and, subpredicates: [filterPredicate, finalPredicate])
        }
        
        if !text.isEmpty {
            let textPredicate = NSPredicate(format: "%K CONTAINS[c] %@", #keyPath(TrackerCoreData.trackerName), text)
            finalPredicate = NSCompoundPredicate(type: .and, subpredicates: [textPredicate, finalPredicate])
        }
        
        return finalPredicate
    }

    private func createDatePredicate() -> NSPredicate {
        guard date != Date.distantPast else { return NSPredicate(value: true) }
        let calendar = Calendar.current
        let weekdayNumber = calendar.component(.weekday, from: date)
        let filterWeekday = Weekdays.convertWeekDay(weekdayNumber)
        let weekdayPredicate = NSPredicate(format: "%K CONTAINS[c] %@", #keyPath(TrackerCoreData.trackerSchedule), filterWeekday)
        let datePredicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.trackerDate), date as CVarArg)
        return NSCompoundPredicate(type: .or, subpredicates: [datePredicate, weekdayPredicate])
    }
    
    private func createFetchedResultsController() -> NSFetchedResultsController<TrackerCoreData>? {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = createPredicate()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "isPinned", ascending: false),
            NSSortDescriptor(key: "category.trackerCategoryTitle", ascending: true),
            NSSortDescriptor(key: "trackerName", ascending: true)
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
    
    private func createOrUpdateTracker(_ trackerCoreData: TrackerCoreData, with tracker: Tracker) {
        trackerCoreData.trackerID = tracker.trackerID
        trackerCoreData.trackerName = tracker.trackerName
        trackerCoreData.trackerColor = tracker.trackerColor
        trackerCoreData.trackerEmoji = tracker.trackerEmoji
        let scheduleDate = tracker.trackerSchedule.compactMap {
            $0?.rawValue }.joined(separator: ",")
        trackerCoreData.trackerSchedule = scheduleDate
        trackerCoreData.trackerDate = tracker.trackerDate
        trackerCoreData.isPinned = trackerCoreData.isPinned
    }
    
    private func fetchTracker(by id: UUID) throws -> TrackerCoreData {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerID == %@", id as CVarArg)
        let result = try context.fetch(fetchRequest)
        guard let trackerCoreData = result.first else { return TrackerCoreData(context: context) }
        return trackerCoreData
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
