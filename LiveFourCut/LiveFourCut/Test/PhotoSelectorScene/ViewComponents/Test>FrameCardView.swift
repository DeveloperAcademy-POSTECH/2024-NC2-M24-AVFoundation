//
//  FrameCardView.swift
//  LiveFourCut
//
//  Created by Greem on 6/19/24.
//

import UIKit
import SnapKit
extension Test.PhotoSelectorVC.ThumbnailFourFrameView{
    class FrameCardView:CardView{
        private let cancelButton: UIButton = .init()
        override var thumbnail: UIImage?{
            didSet{
                guard let thumbnail else {
                    self.image = nil
                    self.cancelButton.isHidden = true
                    self.numberLabel.isHidden = false
                    return
                }
                self.image = thumbnail
                self.cancelButton.isHidden = false
                self.numberLabel.isHidden = true
            }
        }
        var container:ImageContainer?{
            didSet{
                guard let container else {
                    self.thumbnail = nil
                    return
                }
                self.thumbnail = container.image
            }
        }
        var action:((ImageContainer)->())?
        override init(image: UIImage? = nil, number: Int?) {
            super.init(image: image, number: number)
            var config = UIButton.Configuration.plain()
            let imageConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 12, weight: .bold))
            config.image = UIImage(systemName: "xmark", withConfiguration: imageConfig)
            config.baseForegroundColor = .white
            config.background.visualEffect = UIBlurEffect(style: .regular)
            config.contentInsets = .init(top: 6, leading: 6, bottom: 6, trailing: 6)
            config.cornerStyle = .capsule
            cancelButton.configuration = config
            self.addSubview(cancelButton)
            self.isUserInteractionEnabled = true
            cancelButton.addTarget(self, action: #selector(Self.cancelBtnTapped(sender:)), for: .touchUpInside)
            cancelButton.snp.makeConstraints { make in
                make.top.trailing.equalToSuperview().inset(4)
            }
        }
        @objc func cancelBtnTapped(sender: UIButton){
            guard let container else {return}
            action?(container)
        }
        required init?(coder: NSCoder) {
            fatalError("Don't use storyboard")
        }
    }
}
