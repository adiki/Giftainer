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
    let tooltipLabel = UILabel()
    let tooltipButton = UIButton()
    let tooltipView = UIView()
    let noGIFsLabel = UILabel()
    let noResultsFoundLabel = UILabel()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    override func layoutSubviews() {
        super.layoutSubviews()
        noGIFsLabel.constraint(for: noGIFsLabel.centerYAnchor,
                               and: giftainerCollectionView.centerYAnchor)?.constant = -safeAreaInsets.top / 2
    }
    
    override func setupBackground() {
        backgroundColor = .lightSnapperRocksBlue
    }
    
    override func setupSubviews() {
        setupGiftainerCollectionView()
        setupTooltip()
        setupNoGIFsLabel()
        setupNoResultsFoundLabel()
    }
    
    private func setupGiftainerCollectionView() {
        giftainerCollectionView.backgroundColor = .clear
        giftainerCollectionView.keyboardDismissMode = .onDrag
        giftainerCollectionView.alwaysBounceVertical = true
    }
    
    private func setupTooltip() {
        tooltipLabel.font = .appMediumFont(ofSize: 18)
        tooltipLabel.textColor = .snapperRocksBlue
        tooltipLabel.numberOfLines = 0
        tooltipLabel.textAlignment = .center
        
        tooltipButton.setImage(#imageLiteral(resourceName: "Close").withRenderingMode(.alwaysTemplate), for: .normal)
        tooltipButton.tintColor = .snapperRocksBlue
        
        tooltipView.backgroundColor = .black
        tooltipView.layer.cornerRadius = 10
        tooltipView.alpha = 0
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
        let margin: CGFloat = 10
        addSubview(giftainerCollectionView,
                   constraints: [pinAllEdges()])
        tooltipView.addSubview(tooltipLabel,
                               constraints: [pinVerticalEdges(margin: margin),
                                             equal(\.leadingAnchor)])
        tooltipView.addSubview(tooltipButton,
                               constraints: [pinVerticalEdges(margin: margin),
                                             equal(\.leadingAnchor, to: tooltipLabel, \.trailingAnchor, constant: margin),
                                             equal(\.trailingAnchor, constant: -2 * margin)])
        addSubview(tooltipView,
                   constraints: [equal(\.safeAreaLayoutGuide.topAnchor, constant: 10),
                                 equal(\.centerXAnchor),
                                 equal(\.widthAnchor, multiplier: 0.9)])
        giftainerCollectionView.addSubview(noGIFsLabel,
                                      constraints: [pinToCenter(),
                                                    equal(\.widthAnchor, multiplier: 0.9)])
        giftainerCollectionView.addSubview(noResultsFoundLabel,
                                      constraints: [pinToCenter(of: noGIFsLabel)])
        giftainerCollectionView.addSubview(activityIndicator,
                                      constraints: [pinToCenter(of: noGIFsLabel)])
    }
}
