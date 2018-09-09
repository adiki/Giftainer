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
    
    let imageView = UIImageView()
    let progressView  = UIProgressView()
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    private(set) var disposeBag = DisposeBag()
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        imageView.image = nil
        progressView.progress = 0
        progressView.isHidden = true
        activityIndicatorView.startAnimating()
    }
    
    func dispose() {
        disposeBag = DisposeBag()
    }
    
    override func setupBackground() {
        backgroundColor = .clear
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
    }
    
    override func setupSubviews() {
        progressView.tintColor = .lime
        progressView.isHidden = true
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
