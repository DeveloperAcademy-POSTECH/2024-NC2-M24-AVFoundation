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
import Combine
enum Test{
    static let main:UIViewController = FetchEditController()
}
extension Test{
    final class InputLivePhotoToSimulator: UIViewController{
        let names = ["IMG_2380","IMG_2382","IMG_2383","IMG_2384"]
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
        var minDuration:Float = 1000
        let service = LPtoAVService()
        var cancellable = Set<AnyCancellable>()
        override func viewDidLoad() {
            super.viewDidLoad()
            configureLayout()
            configureView()
            playBtn.addTarget(self, action: #selector(Self.playTriggerTapped(sender:)), for: .touchUpInside)
            btn.addTarget(self, action: #selector(Self.pickerTriggerTapped(sender:)), for: .touchUpInside)
            Task{
                service.wow.receive(on: RunLoop.main).sink{[weak self] assets in
                    guard let self else {return}
                    if assets.count == 4{
                        print("새로운 Asset 할당하기")
                        let videoViews = [videoView1,videoView2,videoView3,videoView4]
                        zip(assets,videoViews).forEach{ $1.item = AVPlayerItem(asset: $0) }
                    }
                }.store(in: &self.cancellable)
            }
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
            Task{
                for v in [videoView1,videoView2,videoView3,videoView4]{
                    Task.detached { await v.play() }
                }
            }
        }
    }
}
extension Test.FetchEditController: PHPickerViewControllerDelegate{
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        let identifiers = results.map(\.assetIdentifier).map{$0!}
        let assets:PHFetchResult<PHAsset> = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: nil)
        Task{
            await service.pickerResultAppender(assets: assets)
        }
        self.dismiss(animated: true)
    }
    
}

