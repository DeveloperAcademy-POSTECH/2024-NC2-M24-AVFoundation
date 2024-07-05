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
    
    let backButton = NavigationBackButton()
    lazy var assets: [AVAsset]? = avAssetContainers?.compactMap { container in
        if let url = URL(string: container.originalAssetURL) {
            return AVAsset(url: url)
        } else {
            return nil
        }
    }
    
    var recordedView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray
        view.layer.cornerRadius = 20
        return view
    }()
    
    var overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    var extractionLabel: UILabel = {
        let label = UILabel()
        
        label.text = "추출 하소~"
        label.tintColor = .black
        label.font = .systemFont(ofSize: 25, weight: .bold)
        
        return label
    }()
    
    var imageView1: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .gray
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    var imageView2: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .gray
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    var imageView3: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .gray
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    var imageView4: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .gray
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    var images: [[UIImage?]] = [[],[],[],[]]
    var isLaunch = false
    let extractionButton: UIButton = {
        let button = UIButton(type: .system)
        
        var configuration = UIButton.Configuration.filled()
        configuration.baseBackgroundColor = .systemBlue
        configuration.title = "추출 버튼"
        button.configuration = configuration
        return button
    }()
    
    let progress = UIProgressView(progressViewStyle: .bar)
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        setupUI()
        setupConstraints()
        
    }
    // MARK: - Setup
    
    private func setupUI(){
        [recordedView, overlayView,backButton].forEach {
            self.view.addSubview($0)
        }
        [imageView1, imageView2, imageView3, imageView4].forEach {
            self.recordedView.addSubview($0)
        }
        [extractionLabel, extractionButton].forEach {
            self.overlayView.addSubview($0)
        }
        extractionButton.addTarget(self, action: #selector(extract), for: .touchUpInside)
    }
    
    private func setupConstraints() {
        
        extractionLabel.snp.makeConstraints {
            $0.centerX.equalTo(self.overlayView.snp.centerX)
            $0.centerY.equalTo(self.overlayView.snp.centerY)
        }
        
        recordedView.snp.makeConstraints {
            $0.width.equalTo(300)
            $0.height.equalTo(390)
            $0.centerX.equalTo(self.view.snp.centerX)
            $0.centerY.equalTo(self.view.snp.centerY)
        }
        
        imageView1.snp.makeConstraints {
            $0.width.equalTo(135)
            $0.height.equalTo(180)
            $0.top.equalTo(self.recordedView.snp.top).inset(10)
            $0.leading.equalTo(self.recordedView.snp.leading).inset(10)
        }
        
        imageView2.snp.makeConstraints {
            $0.width.equalTo(135)
            $0.height.equalTo(180)
            $0.top.equalTo(self.recordedView.snp.top).inset(10)
            $0.trailing.equalTo(self.recordedView.snp.trailing).inset(10)
        }
        
        imageView3.snp.makeConstraints {
            $0.width.equalTo(135)
            $0.height.equalTo(180)
            $0.bottom.equalTo(self.recordedView.snp.bottom).inset(10)
            $0.leading.equalTo(self.recordedView.snp.leading).inset(10)
        }
        
        imageView4.snp.makeConstraints {
            $0.width.equalTo(135)
            $0.height.equalTo(180)
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
        backButton.snp.makeConstraints { make in
            make.leading.equalTo(self.view).inset(16.5)
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(4)
        }
        backButton.action = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    // MARK: - Functions
    
    @objc func extract() {
        guard let avAssetContainers else { return }
        guard let assets else { return }
        Task{
            for v in avAssetContainers{
                let asset = assets[v.idx]
                self.images[v.idx] = Array(repeating: nil, count: Int(v.minDuration * 24) + 1)
                let generator = AVAssetImageGenerator(asset: asset)
                generator.appliesPreferredTrackTransform = true
                generator.requestedTimeToleranceBefore = .init(seconds: Double(1 / 48), preferredTimescale: 600)
                generator.requestedTimeToleranceAfter = .init(seconds: Double(1 / 48), preferredTimescale: 600)
                for idx in (0..<Int(v.minDuration * 24)){
                    let time = CMTime(seconds: Double(idx) / 24, preferredTimescale: 600)
                    let (img,actualTime) = try await generator.image(at: time)
                    self.images[v.idx][idx] = UIImage(cgImage: img)
                }
            }
            await MainActor.run {
                print("계수",images.count)
                for i in 0..<Int(self.minDuration! * 24) {
                    [imageView1,imageView2,imageView3,imageView4].enumerated().forEach { idx,view in
                        if let img = images[idx][i]{ view.image = img }
                    }
                    self.extractedUIImages.append(self.recordedView.asImage())
                }
                let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("LiveFourCut.mp4")
                if FileManager.default.fileExists(atPath: outputURL.path()){
                    try? FileManager.default.removeItem(at: outputURL)
                }
                VideoCreator.createVideo(from: extractedUIImages, outputURL: outputURL) { success, _ in
                    if success {
                        Task{ @MainActor in
                            let sharingViewController = SharingViewController()
                            sharingViewController.videoURL = outputURL
                            self.navigationController?.isNavigationBarHidden = true
                            self.navigationController?.pushViewController(sharingViewController, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    private func getFrameImage(asset: AVAsset, seconds: Double) async -> UIImage? {
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        print("받는 초",seconds)
        let timestamp = CMTime(seconds: seconds, preferredTimescale: 600)
        do {
            let imgs = generator.images(for: [timestamp])
            let (image,actualTime) = try await generator.image(at: timestamp)
            return UIImage(cgImage: image)
        } catch let error as NSError
        {
            print("이미지 생성에 실패했습니다: \(error)")
            return nil
        }
    }
    private func testForImageLists() async {
        //                Task{[images = images] in
        //                    images.enumerated().forEach{ (offset, items) in
        //                        for (idx,item) in items.enumerated(){
        //                            guard let item else {return}
        //                            let imgURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(offset)_\(idx)_item.jpeg", conformingTo: .jpeg)
        //                            FileManager.default.createFile(atPath: imgURL.path(), contents: item.jpegData(compressionQuality: 0.5))
        //                        }
        //                    }
        //                }
    }
}
