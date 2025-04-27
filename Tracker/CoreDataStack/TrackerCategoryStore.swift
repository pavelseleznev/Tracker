//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Pavel Seleznev on 4/22/25.
//

import UIKit
import CoreData

final class TrackerCategoryStore: NSObject {
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    var trackersCategories: [TrackerCategory] {
        guard
            let fetchedObjects = self.fetchedResultsController?.fetchedObjects,
            let trackersCategories = try? fetchedObjects.map({ try self.fetchCategories(from: $0) })
        else { return [] }
        return trackersCategories
    }
    
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    private var updatedIndexes: IndexSet?
    
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
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.trackerCategoryTitle, ascending: true)
        ]
        let controller = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        self.fetchedResultsController = controller
        try controller.performFetch()
    }
    
    private func fetchCategories(from trackerCategoryStore: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let trackerCategoryTitle = trackerCategoryStore.trackerCategoryTitle else {
            throw TrackerCategoryStoreError.trackerCategoryTitleDecodingError
        }
        var trackers: [Tracker] = []
        
        if let trackerSet = trackerCategoryStore.tracker as? Set<TrackerCoreData> {
            for trackerCoreData in trackerSet {
                if let trackerColor = UIColor(named: "Color selection 17") {
                    let tracker = Tracker(
                        trackerID: trackerCoreData.trackerID ?? UUID(),
                        trackerName: trackerCoreData.trackerName ?? "",
                        trackerColor: trackerColor,
                        trackerEmoji: trackerCoreData.trackerEmoji ?? "",
                        trackerSchedule: (DaysValueTransformer().reverseTransformedValue(trackerCoreData.trackerSchedule) as? [Weekdays?]) ?? [],
                        trackerDate: trackerCoreData.trackerDate
                    )
                    trackers.append(tracker)
                }
            }
        }
        return TrackerCategory(
            trackerCategoryTitle: trackerCategoryTitle,
            trackerCategoryList: trackers
        )
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
        updatedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if let inserted = insertedIndexes,
           let deleted = deletedIndexes,
           let updated = updatedIndexes {
            delegate?.updateTrackersCollectionView(
                self,
                TrackerIndexes(
                    insertedIndexes: inserted,
                    deletedIndexes: deleted,
                    updatedIndexes: updated
                )
            )
        }
        insertedIndexes = nil
        deletedIndexes = nil
        updatedIndexes = nil
    }
    
    func controller(
        _ controller: NSFetchedResultsController<NSFetchRequestResult>,
        didChange anObject: Any,
        at indexPath: IndexPath?,
        for type: NSFetchedResultsChangeType,
        newIndexPath: IndexPath?
    ) {
        switch type {
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case.update:
            if let indexPath = indexPath {
                updatedIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
    }
}

protocol TrackerCategoryStoreDelegate: AnyObject {
    func updateTrackersCollectionView(_ store: TrackerCategoryStore, _ update: TrackerIndexes)
}
