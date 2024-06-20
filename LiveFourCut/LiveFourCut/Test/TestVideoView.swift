//
//  TestVideoView.swift
//  LiveFourCut
//
//  Created by Developer on 6/17/24.
//

import Foundation
import UIKit
import AVFoundation
extension Test{
    final class VideoView: UIView {
        private lazy var videoBackgroundView: UIView = {
            let view = UIView()
            view.backgroundColor = .systemGray
            view.translatesAutoresizingMaskIntoConstraints = false
            self.addSubview(view)
            return view
        }()
        @MainActor var item: AVPlayerItem?{
            didSet{
                guard let item else {return}
                self.player.replaceCurrentItem(with: item)
                let zeroTime = CMTime(seconds: 0, preferredTimescale: 1)
                self.player.pause()
                self.player.seek(to: zeroTime, toleranceBefore: .zero, toleranceAfter: .zero) { finished in
                    if finished {
                    } else {
//                        print("Failed to reset playback time")
                    }
                }
            }
        }
        private var player = AVPlayer()
        private var playerLayer: AVPlayerLayer?
        
        init() {
            super.init(frame: .zero)
            
            NSLayoutConstraint.activate([
                self.videoBackgroundView.leftAnchor.constraint(equalTo: self.leftAnchor),
                self.videoBackgroundView.rightAnchor.constraint(equalTo: self.rightAnchor),
                self.videoBackgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -50),
                self.videoBackgroundView.topAnchor.constraint(equalTo: self.topAnchor),
            ])
            
            let playerLayer = AVPlayerLayer(player: self.player)
            playerLayer.frame = self.videoBackgroundView.bounds
            playerLayer.videoGravity = .resizeAspectFill
            self.playerLayer = playerLayer
            self.videoBackgroundView.layer.addSublayer(playerLayer)
            let interval = CMTimeMakeWithSeconds(1, preferredTimescale: Int32(NSEC_PER_SEC))
            self.player.addPeriodicTimeObserver(forInterval: interval, queue: .global(), using: { [weak self] elapsedSeconds in
                let elapsedTimeSecondsFloat = CMTimeGetSeconds(elapsedSeconds)
                let totalTimeSecondsFloat = CMTimeGetSeconds(self?.player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
                print(elapsedTimeSecondsFloat, totalTimeSecondsFloat)
            })
            
        }
        
        required init?(coder: NSCoder) {
            fatalError()
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            self.playerLayer?.frame = self.videoBackgroundView.bounds
        }
        
        @objc private func changeValue() { }
        
        func play(){
            self.player.pause()
            let zeroTime = CMTime(seconds: 0, preferredTimescale: 1)
            self.player.seek(to: zeroTime, toleranceBefore: .zero, toleranceAfter: .zero) { finished in
                if finished {
                    self.player.play()
                } else {
//                        print("Failed to reset playback time")
                }
            }
            
        }
    }
}
