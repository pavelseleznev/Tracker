//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Pavel Seleznev on 4/22/25.
//

import CoreData

final class TrackerRecordStore: NSObject {
    
    weak var delegate: NSFetchedResultsControllerDelegate? {
        didSet {
            fetchedResultsController?.delegate = delegate
        }
    }
    
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>?
    
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
    
    func fetchRequestDays(for id: UUID) throws -> [Date] {
        let requestDays: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        requestDays.predicate = NSPredicate(format: "trackerID == %@", id as CVarArg)
        let result = try context.fetch(requestDays)
        let dates = result.compactMap { $0.trackerDate }
        return dates
    }
    
    func loadCurrentTracker(trackerID: UUID, trackerDate: Date) throws {
        if let currentTracker = try fetchTrackerRecord(trackerID: trackerID, trackerDate: trackerDate) {
            context.delete(currentTracker)
        } else {
            if let createdDate = Date().createDateForTracker() {
                if trackerDate <= createdDate {
                    let newRecord = TrackerRecordCoreData(context: context)
                    newRecord.trackerID = trackerID
                    newRecord.trackerDate = trackerDate
                }
            } else {
                assertionFailure("[loadCurrentTracker]: Failed to create a valid date for comparison.")
                return
            }
        }
        try context.save()
    }
    
    private func fetchTrackerRecord(trackerID: UUID, trackerDate: Date) throws -> TrackerRecordCoreData? {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerID == %@ AND trackerDate == %@", trackerID as CVarArg, trackerDate as CVarArg)
        do {
            let result = try context.fetch(fetchRequest)
            return result.first
        } catch {
            throw error
        }
    }
    
    private func completedDays(for id: UUID) throws -> [Date] {
        return try fetchRequestDays(for: id)
    }
}
