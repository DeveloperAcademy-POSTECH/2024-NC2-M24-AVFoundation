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
    let idx: Int
    let minDuration:Float
    let originalAssetURL:String
}
