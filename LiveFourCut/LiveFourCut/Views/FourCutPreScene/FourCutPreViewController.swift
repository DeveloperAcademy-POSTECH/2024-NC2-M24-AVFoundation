//
//  FourCutPreviewController.swift
//  LiveFourCut
//
//  Created by Greem on 6/20/24.
//

import UIKit
import Combine
import CoreMedia

final class FourCutPreViewController: BaseVC{
    // MARK: -- Service 연결
    let extractService = ExtractService()
    let frameService = FrameGenerator()
    //MARK: -- View 저장 프로퍼티
    private let preFourFrameView = PreFourFrameView()
    private let navigationBackButton = NavigationBackButton()
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "공유하소~"
        label.font = .systemFont(ofSize: 25, weight: .bold)
        return label
    }()
    let shareBtn = DoneBtn(title: "4컷 영상 추출하러가기")
    let replayBtn = DescriptionBtn(title: "다시 재생하기")
    var minDuration: Float = 0{
        didSet{ 
            preFourFrameView.minDuration = minDuration
            extractService.minDuration = Double(minDuration)
        }
    }
    var avAssetContainers:[AVAssetContainer]!{
        didSet{ 
            preFourFrameView.containers = avAssetContainers
            extractService.avAssetContainers = avAssetContainers
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
            self.preFourFrameView.play()
        })
        
    }
    override func configureLayout() {
        [titleLabel,preFourFrameView,shareBtn,replayBtn].forEach({ view.addSubview($0) })
    }
    override func configureConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(42)
            make.centerX.equalToSuperview()
        }
        preFourFrameView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        shareBtn.snp.makeConstraints { make in
            make.height.equalTo(50)
            make.horizontalEdges.equalToSuperview().inset(24)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(60)
        }
        replayBtn.snp.makeConstraints { make in
            make.top.equalTo(shareBtn.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
    }
    override func configureNavigation() {
        self.view.addSubview(navigationBackButton)
        navigationBackButton.snp.makeConstraints { make in
            make.leading.equalTo(self.view).inset(16.5)
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(4)
        }
        navigationBackButton.action = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    override func configureView() {
        self.view.backgroundColor = .systemBackground
//        let extractionVC = ExtractionViewController()
//        extractionVC.avAssetContainers = self.avAssetContainers
//        print(extractionVC.avAssetContainers?.count)
//        extractionVC.minDuration = self.minDuration
//        extractionVC.isLaunch = false
        
        shareBtn.action = {[weak self] in
            guard let self else { return }
            self.view.isUserInteractionEnabled = false
            Task{[weak self] in
                guard let self else { return }
                let interactionEnabled = { Task{@MainActor in self.view.isUserInteractionEnabled = true } }
                self.extractService.minDuration = Double(self.minDuration)
                print("minDuration \(self.minDuration)")
                do{
                    var frameImages = try await self.extractService.extractFrameImages()
                    var imgDatas:[CGImage] = try await self.frameService.groupReduce(groupImage: frameImages, spacing: 10)
                    print("추출은 된다. \(frameImages.first?.count)")
                    print("감소는 된다. \(imgDatas.count)")
                    frameImages = [] // 함수 사용 후 스택에서 제거해야한다.
                    let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("LiveFourCut.mp4")
                    if FileManager.default.fileExists(atPath: outputURL.path()){
                        try? FileManager.default.removeItem(at: outputURL)
                    }
                    let videoCreator = VideoCreator(videoSize: self.frameService.frameTargetSize, outputURL: outputURL)
                    videoCreator.createVideo(from: &imgDatas) { success, error in
                        if success{
                            DispatchQueue.main.async {
                                let sharingViewController = SharingViewController()
                                sharingViewController.videoURL = outputURL
                                self.navigationController?.isNavigationBarHidden = true
                                self.navigationController?.pushViewController(sharingViewController, animated: true)
                                _ = interactionEnabled()
                            }
                        }else{
                            _ = interactionEnabled()
                        }
                    }
                }catch{
                    _ = interactionEnabled()
                }
            }
//            self.navigationController?.pushViewController(extractionVC, animated: true)
        }
        replayBtn.action = {
            self.preFourFrameView.play()
        }
        replayBtn.isHidden = true
    }
    
}
