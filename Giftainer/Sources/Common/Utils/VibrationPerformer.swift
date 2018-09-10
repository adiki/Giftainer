//
//  Vibrations.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 10/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import AudioToolbox.AudioServices
import Foundation

class VibrationPerformer {
    
    func vibrate() {
        AudioServicesPlaySystemSound(1519)
    }
}
