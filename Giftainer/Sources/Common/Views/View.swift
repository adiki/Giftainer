//
//  View.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 01/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import UIKit

class View: UIView {
    
    init() {
        super.init(frame: .zero)
        
        setupBackground()
        setupSubviews()
        addSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func setupBackground() {
        backgroundColor = .white
    }
    
    open func setupSubviews() {
    }
    
    open func addSubviews() {
    }
}
