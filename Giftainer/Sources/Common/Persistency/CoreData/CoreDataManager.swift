//
//  CoreDataManager.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 02/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager: PersistencyManager {
    
    private let persistentContainer: NSPersistentContainer
    private let mainContext: NSManagedObjectContext
    private let backgroundContext: NSManagedObjectContext
    private var tokens: [Any] = []
    
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        mainContext = persistentContainer.viewContext
        backgroundContext = persistentContainer.newBackgroundContext()
        
        setupQueryGenerations()
        setupContextNotificationObserving()
    }
    
    func makeGIFsProvider() -> ObjectsProvider<GIF> {
        let request = CDGIF.sortedFetchRequest
        request.returnsObjectsAsFaults = false
        request.fetchBatchSize = 30
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                               managedObjectContext: mainContext,
                                                               sectionNameKeyPath: nil,
                                                               cacheName: nil)
        return CoreDataObjectsProvider(fetchedResultsController: fetchedResultsController)
    }
    
    private func setupQueryGenerations() {
        let token = NSQueryGenerationToken.current
        mainContext.perform {
            try! self.mainContext.setQueryGenerationFrom(token)
        }
        backgroundContext.perform {
            try! self.backgroundContext.setQueryGenerationFrom(token)
        }
    }
    
    private func setupContextNotificationObserving() {
        tokens.append(backgroundContext.addContextDidSaveNotificationObserver { [weak self] note in
            self?.mainContext.performMergeChanges(from: note)
        })
    }
    
    static func makePersistencyManager(completion: @escaping (PersistencyManager) -> Void) {
        let persistentContainer = NSPersistentContainer(name: "Giftainer", managedObjectModel: managedObjectModel)
        let storeURL = URL.documents.appendingPathComponent("Giftainer.giftainer")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.shouldMigrateStoreAutomatically = false
        persistentContainer.persistentStoreDescriptions = [storeDescription]
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("\(error)")
            } else {
                let coreDataManager = CoreDataManager(persistentContainer: persistentContainer)
                DispatchQueue.main.async { completion(coreDataManager) }
            }
        }
    }
    
    private static var managedObjectModel: NSManagedObjectModel = {
        let modelBundle = Bundle(for: CDGIF.self)
        let modelDirectoryName = "Giftainer.momd"
        let resource = "Giftainer"
        let omoURL = modelBundle.url(forResource: resource, withExtension: "omo", subdirectory: modelDirectoryName)
        let momURL = modelBundle.url(forResource: resource, withExtension: "mom", subdirectory: modelDirectoryName)
        guard let url = omoURL ?? momURL else { fatalError("model version not found") }
        guard let model = NSManagedObjectModel(contentsOf: url) else { fatalError("cannot open model at \(url)") }
        return model
    }()
}
