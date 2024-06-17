//
//  LPtoAVService.swift
//  LiveFourCut
//
//  Created by Developer on 6/17/24.
//

import Foundation
import Photos

final class LPtoAVService: NSObject{
    override init() {
        super.init()
    }
    func adaptNewMdeia(asset:AVAsset,identifier:String,minimumScale:Float) async -> AVAsset{
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            fatalError("AVAsset 방출 타입으로 전환 실패")
        }
        exportSession.outputFileType = .mov
        let tempDirectory = FileManager.default.temporaryDirectory
        let newFileURL = tempDirectory.appendingPathComponent("\(identifier).MOV")
        exportSession.outputURL = newFileURL
        let value:Float = (try? await Float(asset.load(.duration).value)) ?? 0
        let timeScale: Float = (try? await Float(asset.load(.duration).timescale)) ?? 1
        let secondsLength = value / timeScale
        let startTime = CMTime(seconds: Double(0), preferredTimescale: 1000)
        let endTime = CMTime(seconds: Double(secondsLength * 0.8), preferredTimescale: 1000)
        let timeRange = CMTimeRange(start: startTime, end: endTime)
        exportSession.timeRange = timeRange
        print("뽑아보자")
        await exportSession.export()
        let newAsset = AVAsset(url: newFileURL)
        print("새로운 에셋 정보",newAsset)
        return newAsset
    }
}
