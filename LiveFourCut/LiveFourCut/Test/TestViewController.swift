//
//  TestViewController.swift
//  LiveFourCut
//
//  Created by Developer on 6/17/24.
//

import UIKit
import Photos
import PhotosUI
import AVFoundation
import PinLayout
enum Test{
    static let main:UIViewController = FetchEditController()
}
extension Test{
    final class InputLivePhotoToSimulator: UIViewController{
        let names = ["IMG_2136","IMG_1965","IMG_1177"]
        override func viewDidLoad() {
            super.viewDidLoad()
            PHPhotoLibrary.shared().performChanges({
                for name in self.names{
                    let request = PHAssetCreationRequest.forAsset()
                    request.addResource(with: .photo, fileURL: URL(string: "/Users/kimtaeyoon/Downloads/\(name).HEIC")!, options: nil)
                    request.addResource(with: .pairedVideo, fileURL: URL(string: "/Users/kimtaeyoon/Downloads/\(name).mov")!, options: nil)
                }
            }) { (success, error) in
                
                print(success)
                print(error?.localizedDescription ?? "error")
            }
            
        }
    }
}

extension Test{
    final class FetchEditController:UIViewController{
        let btn = UIButton(frame: .zero)
        let playBtn = UIButton(frame: .zero)
        let videoView1 = VideoView()
        let videoView2 = VideoView()
        let videoView3 = VideoView()
        let videoView4 = VideoView()
        private var originURLAssets:[(String,AVURLAsset)] = []
        // 여기 커스텀 Serial Actor를 통해서 Tread-Safe하게 접근할 필요가 있음
        private var assetCounter:Int = -1{
            didSet{
                guard assetCounter == 0 else {return}
                assetCounter = -1
                adaptNewMedias()
            }
        }
        var minDuration:Float = 1000
        override func viewDidLoad() {
            super.viewDidLoad()
            configureLayout()
            configureView()
            playBtn.addTarget(self, action: #selector(Self.playTriggerTapped(sender:)), for: .touchUpInside)
            btn.addTarget(self, action: #selector(Self.pickerTriggerTapped(sender:)), for: .touchUpInside)
        }
        func configureLayout(){
            [btn,playBtn,videoView1,videoView2,videoView3,videoView4].forEach({
                view.addSubview($0)
                $0.translatesAutoresizingMaskIntoConstraints = false
            })
            NSLayoutConstraint.activate([
                btn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                btn.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 16),
                btn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                btn.heightAnchor.constraint(equalToConstant: 52),
                playBtn.bottomAnchor.constraint(equalTo: btn.topAnchor, constant: -8),
                playBtn.leadingAnchor.constraint(equalTo: btn.leadingAnchor),
                playBtn.trailingAnchor.constraint(equalTo: btn.trailingAnchor),
                videoView1.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                videoView1.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                videoView2.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                videoView2.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                videoView3.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                videoView4.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                videoView3.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                videoView4.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor)
            ])
            [videoView1,videoView2,videoView3,videoView4].forEach{
                $0.widthAnchor.constraint(equalToConstant: 150).isActive = true
                $0.heightAnchor.constraint(equalToConstant: 150).isActive = true
                $0.tintColor = .gray
            }
        }
        func configureView(){
            btn.setTitle("앨범 선택", for: .normal)
            btn.configuration = UIButton.Configuration.filled()
            playBtn.setTitle("영상 재생", for: .normal)
            playBtn.configuration = UIButton.Configuration.bordered()
        }
        @objc func pickerTriggerTapped(sender:UIButton){
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in }
            var config = PHPickerConfiguration(photoLibrary: .shared())
            config.filter = .livePhotos
            config.selectionLimit = 4
            let phVC = PHPickerViewController(configuration: config)
            phVC.delegate = self
            self.present(phVC , animated: true)
        }
        @objc func playTriggerTapped(sender: UIButton){
            [videoView1,videoView2,videoView3,videoView4].forEach { $0.play() }
        }
    }
}
extension PHAsset{
    // AVURLAsset은 AVAsset의 자식 클래스... url 값을 얻을 수 있어서 AVURLAsset 타입으로 반환
    func convertToAVURLAsset() async throws -> AVURLAsset{
        return try await withCheckedThrowingContinuation {[weak self] continuation in
            guard let self else {fatalError("이게 왜 사라져...")}
            requestContentEditingInput(with: nil) { input, info in
                guard let input,let imageURL = input.fullSizeImageURL else {return}
                let videoURLString = imageURL.absoluteString.replacingOccurrences(of: ".HEIC", with: ".MOV")
                let fileName = String((imageURL.absoluteString.split(separator: "/").last?.split(separator: ".").first ?? ""))
                guard let videoURL = URL(string: videoURLString) else {fatalError("변환 실패")}
                let urlAsset = AVURLAsset(url: videoURL)
                continuation.resume(returning: urlAsset)
            }
        }
    }
}
extension Test.FetchEditController: PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let identifiers = results.map(\.assetIdentifier).map{$0!}
        let assets:PHFetchResult<PHAsset> = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
        assetCounter = assets.count
        // 이 메서드는 이미 Concurrent하게 동작함... TaskGroup 작업 할 필요 없음
        assets.enumerateObjects(options: .concurrent) { asset, idx, pointer in
            let convertedIdentifier = asset.localIdentifier.replacingOccurrences(of: "/", with: "_")
            Task{
                do{
                    let urlAsset:AVURLAsset = try await asset.convertToAVURLAsset()
                    let value:Float = (try? await Float(urlAsset.load(.duration).value)) ?? 0
                    let timeScale: Float = (try? await Float(urlAsset.load(.duration).timescale)) ?? 1
                    let secondsLength = value / timeScale
                    self.minDuration = min(secondsLength,self.minDuration)
                    self.originURLAssets.append((convertedIdentifier,urlAsset))
                }catch{
                    print("picker Error",error)
                }
                self.assetCounter -= 1
            }
        }
        self.dismiss(animated: true)
    }
    func adaptNewMedias(){
        Task{
            var assets:[AVAsset] = []
            for v in self.originURLAssets{
                assets.append(try await adaptNewMdeia(asset: v.1, identifier: v.0))
            }
            if assets.count == 4{
                let videoViews = [videoView1,videoView2,videoView3,videoView4]
                for (asset,videoView) in zip(assets,videoViews){
                    videoView.item = AVPlayerItem(asset: asset)
                }
            }
        }
    }
}
extension Test.FetchEditController{
    func adaptNewMdeia(asset:AVAsset,identifier:String) async throws -> AVAsset{
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            fatalError("AVAsset 방출 타입으로 전환 실패")
        }
        exportSession.outputFileType = .mov
        let tempDirectory = FileManager.default.temporaryDirectory
        let newFileURL = tempDirectory.appendingPathComponent("\(identifier).MOV")
        exportSession.outputURL = newFileURL
        print("exportSession URL\n \(newFileURL)")
        let value:Float = (try? await Float(asset.load(.duration).value)) ?? 0
        let timeScale: Float = (try? await Float(asset.load(.duration).timescale)) ?? 1
        let secondsLength = value / timeScale
        let startTime = CMTime(seconds: Double(0), preferredTimescale: 1000)
        let endTime = CMTime(seconds: Double(self.minDuration), preferredTimescale: 1000)
        let timeRange = CMTimeRange(start: startTime, end: endTime)
        exportSession.timeRange = timeRange
        await exportSession.export()
        let newAsset = AVAsset(url: newFileURL)
        return newAsset
    }
}
