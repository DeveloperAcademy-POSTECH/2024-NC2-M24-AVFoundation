//
//  ExtractionViewController.swift
//  LiveFourCut
//
//  Created by 윤동주 on 6/20/24.
//

import UIKit
import AVFoundation
import SnapKit

class ExtractionViewController: UIViewController {
    
    // MARK: - Properties
    
    var avAssetContainers: [AVAssetContainer]?
    var minDuration: Float? = 0.47
    
    var extractedUIImages: [UIImage] = []
    
    lazy var assets: [AVAsset]? = avAssetContainers?.compactMap { container in
        if let url = URL(string: container.originalAssetURL) {
            return AVAsset(url: url)
        } else {
            return nil
        }
    }
    
    var recordedView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        return view
    }()
    
    var imageView1: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .gray
        return view
    }()
    var imageView2: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .gray
        return view
    }()
    var imageView3: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .gray
        return view
    }()
    var imageView4: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .gray
        return view
    }()
    
    var images: [UIImage] = []
    
    let extractionButton: UIButton = {
        let button = UIButton(type: .system)
        
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .systemBlue
        configuration.title = "추출 버튼"
        button.configuration = configuration
        
        return button
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        setupUI()
        setupConstraints()
        
    }
    // MARK: - Setup
    
    private func setupUI(){
        [recordedView, overlayView].forEach {
            self.view.addSubview($0)
        }
        [imageView1, imageView2, imageView3, imageView4].forEach {
            self.recordedView.addSubview($0)
        }
        self.overlayView.addSubview(extractionButton)
        extractionButton.addTarget(self, action: #selector(extract), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        
        recordedView.snp.makeConstraints {
            $0.width.equalTo(300)
            $0.height.equalTo(400)
            $0.centerX.equalTo(self.view.snp.centerX)
            $0.centerY.equalTo(self.view.snp.centerY)
        }
        
        imageView1.snp.makeConstraints {
            $0.width.equalTo(120)
            $0.height.equalTo(160)
            $0.top.equalTo(self.recordedView.snp.top).inset(10)
            $0.leading.equalTo(self.recordedView.snp.leading).inset(10)
        }
        
        imageView2.snp.makeConstraints {
            $0.width.equalTo(120)
            $0.height.equalTo(160)
            $0.top.equalTo(self.recordedView.snp.top).inset(10)
            $0.trailing.equalTo(self.recordedView.snp.trailing).inset(10)
        }
        
        imageView3.snp.makeConstraints {
            $0.width.equalTo(120)
            $0.height.equalTo(160)
            $0.bottom.equalTo(self.recordedView.snp.bottom).inset(10)
            $0.leading.equalTo(self.recordedView.snp.leading).inset(10)
        }
        
        imageView4.snp.makeConstraints {
            $0.width.equalTo(120)
            $0.height.equalTo(160)
            $0.bottom.equalTo(self.recordedView.snp.bottom).inset(10)
            $0.trailing.equalTo(self.recordedView.snp.trailing).inset(10)
        }
        
        overlayView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        extractionButton.snp.makeConstraints {
            $0.height.equalTo(50)
            $0.width.equalTo(100)
            $0.centerX.equalTo(self.view.snp.centerX)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-20)
        }
    }
    
    // MARK: - Functions
    
    @objc func extract() {
        guard let avAssetContainers else { return }
        guard let assets else { return }
        
        avAssetContainers.forEach {
            for i in 0..<Int($0.minDuration * 10) {
                images.append(getFrameImage(asset: assets[$0.idx], seconds: Double(i))!)
            }
        }
        for i in 0..<Int(self.minDuration! * 10) {
            self.imageView1.image = images[i]
            self.imageView2.image = images[4+i]
            self.imageView3.image = images[8+i]
            self.imageView4.image = images[12+i]
            self.extractedUIImages.append(self.recordedView.asImage())
        }
        let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp.mp4")
                   if FileManager.default.fileExists(atPath: outputURL.path()){
                       try? FileManager.default.removeItem(at: outputURL)
                   }
        VideoCreator().createVideo(from: extractedUIImages, outputURL: outputURL) { success, _ in 
            if success {
                Task{
                    @MainActor in
                    let sharingViewController = SharingViewController()
                    sharingViewController.videoURL = outputURL
                    self.navigationController?.isNavigationBarHidden = false
                    self.navigationController?.pushViewController(sharingViewController, animated: true)
                }
            }
        }
        
    }
    
    private func getFrameImage(asset: AVAsset, seconds: Double) -> UIImage? {
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        
        let timestamp = CMTime(seconds: seconds, preferredTimescale: 10)
        do {
            let imageRef = try generator.copyCGImage(at: timestamp, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch let error as NSError
        {
            print("이미지 생성에 실패했습니다: \(error)")
            return nil
        }
    }
}
