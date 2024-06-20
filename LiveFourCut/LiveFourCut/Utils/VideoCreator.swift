//
//  VideoCreator.swift
//  LiveFourCut
//
//  Created by Greem on 6/21/24.
//

import Foundation
import UIKit
import AVFoundation

class VideoCreator {
    func createVideo(from images: [UIImage], outputURL: URL, fps: Int32 = 24, completion: @escaping (Bool, Error?) -> Void) {
        print(images.count)
        guard !images.isEmpty else {
            completion(false, NSError(domain: "com.example.VideoCreator", code: -1, userInfo: [NSLocalizedDescriptionKey: "No images to create video"]))
            return
        }
        
        // 비디오 설정
        let maxNumber = images.reduce(0) { partialResult, image in
            max(partialResult,image.cgImage!.width * 3,image.cgImage!.height * 3)
        }
        print("maxNumber \(maxNumber)")
        let videoSize = CGSize(width: images.last!.cgImage!.width * 3, height: images.last!.cgImage!.height * 3)
        let writer = try! AVAssetWriter(outputURL: outputURL, fileType: .mp4)
        
        let settings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: videoSize.width,
            AVVideoHeightKey: videoSize.height
        ]
        
        let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
        writerInput.expectsMediaDataInRealTime = false
        writer.add(writerInput)
        
        let sourcePixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
            kCVPixelBufferWidthKey as String: videoSize.width,
            kCVPixelBufferHeightKey as String: videoSize.height
        ]
        
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: sourcePixelBufferAttributes)
        
        writer.startWriting()
        writer.startSession(atSourceTime: .zero)
        
        var frameCount: Int64 = 0
        let frameDuration = CMTimeMake(value: 1, timescale: fps)
        
        for image in images {
            autoreleasepool {
                while !writerInput.isReadyForMoreMediaData { }
                
                guard let pixelBuffer = self.pixelBuffer(from: image, size: videoSize) else {
                    completion(false, NSError(domain: "com.example.VideoCreator", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create pixel buffer"]))
                    return
                }
                
                let frameTime = CMTimeMake(value: frameCount, timescale: fps)
                adaptor.append(pixelBuffer, withPresentationTime: frameTime)
                frameCount += 1
            }
        }
        
        writerInput.markAsFinished()
        writer.finishWriting {
            completion(writer.status == .completed, writer.error)
        }
    }
    
    private func pixelBuffer(from image: UIImage, size: CGSize) -> CVPixelBuffer? {
        let options: [CFString: Any] = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue as Any,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue as Any
        ]
        
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(size.width), Int(size.height), kCVPixelFormatType_32ARGB, options as CFDictionary, &pixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        let context = CGContext(data: CVPixelBufferGetBaseAddress(buffer),
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.draw(image.cgImage!, in: CGRect(origin: .zero, size: size))
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        return buffer
    }
}
