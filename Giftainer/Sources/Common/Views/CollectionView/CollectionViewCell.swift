//
//  CollectionViewCell.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 06/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import UIKit

//This class uses template method to reduce boilerplate code when defining views
class CollectionViewCell: UICollectionViewCell {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        setupBackground()
        setupSubviews()
        addSubviews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupBackground() {
        backgroundColor = .white
    }
    
    func setupSubviews() {
    }
    
    func addSubviews() {
    }
}
