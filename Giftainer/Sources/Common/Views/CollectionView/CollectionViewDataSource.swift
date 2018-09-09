//
//  CollectionViewDataSource.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 06/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

class CollectionViewDataSource<Object, Cell: UICollectionViewCell>: NSObject, UICollectionViewDataSource {
    
    let cellForConfiguration: Observable<(Cell, Object)>
    
    private let collectionView: UICollectionView
    private let objectsProvider: AnyObjectsProvider<Object>
    private let cellForConfigurationPublishSubject = PublishSubject<(Cell, Object)>()
    
    private let disposeBag = DisposeBag()
    
    init(collectionView: UICollectionView, objectsProvider: AnyObjectsProvider<Object>) {
        self.collectionView = collectionView
        self.objectsProvider = objectsProvider
        cellForConfiguration = cellForConfigurationPublishSubject.asObservable()
        cellForConfigurationPublishSubject.disposed(by: disposeBag)
        super.init()
        
        collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.self.description())
        objectsProvider.updates
            .subscribe(onNext: { [weak self] updates in
                self?.process(updates: updates)
            })
            .disposed(by: disposeBag)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objectsProvider.numberOfObjects()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.self.description(), for: indexPath) as? Cell else {
            fatalError("Unexpected cell type at \(indexPath)")
        }
        let object = objectsProvider.object(at: indexPath)
        cellForConfigurationPublishSubject.onNext((cell, object))
        return cell
    }
    
    private func process(updates: [Update<Object>]) {
        
        guard updates.count > 0 else {
            return
        }
        
        //iOS is not updating collection view correctly when it's not inserted into views hierarchy
        guard collectionView.window != nil else {
            collectionView.reloadData()
            return
        }
        
        collectionView.performBatchUpdates({
            for update in updates {
                switch update {
                case .insert(let indexPath):
                    self.collectionView.insertItems(at: [indexPath])
                case .update(let indexPath, let object):
                    if let cell = self.collectionView.cellForItem(at: indexPath) as? Cell {
                        self.cellForConfigurationPublishSubject.onNext((cell, object))
                    }
                case .move(let indexPath, let newIndexPath):
                    self.collectionView.deleteItems(at: [indexPath])
                    self.collectionView.insertItems(at: [newIndexPath])
                case .delete(let indexPath):
                    self.collectionView.deleteItems(at: [indexPath])
                }
            }
        }, completion: nil)
    }
}
