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
    var flowCollectionViewBottomConstraint: NSLayoutConstraint?
    let noGIFsLabel = UILabel()
    var noGIFsLabelCenterYConstraint: NSLayoutConstraint?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        noGIFsLabelCenterYConstraint?.constant = -safeAreaInsets.top / 2
    }
    
    override func setupBackground() {
        backgroundColor = UIColor.snapperRocksBlue.withAlphaComponent(0.8)
    }
    
    override func setupSubviews() {
        setupFlowCollectionView()
        setupNoGIFsLabel()
    }
    
    private func setupFlowCollectionView() {
        flowCollectionView.backgroundColor = .clear
        flowCollectionView.keyboardDismissMode = .onDrag
        flowCollectionView.alwaysBounceVertical = true
    }
    
    private func setupNoGIFsLabel() {
        noGIFsLabel.text = .Your_search_history_appear_here
        noGIFsLabel.font = .appMediumFont(ofSize: 17)
    }
    
    override func addSubviews() {
        addSubview(flowCollectionView,
                   constraints: [pinAllEdges()])
        flowCollectionViewBottomConstraint = flowCollectionView.constraint(for: flowCollectionView.bottomAnchor)
        flowCollectionView.addSubview(noGIFsLabel,
                                      constraints: [pinToCenter()])
        noGIFsLabelCenterYConstraint = noGIFsLabel.constraint(for: noGIFsLabel.centerYAnchor)
    }
}
