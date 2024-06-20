//
//  VideoMakerVC.swift
//  LiveFourCut
//
//  Created by Greem on 6/21/24.
//

import UIKit
import AVFoundation
import SnapKit
extension UIImage{
    static func getImageURL(url:URL) -> UIImage{
        let imageSourceOption = [kCGImageSourceShouldCache: false] as CFDictionary
        let imageResource = CGImageSourceCreateWithURL(url as CFURL, imageSourceOption)
        let downSampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
//            kCGImageSourceThumbnailMaxPixelSize: maxPixel
        ] as CFDictionary
        let image = CGImageSourceCreateThumbnailAtIndex(imageResource!, 0, downSampleOptions)
        return UIImage(cgImage: image!)
    }
}

extension Test{
    
    final class VideoMakerVC:UIViewController{
        let images:[UIImage] = (0..<24).map{_ in .hanroro1} + (0..<24).map{_ in .hanroro2} + (0..<24).map{_ in .hanroro4}
        let creator = VideoCreator()
        let videoView = VideoView()
        let playBtn = DoneBtn(title: "재생")
        
        override func viewDidLoad() {
            super.viewDidLoad()

            let night = FileManager.default.temporaryDirectory.appendingPathComponent("taste.jpeg")
            let payday = FileManager.default.temporaryDirectory.appendingPathComponent("payday.jpeg")
            let images = (0..<24).map{ _ in
                firstViewMaker().asImage()
            } + (0..<24).map{ _ in
//                UIImage.getImageURL(url: payday)
                secondViewMaker().asImage()
            }
            
            let outputURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp.mp4")
            if FileManager.default.fileExists(atPath: outputURL.path()){
                try? FileManager.default.removeItem(at: outputURL)
            }
            print(outputURL)
            creator.createVideo(from: images, outputURL: outputURL) { isSuccess, error in
                if isSuccess{
                    print("성공...")
                    let asset = AVAsset(url: outputURL)
                    self.videoView.item = AVPlayerItem(asset: asset)
                }else{
                    print("실패...")
                    print(error)
                }
            }
            view.addSubview(videoView)
            view.addSubview(playBtn)
            videoView.snp.makeConstraints { make in
                make.center.equalTo(view.safeAreaLayoutGuide)
                make.height.equalTo(view.snp.width).multipliedBy(1.3333)
                make.width.equalTo(300)
            }
            playBtn.snp.makeConstraints { make in
                make.bottom.equalTo(view.safeAreaLayoutGuide)
                make.height.equalTo(60)
                make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(24)
            }
            playBtn.action = {
                self.videoView.play()
            }
        }
        func firstViewMaker() -> UIView{
            let view = UIView(frame: .init(x: 0, y: 0, width: 300, height: 400))
            let payday = FileManager.default.temporaryDirectory.appendingPathComponent("payday.jpeg")
            let paydayImage = UIImage.getImageURL(url: payday)
//            let night = FileManager.default.temporaryDirectory.appendingPathComponent("taste.jpeg")
//            let nightImage = UIImage.getImageURL(url: night)
            let width = Double(paydayImage.cgImage!.width)
            let size: CGSize = .init(width: (width - 30) / 2, height: (width * 1.3333 - 30) / 2)
            let img = { paydayImage.cgImage!.cropping(to: .init(origin: .zero, size: .init(width: width, height: width * 1.3333))) }
            
            let paydayImageView1 = imageViewMaker(image: img()! , rect: .init(origin: .init(x: 10, y: 10), size: size))
            let paydayImageView2 = imageViewMaker(image: img()!
                                                  , rect: .init(origin: .init(x: size.width + 20, y: 10), size: size))
            let paydayImageView3 = imageViewMaker(image: img()!
                                                  , rect: .init(origin: .init(x: 10, y: size.height + 20), size: size))
            let paydayImageView4 = imageViewMaker(image: img()!
                                                  , rect: .init(origin: .init(x: size.width + 20, y: size.height + 20), size: size))
            
            view.addSubview(paydayImageView1)
            view.addSubview(paydayImageView2)
            view.addSubview(paydayImageView3)
            view.addSubview(paydayImageView4)
            view.layer.cornerRadius = 30
            view.clipsToBounds = true
            view.backgroundColor = .red
            
            
            return view
        }
        func imageViewMaker(image:CGImage,rect:CGRect) -> UIImageView{
            let imageView = UIImageView(frame: rect)
            let render = UIGraphicsImageRenderer(size: rect.size)
            let newImage = render.image { context in
                UIImage(cgImage:image).draw(in: CGRect(origin: .zero, size: rect.size))
            }
            imageView.image = newImage
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = 30
            imageView.bounds = .init(origin: .zero, size: rect.size)
            imageView.contentMode = .scaleAspectFill
            return imageView
        }
        func secondViewMaker() -> UIView{
            let view = UIView(frame: .init(x: 0, y: 0, width: 300, height: 400))
            let payday = FileManager.default.temporaryDirectory.appendingPathComponent("taste.jpeg")
            let paydayImage = UIImage.getImageURL(url: payday)
            let night = FileManager.default.temporaryDirectory.appendingPathComponent("payday.jpeg")
            let nightImage = UIImage.getImageURL(url: night)
            let paydayImageView = UIImageView(frame: .init(origin: .init(x: 0, y: 0), size: .init(width: 200, height: 200)))
            paydayImageView.image = paydayImage
            let nightImageView = UIImageView(frame: .init(x: 200, y: 0, width: 200, height: 200))
            nightImageView.image = nightImage
            paydayImageView.contentMode = .scaleToFill
            nightImageView.contentMode = .scaleToFill
            view.addSubview(paydayImageView)
            view.addSubview(nightImageView)
            view.backgroundColor = .gray
            return view
        }
    }
}
