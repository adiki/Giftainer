//
//  CoreDataModelsProvider.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 02/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import CoreData
import Foundation
import RxCocoa
import RxSwift

class CoreDataObjectsProvider<CoreDataObject: Convertible>: ObjectsProvider<CoreDataObject.ConvertedType>, NSFetchedResultsControllerDelegate where CoreDataObject: NSFetchRequestResult {
    
    typealias Object = CoreDataObject.ConvertedType
    
    private let numberOfObjectsBehaviorRelay: BehaviorRelay<Int>
    private let updatesPublishSubject = PublishSubject<[Update<Object>]>()
    private let fetchedResultsController: NSFetchedResultsController<CoreDataObject>
    
    private var updatesList: [Update<Object>] = []
    
    init(fetchedResultsController: NSFetchedResultsController<CoreDataObject>) {
        self.fetchedResultsController = fetchedResultsController
        try! fetchedResultsController.performFetch()
        let numberOfObjects = fetchedResultsController.sections?[0].numberOfObjects ?? 0
        numberOfObjectsBehaviorRelay = BehaviorRelay(value: numberOfObjects)
        
        super.init(numberOfObjects: numberOfObjectsBehaviorRelay.asObservable(),
                   updates: updatesPublishSubject.asObservable())
        
        fetchedResultsController.delegate = self
    }
    
    func objectAtIndexPath(_ indexPath: IndexPath) -> Object {
        return fetchedResultsController.object(at: indexPath).convert()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updatesList = []
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            guard let newIndexPath = newIndexPath else { fatalError("Index path should be not nil") }
            updatesList.append(.insert(newIndexPath))
        case .update:
            guard let newIndexPath = newIndexPath else { fatalError("Index path should be not nil") }
            let object = objectAtIndexPath(newIndexPath)
            updatesList.append(.update(newIndexPath, object))
        case .move:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            guard let newIndexPath = newIndexPath else { fatalError("New index path should be not nil") }
            updatesList.append(.move(indexPath, newIndexPath))
        case .delete:
            guard let indexPath = indexPath else { fatalError("Index path should be not nil") }
            updatesList.append(.delete(indexPath))
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updatesPublishSubject.onNext(updatesList)
    }
}
