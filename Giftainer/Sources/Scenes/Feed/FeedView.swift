//
//  FeedView.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 01/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import UIKit

class FeedView: View {
    
    let flowCollectionView = FlowCollectionView()
    
    override func setupBackground() {
        backgroundColor = UIColor.snapperRocksBlue.withAlphaComponent(0.8)
    }
    
    override func setupSubviews() {
        setupFlowCollectionView()
    }
    
    private func setupFlowCollectionView() {
        flowCollectionView.backgroundColor = .clear
        flowCollectionView.keyboardDismissMode = .onDrag
        flowCollectionView.alwaysBounceVertical = true
    }
    
    override func addSubviews() {
        addSubview(flowCollectionView,
                   constraints: [pinAllEdges()])
    }
}
