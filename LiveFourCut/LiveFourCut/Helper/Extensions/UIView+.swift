//
//  UIView+.swift
//  LiveFourCut
//
//  Created by Greem on 6/21/24.
//

import UIKit
extension UIView {
  func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
}
