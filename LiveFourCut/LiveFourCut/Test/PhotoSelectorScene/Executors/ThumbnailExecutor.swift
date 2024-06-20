//
//  ThumbnailExecutor.swift
//  LiveFourCut
//
//  Created by Developer on 6/19/24.
//

import Foundation
import Combine
import Photos
import UIKit
actor ThumbnailExecutor{ // Actor는 상속이 가능하다
    let thumbnailsSubject: PassthroughSubject<[ImageContainer],Never> = .init()
    let progressSubject:PassthroughSubject<Float,Never> = .init()
    private var result: PHFetchResult<PHAsset>!
    private var counter: Int = -1{
        didSet{
            guard counter == 0 else {return}
            thumbnailsSubject.send(fetchItems)
            fetchItems.removeAll()
        }
    }
    private var fetchItems:[ImageContainer] = []
    func setFetchResult(result: PHFetchResult<PHAsset>) async{
        self.result = result
    }
    func run() async{
        counter = result.count
        fetchItems.removeAll()
        let resultCount = result.count
        self.progressSubject.send(0)
        result.enumerateObjects(options:.concurrent) { asset, val, idx in
            Task{
                do{
                    let image = try await asset.convertToUIImage(size: .init(width: 120, height: 120 * 1.3333)) 
                    let count = self.fetchItems.count
                    self.fetchItems.append(ImageContainer(id: asset.localIdentifier, image: image, idx: count))
                    self.counter -= 1
                    self.progressSubject.send(min(1,(Float(resultCount - self.counter) / Float(resultCount))))
                }catch{
                    fatalError("무슨 문제야")
                }
            }
        }
    }
}

actor VideoExecutor{
    let videosSubject: PassthroughSubject<[AVAssetContainer],Never> = .init()
    let progressSubject:PassthroughSubject<Float,Never> = .init()
    private var minDuration:Float = 1000
    private var result: PHFetchResult<PHAsset>!
    private var counter: Int = -1{
        didSet{
            guard counter == 0 else {return}
            counter = -1
            Task{
                try await self.exportConvertedAssetContainers()
            }
        }
    }
    private var fetchItems:[AVAssetContainer] = []
    func setFetchResult(result: PHFetchResult<PHAsset>) async{
        self.result = result
    }
    func run() async{
        counter = result.count
        fetchItems.removeAll()
        self.minDuration = 1000
        let resultCount = result.count
        self.progressSubject.send(0)
        result.enumerateObjects(options:.concurrent) { asset, val, idx in
            let convertedIdentifier = asset.localIdentifier.replacingOccurrences(of: "/", with: "_")
            Task{
                do{
                    let urlAsset:AVURLAsset = try await asset.convertToAVURLAsset()
                    let value:Float = (try? await Float(urlAsset.load(.duration).value)) ?? 1 // 여기 에러 처리 필요함
                    let timeScale: Float = (try? await Float(urlAsset.load(.duration).timescale)) ?? 1 // 여기 에러 처리 필요함
                    let secondsLength = value / timeScale
                    self.minDuration = min(secondsLength,self.minDuration)
                    let cnt = self.fetchItems.count
                    self.fetchItems.append(AVAssetContainer(id: asset.localIdentifier, asset: urlAsset, idx: cnt, originalAssetURL: convertedIdentifier))
                    self.counter -= 1
                    self.progressSubject.send(min(1, Float(resultCount - self.counter) / Float(2 * resultCount)))
                }catch{
                    fatalError("무슨 문제야")
                }
            }
        }
    }
    private func exportConvertedAssetContainers() async throws{
        var newAVssetContainers:[AVAssetContainer] = []
        let resultCount = fetchItems.count
        for (idx,item) in fetchItems.enumerated(){
            let fileName = "\(item.tempFileName).MOV"
            let newAVAsset = try await item.asset.createClippeAVURLAsset(identifier: item.tempFileName, end: self.minDuration)
            newAVssetContainers.append(AVAssetContainer(id: item.id, asset: newAVAsset, idx: item.idx, originalAssetURL: item.originalAssetURL))
            self.progressSubject.send(min(1,Float(idx) / Float(resultCount * 2) + 0.5))
        }
        fetchItems.removeAll()
        print("새 영상 컨테이너들",newAVssetContainers)
        self.videosSubject.send(newAVssetContainers)
    }
}
extension FileManager{
    func tempFileExist(fileName:String) -> Bool{
        let newFileURL = self.temporaryDirectory.appendingPathComponent(fileName)
        return self.fileExists(atPath: newFileURL.absoluteString)
    }
}
