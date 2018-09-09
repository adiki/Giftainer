//
//  FeedGIFCell.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 06/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

class FeedGIFCell: CollectionViewCell {
    
    var id: String? {
        didSet {
            imageView.backgroundColor = id?.color ?? .white
        }
    }
        
    let imageView = UIImageView()
    let progressView  = UIProgressView()
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    let panGestureRecognizer = UIPanGestureRecognizer()
    
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        imageView.image = nil
        imageView.alpha = 1
        progressView.progress = 0
        progressView.isHidden = true
        activityIndicatorView.startAnimating()
        set(imageViewDeltaConstant: 0)
    }
    
    func set(imageViewDeltaConstant: CGFloat) {
        imageView.constraint(for: imageView.leadingAnchor,
                             and: contentView.leadingAnchor)?.constant = imageViewDeltaConstant
        imageView.constraint(for: imageView.trailingAnchor,
                             and: contentView.trailingAnchor)?.constant = imageViewDeltaConstant
    }
    
    override func setupBackground() {
        backgroundColor = .clear
    }
    
    override func setupSubviews() {
        setupImageView()
        setupProgressView()
        setupActivityIndicatorView()
    }
    
    private func setupImageView() {
        imageView.addGestureRecognizer(panGestureRecognizer)
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        panGestureRecognizer.delegate = self
        
    }
    
    private func setupProgressView() {
        progressView.tintColor = .lime
        progressView.isHidden = true
    }
    
    private func setupActivityIndicatorView() {
        activityIndicatorView.startAnimating()
    }
    
    override func addSubviews() {
        contentView.addSubview(imageView,
                               constraints: [pinAllEdges()])
        contentView.addSubview(progressView,
                               constraints: [pinHorizontalEdges(),
                                             constant(\.heightAnchor, constant: 5),
                                             equal(\.bottomAnchor)])
        contentView.addSubview(activityIndicatorView,
                               constraints: [pinToCenter()])
    }
}

extension FeedGIFCell: UIGestureRecognizerDelegate {
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let translation = panGestureRecognizer.translation(in: nil)
        return abs(translation.x) > abs(translation.y)
    }
}
