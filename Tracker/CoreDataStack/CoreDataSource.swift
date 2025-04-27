//
//  CoreDataSource.swift
//  Tracker
//
//  Created by Pavel Seleznev on 4/21/25.
//

import CoreData

final class CoreDataSource {
    
    // MARK: - Core Data stack
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(
            name: "DataModel"
        )
        container.loadPersistentStores(completionHandler: {
            (
                storeDescription,
                error
            ) in
            if let error = error as NSError? {
                fatalError(
                    "Unresolved error \(error), \(error.userInfo)"
                )
            }
        })
        return container
    }()
}
