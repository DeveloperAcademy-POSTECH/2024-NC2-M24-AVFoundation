//
//  SharingViewController.swift
//  LiveFourCut
//
//  Created by 윤동주 on 6/19/24.
//

import UIKit
import AVFoundation

class SharingViewController: UIViewController {
    
    // MARK: - Properties
    
    /// 공유할 영상의 저장 위치 URL
    /// FlipBook에서는 해당 영상 URL에 대한 최적화를 진행함.(FlipBookAssetWriter.makeFileOutputURL(String))
    var videoURL: URL? = URL(string: "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4")
    lazy private var player: AVPlayer = {
        guard let url = videoURL else {
            fatalError("영상 URL이 제공되지 않았습니다.")
        }
        return AVPlayer(url: url)
    }()
    
    lazy private var playerLayer: AVPlayerLayer = AVPlayerLayer(player: player)
    lazy private var shareBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action,
                                                          target: self,
                                                          action: #selector(share(_:)))
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupPlayer()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = view.bounds
    }
    
    // MARK: - Setup
    
    private func setupUI(){
        playerLayer.videoGravity = .resizeAspect
        self.view.layer.addSublayer(playerLayer)
        self.navigationItem.rightBarButtonItem = shareBarButtonItem
        
    }
    
    private func setupPlayer() {
        self.player.play()
    }
    
    // MARK: - Functions
    
    @objc private func share(_ sender: UIBarButtonItem) {
        guard let url = videoURL else {
            return
        }
        
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityViewController.popoverPresentationController?.barButtonItem = sender
        present(activityViewController, animated: true)
    }
    
    // MARK: - Deinitializer
    
    deinit {
        player.pause()
    }
    
    
}
