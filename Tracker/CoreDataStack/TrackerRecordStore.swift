//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Pavel Seleznev on 4/22/25.
//

import CoreData

final class TrackerRecordStore: NSObject {
    
    private weak var delegate: NSFetchedResultsControllerDelegate? {
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
                guard let tracker = try fetchTracker(id: trackerID) else { return }
                if trackerDate <= createdDate {
                    let newRecord = TrackerRecordCoreData(context: context)
                    newRecord.trackerID = trackerID
                    newRecord.trackerDate = trackerDate
                    newRecord.tracker = tracker
                }
            } else {
                assertionFailure("[loadCurrentTracker]: Failed to create a valid date for comparison.")
                return
            }
        }
        try context.save()
    }
    
    func fetchInitialDate() throws -> Date? {
        let fetchRequest: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "trackerDate", ascending: true)]
        do {
            let result = try context.fetch(fetchRequest)
            return result.first?.trackerDate
        } catch {
            throw error
        }
    }
    
    func fetchAllTrackers() throws -> [TrackerStatistics] {
        var trackers: [TrackerStatistics] = []
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "trackerName", ascending: true)]
        let result = try context.fetch(fetchRequest)
        for object in result {
            let tracker = TrackerStatistics(
                id: object.trackerID ?? UUID(),
                schedule: object.trackerSchedule?.components(separatedBy: ",").compactMap { Weekdays(rawValue: $0) } ?? [],
                dateEvent: object.trackerDate,
                completedAt: object.record?.compactMap { ($0 as? TrackerRecordCoreData)?.trackerDate} ?? []
            )
            trackers.append(tracker)
        }
        return trackers
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
    private func fetchTracker(id: UUID) throws -> TrackerCoreData? {
        let fetchRequest: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerID == %@", id as CVarArg)
        do {
            let result = try context.fetch(fetchRequest)
            return result.first
        } catch {
            throw error
        }
    }
}
