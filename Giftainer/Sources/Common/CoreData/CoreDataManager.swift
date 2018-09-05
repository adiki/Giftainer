//
//  CoreDataManager.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 02/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import CoreData
import Foundation
import RxSwift

class CoreDataManager: ObjectsManager {    
    
    private let persistentContainer: NSPersistentContainer
    private let mainContext: NSManagedObjectContext
    private let backgroundContext: NSManagedObjectContext
    private var tokens: [Any] = []
    private let backgroundScheduler = ConcurrentDispatchQueueScheduler(qos: .userInitiated)
    
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
        mainContext = persistentContainer.viewContext
        backgroundContext = persistentContainer.newBackgroundContext()
        
        setupQueryGenerations()
        setupContextNotificationObserving()
    }
    
    func makeGIFsProvider() -> AnyObjectsProvider<GIF> {
        let request = CDGIF.sortedFetchRequest
        setup(fetchRequest: request)
        let coreDataObjectsProvider = makeObjectsProvider(with: request)
        return AnyObjectsProvider(objectsProvider: coreDataObjectsProvider)
    }
    
    func save(gifs: [GIF]) -> Completable {
        return Completable.create { [backgroundContext] observer in
            backgroundContext.performChanges {
                for gif in gifs {
                    _ = CDGIF.findOrCreate(gif: gif, in: backgroundContext)
                }
                observer(.completed)
            }
            return Disposables.create()
        }
        .observeOn(backgroundScheduler)
    }
    
    private func setup<Result: NSFetchRequestResult>(fetchRequest: NSFetchRequest<Result>) {
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.fetchBatchSize = 30
    }
    
    private func makeObjectsProvider<T: Convertible>(with request: NSFetchRequest<T>) -> CoreDataObjectsProvider<T> {
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
    
    static func makeObjectsManager(completion: @escaping (ObjectsManager) -> Void) {
        let persistentContainer = NSPersistentContainer(name: "Giftainer", managedObjectModel: managedObjectModel)
        let storeURL = URL.documents.appendingPathComponent("Giftainer.giftainer")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.shouldMigrateStoreAutomatically = true
        persistentContainer.persistentStoreDescriptions = [storeDescription]
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("\(error)")
            } else {
                let coreDataManager = CoreDataManager(persistentContainer: persistentContainer)
                completion(coreDataManager)
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
