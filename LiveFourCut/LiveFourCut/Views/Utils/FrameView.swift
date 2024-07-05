//
//  FrameView.swift
//  LiveFourCut
//
//  Created by 윤동주 on 6/21/24.
//

import UIKit
import SnapKit

class FrameView: UIView {
    
    var imageViews: [UIImageView] = []
    
    init(images: [UIImage]?) {
        super.init(frame: .zero)
        setupUI(images: images)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Setup
    
    private func setupUI(images: [UIImage]?) {
        images?.forEach {
            let imageView = UIImageView(image: $0)
            imageView.contentMode = .scaleAspectFit
            self.imageViews.append(imageView)
            self.addSubview(imageView)
        }
    }
    
    private func setupConstraints() {
        if imageViews.count > 0 {
            imageViews[0].snp.makeConstraints {
                $0.bottom.equalTo(self.snp.centerY).offset(-5)
                $0.trailing.equalTo(self.snp.centerX).offset(-5)
                $0.width.equalTo(self.snp.width).dividedBy(2).offset(-5)
                $0.height.equalTo(self.snp.height).dividedBy(2).offset(-5)
            }
            
            imageViews[1].snp.makeConstraints {
                $0.bottom.equalTo(self.snp.centerY).offset(-5)
                $0.leading.equalTo(self.snp.centerX).offset(5)
                $0.width.equalTo(self.snp.width).dividedBy(2).offset(-5)
                $0.height.equalTo(self.snp.height).dividedBy(2).offset(-5)
            }
            
            imageViews[2].snp.makeConstraints {
                $0.top.equalTo(self.snp.centerY).offset(5)
                $0.trailing.equalTo(self.snp.centerX).offset(-5)
                $0.width.equalTo(self.snp.width).dividedBy(2).offset(-5)
                $0.height.equalTo(self.snp.height).dividedBy(2).offset(-5)
            }
            
            imageViews[3].snp.makeConstraints {
                $0.top.equalTo(self.snp.centerY).offset(5)
                $0.leading.equalTo(self.snp.centerX).offset(5)
                $0.width.equalTo(self.snp.width).dividedBy(2).offset(-5)
                $0.height.equalTo(self.snp.height).dividedBy(2).offset(-5)
            }
        }
    }
    
    func setImages(images: [UIImage]) {
        images.enumerated().forEach { index, image in
            if index < imageViews.count {
                self.imageViews[index].image = image
            }
        }
    }
}
