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
    
    var defaultGIFPredicate: NSPredicate {
        return NSPredicate(format: "%K == false", #keyPath(CDGIF.isHidden))
    }
    
    private let persistentContainer: NSPersistentContainer
    private let fileManager: FileManager
    private let logger: Logger
    private let mainContext: NSManagedObjectContext
    private let backgroundContext: NSManagedObjectContext
    private var tokens: [Any] = []
    private let backgroundScheduler = ConcurrentDispatchQueueScheduler(qos: .userInitiated)
    
    init(persistentContainer: NSPersistentContainer, fileManager: FileManager, logger: Logger) {
        self.persistentContainer = persistentContainer
        self.fileManager = fileManager
        self.logger = logger
        mainContext = persistentContainer.viewContext
        backgroundContext = persistentContainer.newBackgroundContext()
        
        setupQueryGenerations()
        setupContextNotificationObserving()
        
        removeOldGIFs()
    }
    
    func makeGIFsProvider() -> AnyObjectsProvider<GIF> {
        let request = CDGIF.sortedFetchRequest
        request.predicate = defaultGIFPredicate
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
    
    func hide(gif: GIF) {
        backgroundContext.performChanges { [weak self, backgroundContext] in
            let cdGIF = CDGIF.findOrCreate(gif: gif, in: backgroundContext)
            cdGIF.isHidden = true
            self?.removeFromDisk(gif: gif)
        }
    }
    
    func removeFromDisk(gif: GIF) {
        do {
            try fileManager.removeItem(at: gif.localStillURL)
        } catch {
            logger.log(error.localizedDescription)
        }
        do {
            try fileManager.removeItem(at: gif.localMP4URL)
        } catch {
            logger.log(error.localizedDescription)
        }
        
    }
    
    private func makeObjectsProvider<T: Convertible>(with request: NSFetchRequest<T>) -> CoreDataObjectsProvider<T> {
        request.returnsObjectsAsFaults = false
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
    
    private func removeOldGIFs() {
        backgroundContext.performChanges { [weak self, backgroundContext] in
            let request = NSFetchRequest<CDGIF>(entityName: CDGIF.entityName)
            request.predicate = NSPredicate(format: "%K < %@", #keyPath(CDGIF.modificationDate), NSDate(timeIntervalSinceNow: -.week))
            request.returnsObjectsAsFaults = true
            let oldGIFs = try! backgroundContext.fetch(request)
            for cdOldGIF in oldGIFs {
                self?.removeFromDisk(gif: cdOldGIF.convert())
                self?.backgroundContext.delete(cdOldGIF)
            }
        }
    }
    
    static func makeObjectsManager(logger: Logger, completion: @escaping (ObjectsManager) -> Void) {
        let persistentContainer = NSPersistentContainer(name: "Giftainer", managedObjectModel: managedObjectModel)
        let storeURL = URL.documents.appendingPathComponent("Giftainer.giftainer")
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        storeDescription.shouldMigrateStoreAutomatically = true
        storeDescription.shouldInferMappingModelAutomatically = true
        persistentContainer.persistentStoreDescriptions = [storeDescription]
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("\(error)")
            } else {
                let fileManager = FileManager.default
                let coreDataManager = CoreDataManager(persistentContainer: persistentContainer,
                                                      fileManager: fileManager,
                                                      logger: logger)
                completion(coreDataManager)
            }
        }
    }
    
    private static var managedObjectModel: NSManagedObjectModel = {
        let modelBundle = Bundle(for: CDGIF.self)        
        let resource = "Giftainer"
        guard let url = modelBundle.url(forResource: resource, withExtension: "momd") else { fatalError("model version not found") }
        guard let model = NSManagedObjectModel(contentsOf: url) else { fatalError("cannot open model at \(url)") }
        return model
    }()
}
