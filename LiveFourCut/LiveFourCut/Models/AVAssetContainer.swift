//
//  AVAssetContainer.swift
//  LiveFourCut
//
//  Created by Greem on 6/20/24.
//

import Foundation
import AVFoundation
struct AVAssetContainer:Identifiable{
    var id: String // PHAsset Local Identifier
    let asset:AVAsset // AVAsset
    let idx: Int // 앨범 Fetch시 가져온 인덱스
    let originalAssetURL:String // 원본 파일 저장 주소
    // temp directory에 위치한 현재 파일 이름.확장자
    var tempFileName:String{id.replacingOccurrences(of: "/", with: "-")}
}
