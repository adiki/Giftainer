//
//  LocalMP4Opertation.swift
//  Giftainer
//
//  Created by Adrian Śliwa on 09/09/2018.
//  Copyright © 2018 MobileSolutions. All rights reserved.
//

import AVFoundation
import Foundation
import UIKit

class LocalMP4Opertation: LocalMediaOperation {
    
    private static let ciContext = EAGLContext(api: .openGLES2).map(CIContext.init) ?? CIContext(options: nil)
    
    private let maxGIFLength = ProcessInfo.processInfo.physicalMemory / (1024 * 1024) > 2500 ? 33 : 17
    
    override func main() {
        let asset = AVAsset(url: url)
        guard let numberOfFrames = computeNumberOfFrames(for: asset),
            let images = extractImages(for: asset, numberOfFrames: numberOfFrames, maxLength: maxGIFLength) else {
            return
        }
        
        let duration = CMTimeGetSeconds(asset.duration) * Float64(images.count) / Float64(numberOfFrames)
        guard let animatedImage = UIImage.animatedImage(with: images, duration: duration) else {
            return
        }
        resultPublishSubject.onNext(animatedImage)
        resultPublishSubject.onCompleted()
        resultPublishSubject.dispose()
    }
    
    private func computeNumberOfFrames(for asset: AVAsset) -> Int? {
        guard let assetReaderOutput = makeReadyAssetReaderOutput(for: asset) else {
            return nil
        }
        var totalImagesCount = 0
        var sample: CMSampleBuffer? = assetReaderOutput.copyNextSampleBuffer()
        while !isCancelled && sample != nil {
            totalImagesCount += 1
            sample = assetReaderOutput.copyNextSampleBuffer()
        }
        if isCancelled {
            return nil
        }
        return totalImagesCount
    }
    
    private func extractImages(for asset: AVAsset, numberOfFrames: Int, maxLength: Int) -> [UIImage]? {
        
        guard let assetReaderOutput = makeReadyAssetReaderOutput(for: asset) else {
            return nil
        }
        var images: [UIImage] = []
        var sample: CMSampleBuffer? = assetReaderOutput.copyNextSampleBuffer()
        var index = 0
        let startIndex = max(0, (numberOfFrames - maxLength) / 2)
        while !isCancelled, let sampleBuffer = sample {
            if startIndex <= index {
                if images.count < maxLength {
                    if let cvImageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                        let ciImage = CIImage(cvImageBuffer: cvImageBuffer)
                        if let cgImage = LocalMP4Opertation.ciContext.createCGImage(ciImage, from: ciImage.extent) {
                            if !isCancelled {
                                let image = UIImage(cgImage: cgImage)
                                images.append(image.decoded())
                            } else {
                                break
                            }
                        }
                    }
                } else {
                    break
                }
            }
            sample = assetReaderOutput.copyNextSampleBuffer()
            index += 1
        }
        if isCancelled {
            return nil
        }
        return images
    }
    
    private func makeReadyAssetReaderOutput(for asset: AVAsset) -> AVAssetReaderTrackOutput? {
        guard let assetReader = try? AVAssetReader(asset: asset),
            let assetTrack = asset.tracks(withMediaType: .video).first else {
                resultPublishSubject.onError(GIFsError.mp4NotPersistent)
                return nil
        }
        let assetReaderOutputSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: NSNumber(value: kCVPixelFormatType_32BGRA)
        ]
        let assetReaderOutput = AVAssetReaderTrackOutput(track: assetTrack, outputSettings: assetReaderOutputSettings)
        assetReaderOutput.alwaysCopiesSampleData = false
        assetReader.add(assetReaderOutput)
        assetReader.startReading()
        return assetReaderOutput
    }
}