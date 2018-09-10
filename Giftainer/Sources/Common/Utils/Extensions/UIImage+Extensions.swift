//
//  UIImage+Extensions.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 06/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    var cacheCost: Int? {
        if let images = self.images {
            return calculateBytesSize(for: images)
        } else {
            return bytesSize
        }
    }
    
    private func calculateBytesSize(for images: [UIImage]) -> Int? {
        let costs = images.compactMap { $0.bytesSize }
        guard images.count == costs.count else {
            return nil
        }
        return costs.reduce(0, +)
    }
    
    private var bytesSize: Int? {
        guard let cgImage = cgImage else {
            return nil
        }
        return cgImage.height * cgImage.bytesPerRow
    }

    func makePendulum() -> UIImage {
        guard var images = images else {
            return self
        }
        let frameTime = duration / Double(images.count)
        images = images + images.dropFirst().dropLast().reversed()
        return UIImage.animatedImage(with: images,
                                     duration: frameTime * Double(images.count)) ?? self
    }
    
    func decoded() -> UIImage {
        guard let cgImage = self.cgImage else {
            return self
        }
        let width = cgImage.width
        let height = cgImage.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        if let context = CGContext(data: nil,
                                   width: width,
                                   height: height,
                                   bitsPerComponent: 8,
                                   bytesPerRow: width * 4,
                                   space: colorSpace,
                                   bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) {
            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
            if let drawnImage = context.makeImage() {
                return UIImage(cgImage: drawnImage)
            } else {
                return self
            }
        }
        return self
    }
}
