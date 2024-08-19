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
        result.enumerateObjects(options:.concurrent) { asset, _, _ in
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


