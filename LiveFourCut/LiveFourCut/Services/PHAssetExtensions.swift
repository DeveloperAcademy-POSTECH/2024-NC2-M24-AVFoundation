//
//  PHAssetExtensions.swift
//  LiveFourCut
//
//  Created by Developer on 6/19/24.
//

import Foundation
import Photos
import UIKit
extension PHAsset{
    func convertToUIImage(size:CGSize? = nil) async throws -> UIImage{
        return try await withCheckedThrowingContinuation { [weak self] continuation in
            self?.requestContentEditingInput(with: nil) { input, info in
                guard let input, let imageURL = input.fullSizeImageURL else {return}
                let imageSourceOption = [kCGImageSourceShouldCache: false] as CFDictionary
                let imageSource: CGImageSource = CGImageSourceCreateWithURL(imageURL as CFURL, imageSourceOption)!
                let image = self!.coreDownSample(resource: imageSource,size: size)
                continuation.resume(returning: image)
            }
        }
    }
    private func coreDownSample(resource:CGImageSource,size:CGSize? = nil) -> UIImage{
        let scale = UIScreen.main.scale
        let screenSize = UIScreen.main.bounds
        let maxPixel = if let size{
             max(size.width, size.height) * scale
        }else{
            max(screenSize.width,screenSize.height) * scale
        }
        let downSampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixel
        ] as CFDictionary
        return if let downSampledImage = CGImageSourceCreateThumbnailAtIndex(resource, 0, downSampleOptions){
            UIImage(cgImage: downSampledImage)
        }else{
            UIImage(resource: .hanroro1)
        }
    }
}
