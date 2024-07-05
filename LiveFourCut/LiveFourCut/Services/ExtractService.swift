//
//  ExtractService.swift
//  LiveFourCut
//
//  Created by Greem on 7/3/24.
//

import Foundation
import AVFoundation
import CoreImage
enum ExtractError: Error{
    case emptyContainer
}
class ExtractService{
    var avAssetContainers: [AVAssetContainer] = []
    var minDuration: Double = 0.47
    var frameCounts:Int{ avAssetContainers.count }
    private let fps:Double = 24
    func extractFrameImages() async throws -> [[CGImage]] {
        guard !avAssetContainers.isEmpty else { throw ExtractError.emptyContainer }
        let imageDatas: [[CGImage]] = try await withThrowingTaskGroup(of: (Int,[CGImage]).self) { taskGroup in
            for (offset,v) in avAssetContainers.enumerated(){
                taskGroup.addTask {[minDuration,fps] in
                    let asset = AVAsset(url: URL(string: v.originalAssetURL)!)
                    let generator = AVAssetImageGenerator(asset: asset)
                    generator.appliesPreferredTrackTransform = true
                    generator.requestedTimeToleranceBefore = .init(seconds: Double(1 / (fps * 2)), preferredTimescale: 600)
                    generator.requestedTimeToleranceAfter = .init(seconds: Double(1 / (fps * 2)), preferredTimescale: 600)
                    var imageDatas:[CGImage] = []
                    var lastImage: CGImage!
                    let time = CMTime(seconds: 0, preferredTimescale: 600)
                    let imgContain = try await generator.image(at: time)
                    imageDatas.append(imgContain.image)
                    lastImage = imgContain.image
                    for idx in (1..<Int(minDuration * fps)){
                        let time = CMTime(seconds: Double(idx) / 24, preferredTimescale: 600)
                        let imgContain = try? await generator.image(at: time)
                        if let imgContain{ 
                            imageDatas.append(imgContain.image)
                            lastImage = imgContain.image
                        }
                        else{ imageDatas.append(lastImage) }
                    }
                    return (offset,imageDatas)
                }
            }
            var imageContainers: [[CGImage]] = Array(repeating:[], count: frameCounts)
            for try await imageDatas in taskGroup{ imageContainers[imageDatas.0] = imageDatas.1 }
            return imageContainers
        }
        return imageDatas
    }
}
