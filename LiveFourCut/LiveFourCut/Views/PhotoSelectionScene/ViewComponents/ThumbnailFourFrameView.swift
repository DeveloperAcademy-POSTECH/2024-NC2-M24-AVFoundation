//
//  ThumbnailFourFrameView.swift
//  LiveFourCut
//
//  Created by Greem on 6/20/24.
//

import UIKit
import Combine

extension PhotoSelectionViewController {
    final class ThumbnailFourFrameView:UIStackView {
        weak var vm: ThumbnailSelectorVM! {
            didSet{
                guard let vm else { return }
                vm.selectImageContainerSubject.sink { [weak self] containerList in
                    containerList.enumerated().forEach { ele in
                        self?.imageViews[ele.offset].container = ele.element
                    }
                }.store(in: &cancellable)
                for cardView in imageViews{
                    cardView.action = { container in
                        vm.removeSelectImage(containerID: container.id)
                    }
                }
            }
        }
        var selector:[Bool] = Array(repeating: false, count: 4)
        private var imageViews:[ThumbnailCardView] = (0..<4).map{ThumbnailCardView(image: nil, number: $0 + 1)}
        //        .enumerated().reduce(into: [:]) { $0[$1.offset] = $1.element }
        private lazy var upperStack = {
            let subViews = [imageViews[0],imageViews[1]]
            let stView = UIStackView(arrangedSubviews: subViews)
            stView.axis = .horizontal
            stView.alignment = .fill
            stView.distribution = .fillEqually
            stView.spacing = 10
            return stView
        }()
        private lazy var lowerStack = {
            let subViews = [imageViews[2],imageViews[3]]
            let stView = UIStackView(arrangedSubviews: subViews)
            stView.axis = .horizontal
            stView.distribution = .fillEqually
            stView.alignment = .fill
            stView.spacing = 10
            return stView
        }()
        var cancellable = Set<AnyCancellable>()
        init(){
            super.init(frame: .zero)
            [upperStack,lowerStack].forEach{ item in
                self.addArrangedSubview(item)
            }
            self.axis = .vertical
            self.layer.cornerRadius = 20
            self.alignment = .fill
            self.distribution = .fill
            self.spacing = 10
            self.backgroundColor = .systemGray3
            self.isLayoutMarginsRelativeArrangement = true
            self.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            self.tag = 0
        }
        required init(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        func reset(){
            imageViews.forEach { item in
                item.container = nil
            }
        }
    }
}
extension PhotoSelectionViewController.ThumbnailFourFrameView {
    class ThumbnailCardView:CardView{
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
