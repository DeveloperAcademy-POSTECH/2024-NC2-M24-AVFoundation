//
//  ImageContainer.swift
//  LiveFourCut
//
//  Created by Greem on 6/19/24.
//

import Foundation
import UIKit
struct ImageContainer:Identifiable {
    var id: String // PHAsset Local Identifier
    var image: UIImage // 이미지
    var idx: Int // 앨범에서 가져올 때 인덱스
}
