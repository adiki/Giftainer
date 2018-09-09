//
//  FeedView.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 01/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import UIKit

class FeedView: View {
    
    let giftainerCollectionView = UICollectionView(frame: .zero, collectionViewLayout: GiftainerLayout())
    let noGIFsLabel = UILabel()
    let noResultsFoundLabel = UILabel()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        noGIFsLabel.constraint(for: noGIFsLabel.centerYAnchor, and: centerYAnchor)?.constant = -safeAreaInsets.top / 2
    }
    
    override func setupBackground() {
        backgroundColor = .lightSnapperRocksBlue
    }
    
    override func setupSubviews() {
        setupGiftainerCollectionView()
        setupNoGIFsLabel()
        setupNoResultsFoundLabel()
    }
    
    private func setupGiftainerCollectionView() {
        giftainerCollectionView.backgroundColor = .clear
        giftainerCollectionView.keyboardDismissMode = .onDrag
        giftainerCollectionView.alwaysBounceVertical = true
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
        addSubview(giftainerCollectionView,
                   constraints: [pinAllEdges()])
        giftainerCollectionView.addSubview(noGIFsLabel,
                                      constraints: [pinToCenter(),
                                                    equal(\.widthAnchor, multiplier: 0.9)])
        giftainerCollectionView.addSubview(noResultsFoundLabel,
                                      constraints: [pinToCenter(of: noGIFsLabel)])
        giftainerCollectionView.addSubview(activityIndicator,
                                      constraints: [pinToCenter(of: noGIFsLabel)])
    }
}
