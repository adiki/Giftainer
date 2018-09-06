//
//  FeedGIFCell.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 06/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import UIKit

class FeedGIFCell: CollectionViewCell {
    
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    override func prepareForReuse() {
        super.prepareForReuse()
        activityIndicatorView.startAnimating()
    }
    
    override func setupBackground() {
        backgroundColor = .clear
        contentView.layer.cornerRadius = 10
    }
    
    override func setupSubviews() {
        activityIndicatorView.startAnimating()
    }
    
    override func addSubviews() {
        contentView.addSubview(activityIndicatorView,
                               constraints: [pinToCenter()])
    }
}
