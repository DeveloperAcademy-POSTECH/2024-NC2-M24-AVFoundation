//
//  LPtoAVService.swift
//  LiveFourCut
//
//  Created by Greem on 6/17/24.
//

import Foundation
import Photos
import PhotosUI
import Combine
enum LPtoAVError:Error { }

protocol LPtoAVServiceProtocol { }
actor LPtoAVService: NSObject{
    private var originURLAssets:[(String,AVURLAsset)] = []
    private var assetCounter:Int = -1{
        didSet{
            guard assetCounter == 0 else {return}
            assetCounter = -1
            Task{
                do{
                    try await adaptNewMedias()
                }catch{
                    fatalError("새로운 영상 만들기 실패")
                }
            }
        }
    }
    var minDuration:Float = 1000
    let wow: PassthroughSubject<[AVURLAsset],Never> = .init()
    override init() {
        super.init()
    }
    func presentAlbumPicker(){
        
    }
}
extension LPtoAVService{
    
    func pickerResultAppender(assets:PHFetchResult<PHAsset>) {
//        PHLivePhoto()
        assetCounter = assets.count
        originURLAssets.removeAll()
        minDuration = 1000
        assets.enumerateObjects(options: .concurrent) { asset, idx, pointer in
            let convertedIdentifier = asset.localIdentifier.replacingOccurrences(of: "/", with: "_")
            Task{
                do{
                    let urlAsset:AVURLAsset = try await asset.convertToAVURLAsset()
                    let value:Float = (try? await Float(urlAsset.load(.duration).value)) ?? 1 // 여기 에러 처리 필요함
                    let timeScale: Float = (try? await Float(urlAsset.load(.duration).timescale)) ?? 1 // 여기 에러 처리 필요함
                    let secondsLength = value / timeScale
                    self.minDuration = min(secondsLength,self.minDuration)
                    self.originURLAssets.append((convertedIdentifier,urlAsset))
                }catch{
                    fatalError("영상 추출 에러")
                }
                self.assetCounter -= 1
            }
        }
        
    }
    func adaptNewMedias() async throws{
            let newAssets:[AVURLAsset] = try await originURLAssets.asyncMap({ v in
                try await v.1.createClippeAVURLAsset(identifier: v.0, end: self.minDuration)
            })
        wow.send(newAssets)
    }
}
extension PHAsset{
    // AVURLAsset은 AVAsset의 자식 클래스... url 값을 얻을 수 있어서 AVURLAsset 타입으로 반환
    func convertToAVURLAsset() async throws -> AVURLAsset{
        return try await withCheckedThrowingContinuation {[weak self] continuation in
            guard let self else {fatalError("이게 왜 사라져...")}
            requestContentEditingInput(with: nil) { input, info in
                guard let input,let imageURL = input.fullSizeImageURL else {return}
                let videoURLString = imageURL.absoluteString.replacingOccurrences(of: ".HEIC", with: ".MOV")
                guard let videoURL = URL(string: videoURLString) else {fatalError("변환 실패")}
                let urlAsset = AVURLAsset(url: videoURL)
                continuation.resume(returning: urlAsset)
            }
        }
    }
    
}
extension AVAsset{
    func createClippeAVURLAsset(identifier: String,start:Float = 0,end:Float) async throws -> AVURLAsset{
        let startTime = CMTime(seconds: Double(start), preferredTimescale: 600)
        let endTime = CMTime(seconds: Double(end), preferredTimescale: 600)
        let timeRange = CMTimeRange(start: startTime, end: endTime)
        guard let exportSession = AVAssetExportSession(asset: self, presetName: AVAssetExportPresetHighestQuality) else {
            fatalError("AVAsset 방출 타입으로 전환 실패")
        }
        exportSession.outputFileType = .mov
        let tempDirectory = FileManager.default.temporaryDirectory
        let newFileURL = tempDirectory.appendingPathComponent("\(identifier).MOV")
        exportSession.outputURL = newFileURL
        exportSession.timeRange = timeRange
        await exportSession.export()
        let newAsset = AVURLAsset(url: newFileURL)
        return newAsset
    }
}
