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
    private(set) var flowCollectionViewBottomConstraint: NSLayoutConstraint?
    let noGIFsLabel = UILabel()
    let noResultsFoundLabel = UILabel()
    private(set) var noGIFsLabelCenterYConstraint: NSLayoutConstraint?
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        noGIFsLabelCenterYConstraint?.constant = -safeAreaInsets.top / 2
    }
    
    override func setupBackground() {
        backgroundColor = .lightSnapperRocksBlue
    }
    
    override func setupSubviews() {
        setupFlowCollectionView()
        setupNoGIFsLabel()
        setupNoResultsFoundLabel()
    }
    
    private func setupFlowCollectionView() {
        flowCollectionView.backgroundColor = .clear
        flowCollectionView.keyboardDismissMode = .onDrag
        flowCollectionView.alwaysBounceVertical = true
    }
    
    private func setupNoGIFsLabel() {
        noGIFsLabel.text = .Your_search_history_appear_here
        setup(infoLabel: noGIFsLabel)
    }
    
    private func setupNoResultsFoundLabel() {
        noResultsFoundLabel.text = .No_results_found
        setup(infoLabel: noResultsFoundLabel)
    }
    
    private func setup(infoLabel: UILabel) {
        infoLabel.font = .appMediumFont(ofSize: 18)
        infoLabel.textColor = .white
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
    }
    
    override func addSubviews() {
        addSubview(flowCollectionView,
                   constraints: [pinAllEdges()])
        flowCollectionViewBottomConstraint = flowCollectionView.constraint(for: flowCollectionView.bottomAnchor)
        flowCollectionView.addSubview(noGIFsLabel,
                                      constraints: [pinToCenter(),
                                                    equal(\.widthAnchor, multiplier: 0.9)])
        noGIFsLabelCenterYConstraint = noGIFsLabel.constraint(for: noGIFsLabel.centerYAnchor)
        flowCollectionView.addSubview(noResultsFoundLabel,
                                      constraints: [pinToCenter(of: noGIFsLabel)])
        flowCollectionView.addSubview(activityIndicator,
                                      constraints: [pinToCenter(of: noGIFsLabel)])
    }
}
