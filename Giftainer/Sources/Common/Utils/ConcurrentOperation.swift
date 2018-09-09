//
//  ConcurrentOperation.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 07/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation

class ConcurrentOperation: Operation {
    
    override var isAsynchronous: Bool {
        return true
    }
    
    private var _executing = false {
        willSet {
            willChangeValue(forKey: "isExecuting")
        }
        didSet {
            didChangeValue(forKey: "isExecuting")
        }
    }
    
    override var isExecuting: Bool {
        return _executing
    }
    
    private var _finished = false {
        willSet {
            willChangeValue(forKey: "isFinished")
        }
        
        didSet {
            didChangeValue(forKey: "isFinished")
        }
    }
    
    override var isFinished: Bool {
        return _finished
    }
    
    override func start() {
        _executing = true
        execute()
    }
    
    func execute() {
    }
    
    func finish() {
        _executing = false
        _finished = true
    }
}
