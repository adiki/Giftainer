//
//  Logging.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 07/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation

private let dateFormater: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSSSSZZZ"
    return dateFormatter
}()

private let serialQueue = DispatchQueue(label: "Logger")

func Log(_ message: String, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    serialQueue.async {
        print("\(dateFormater.string(from: Date())) [\((fileName as NSString).lastPathComponent):\(lineNumber)] \(functionName) > \(message)")
    }
}
