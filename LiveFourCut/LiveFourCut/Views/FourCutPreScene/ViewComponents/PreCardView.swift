//
//  PreCardView.swift
//  LiveFourCut
//
//  Created by Greem on 6/21/24.
//

import Foundation
import UIKit
import AVFoundation
import Combine
extension FourCutPreViewController.PreFourFrameView{
    final class PreCardView: UIView {
        var minDuration: Float = 1000{
            didSet{
                let timeRange = CMTimeRange(start: .zero, duration: CMTime(seconds: Float64(minDuration), preferredTimescale: 10))
                if let item,self.looper == nil{
                    self.looper = AVPlayerLooper(player: queuePlayer, templateItem: item,timeRange: timeRange)
                }
            }
        }
        var container: AVAssetContainer? {
            didSet {
                guard let container else {
                    item = nil
                    return
                }
                item = AVPlayerItem(asset: AVAsset(url: URL(string:container.originalAssetURL)!))
            }
        }
        var cancellabe = Set<AnyCancellable>()
        private var item: AVPlayerItem? {
            didSet{
                guard let item else {
                    print("여기가 불리는건가?")
                    self.queuePlayer.pause()
                    self.queuePlayer.replaceCurrentItem(with: nil)
                    return
                }
                self.queuePlayer.replaceCurrentItem(with: item)
                if minDuration != 1000 && self.looper == nil{
                    Task{
                        let timeRange = CMTimeRange(start: .zero, duration: CMTime(seconds: Float64(minDuration), preferredTimescale: 10))
                        self.looper = AVPlayerLooper(player: queuePlayer, templateItem: item,timeRange: timeRange)
                    }
                }
            }
        }
        private var playerLayer: AVPlayerLayer!
        private var queuePlayer = AVQueuePlayer()
        private var looper:AVPlayerLooper?
        init() {
            super.init(frame: .zero)
            let playerLayer = AVPlayerLayer(player: self.queuePlayer)
            playerLayer.videoGravity = .resizeAspectFill
            self.queuePlayer.isMuted = true
            self.queuePlayer.items()
            self.playerLayer = playerLayer
            self.layer.addSublayer(playerLayer)
            setupConstraints()
            setupView()
        }
        required init?(coder: NSCoder) {
            fatalError("Don't use storyboard")
        }
        override func layoutSubviews() {
            super.layoutSubviews()
            self.playerLayer?.frame = self.bounds
        }
        
        private func setupConstraints() {
            self.snp.makeConstraints { make in
                make.height.equalTo(self.snp.width).multipliedBy(1.58)
            }
        }
        private func setupView() {
            self.backgroundColor = .systemGray
            self.layer.cornerRadius = 10
            self.contentMode = .scaleAspectFill // 이미지가 상하or좌우에 꽉 차도록 설정
            self.clipsToBounds = true // 벗어나는 범위는 자름
        }
        func play(){
            Task{
                print("재생이 눌림")
                queuePlayer.play()
            }
        }
    }
}
