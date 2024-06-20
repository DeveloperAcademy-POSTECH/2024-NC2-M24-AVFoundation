//
//  PreFourFrameView.swift
//  LiveFourCut
//
//  Created by Greem on 6/20/24.
//

import UIKit
import Combine

extension FourCutPreViewController{
    final class PreFourFrameView: UIStackView{
        var containers:[AVAssetContainer]! {
            didSet{
                guard let containers, containers.count == 4 else { return }
                for (offset,container) in containers.enumerated(){
                    imageViews[offset].container = container
                }
            }
        }
        var minDuration:Float!{
            didSet{
                guard let minDuration else { return }
                imageViews.forEach({ $0.minDuration = minDuration })
            }
        }
        private var imageViews:[PreCardView] = (0..<4).map{_ in PreCardView()}
        private lazy var upperStack = {
            let subViews = [imageViews[0],imageViews[1]]
            let stView = UIStackView(arrangedSubviews: subViews)
            stView.axis = .horizontal
            stView.alignment = .fill
            stView.distribution = .fillEqually
            stView.spacing = 10
            return stView
        }()
        
        private lazy var lowerStack = {
            let subViews = [imageViews[2],imageViews[3]]
            let stView = UIStackView(arrangedSubviews: subViews)
            stView.axis = .horizontal
            stView.distribution = .fillEqually
            stView.alignment = .fill
            stView.spacing = 10
            return stView
        }()
        var cancellable = Set<AnyCancellable>()
        
        init(){
            super.init(frame: .zero)
            [upperStack,lowerStack].forEach{ addArrangedSubview($0) }
            self.axis = .vertical
            self.layer.cornerRadius = 20
            self.alignment = .fill
            self.distribution = .fill
            self.spacing = 10
            self.backgroundColor = .systemGray3
            self.isLayoutMarginsRelativeArrangement = true
            self.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            self.tag = 0
        }
        required init(coder: NSCoder) {
            fatalError("Don't use storyboard")
        }
        func play(){ self.imageViews.forEach({ $0.play() }) }
    }
}

