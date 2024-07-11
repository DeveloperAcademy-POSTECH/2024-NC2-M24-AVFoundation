//
//  VideoFrameDiverScene.swift
//  LiveFourCut
//
//  Created by Greem on 6/27/24.
//

import UIKit
class Wow:UIViewController{
    let imageView = UIImageView(frame: .init(x: 20, y: 100, width: 300, height: 400))
    override func viewDidLoad() {
        super.viewDidLoad()
        goConcurrent()
        view.addSubview(imageView)
    }
    func goConcurrent(){
        let queue = DispatchQueue(label: "queue1",qos: .userInteractive,attributes: .concurrent)
        let group = DispatchGroup()
        let startTime = DispatchTime.now()
        for i in 0..<10{
            DispatchQueue.global().async(group:group) {
                for j in 0..<24{
                    self.maker(idx: i * 10 + j)
                }
            }
        }
        group.notify(queue: queue) {
            let endTime = DispatchTime.now()
            let elapsedTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
            let elapsedTimeInMilliseconds = Double(elapsedTime) / 1_000_000
            print("CGImageConcurrentTime",elapsedTimeInMilliseconds)
        }
    }
    func maker(idx:Int){
        let (width,height):(CGFloat,CGFloat) = (300,400)
        let targetRatio:CGFloat = height / width
        let spacing:CGFloat = 20
        let images = ["rabbits","rabbit","lemon","demo"].map { (name:String) in
            let img = UIImage(named: name)!.flipImageHorizontal()!
            let (height,width) = (CGFloat(img.height),CGFloat(img.width))
            let centerCropSize = CGRect.cropFromCenter(width: width, height: height, ratio: targetRatio)
            return img.cropping(to: centerCropSize)!.makeRoundedCorner()!
        }
        let nW = 0.5 * width - 1.5 * spacing
        let nH = 0.5 * width * targetRatio - 1.5 * spacing
        let ltRect = CGRect.init(x: spacing, y: spacing, width: nW, height: nH)
        let rtRect = CGRect.init(x: nW + 2 * spacing, y: spacing, width: nW, height: nH)
        let ldRect = CGRect.init(x: spacing, y: nH + 2 * spacing, width: nW, height: nH)
        let rdRect = CGRect.init(x: nW + 2 * spacing, y: nH + 2 * spacing, width: nW, height: nH)
        let render = UIGraphicsImageRenderer(size: .init(width: width, height: height))
        let data = render.pngData { context in
            context.cgContext.setFillColor(UIColor.blue.cgColor)
            context.cgContext.beginPath()
            let roundedPath2 = CGPath.init(roundedRect: .init(x: 0, y: 0, width: 300, height: 400), cornerWidth: 40, cornerHeight: 40, transform: nil)
            context.cgContext.addPath(roundedPath2)
            context.cgContext.closePath()
            context.cgContext.fillPath()
            zip(images,[ltRect,rtRect,ldRect,rdRect]).forEach { image,rect in
                context.cgContext.draw(image, in: rect, byTiling: false)
            }
        }
        if idx == 0{
            DispatchQueue.main.async{
                let image = UIImage(data: data)
                self.imageView.image = image
            }
        }
    }
}
extension CGImage{
    func makeRoundedCorner(radius:CGFloat = 0) -> CGImage?{
        var cgImage = self
        let width = cgImage.width
        let height = cgImage.height
        let bitsPerComponent = cgImage.bitsPerComponent
        let bytesPerRow = cgImage.bytesPerRow
        let colorSpace = cgImage.colorSpace
        
        let bitmapInfo = cgImage.bitmapInfo
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace!,
                                      bitmapInfo: bitmapInfo.rawValue) else { return nil }
        context.setFillColor(UIColor.clear.cgColor)
        context.setAlpha(1)
        context.fill([.init(x: 0, y: 0, width: width, height: height)])
        context.beginPath()
        let roundedPath2 = CGPath.init(roundedRect: .init(x: 0, y: 0, width: width, height: height), cornerWidth: radius , cornerHeight: radius, transform: nil)
        context.addPath(roundedPath2)
        context.closePath()
        context.clip()
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        
        guard let roundedCGImage = context.makeImage() else { return nil }
        return roundedCGImage
    }
}
extension UIImage{
    func flipImageHorizontal() -> CGImage? {
        let image = self
        guard let cgImage = image.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        let bitsPerComponent = cgImage.bitsPerComponent
        let bytesPerRow = cgImage.bytesPerRow
        let colorSpace = cgImage.colorSpace
        let bitmapInfo = cgImage.bitmapInfo
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace!,
                                      bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        context.translateBy(x: 0, y: CGFloat(height))
        context.scaleBy(x: 1.0, y: -1.0)
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        guard let flippedCGImage = context.makeImage() else { return nil }
        return flippedCGImage
    }
    
}
extension CGRect{
    static func cropFromCenter(width:CGFloat,height:CGFloat,ratio targetRatio:CGFloat = 1) -> Self{
        var yOffset:CGFloat = 0
        var xOffset:CGFloat = 0
        var height:CGFloat = height
        var width:CGFloat = width
        if width < height{
            yOffset = (height - width * targetRatio)  * 0.5
            height = width * targetRatio
        }else{
            xOffset = (width - height * targetRatio) * 0.5
            width = height * targetRatio
        }
        let cropSize = CGRect(x: xOffset, y: yOffset, width: width, height: height)
        return cropSize
    }
}
