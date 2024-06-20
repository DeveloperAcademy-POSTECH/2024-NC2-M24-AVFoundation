//
//  AVAssetContainer.swift
//  LiveFourCut
//
//  Created by Greem on 6/20/24.
//

import Foundation
import AVFoundation

struct AVAssetContainer:Identifiable {
    var id: String
    let asset:AVAsset
    let idx: Int
    let originalAssetURL:String
    var tempFileName:String{
        id.replacingOccurrences(of: "/", with: "-")
    }
}
