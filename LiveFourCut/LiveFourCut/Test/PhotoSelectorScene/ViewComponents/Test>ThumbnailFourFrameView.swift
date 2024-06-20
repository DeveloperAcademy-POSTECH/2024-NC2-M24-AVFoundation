//
//  FrameView.swift
//  LiveFourCut
//
//  Created by Developer on 6/19/24.
//

import UIKit
import SnapKit
import Combine
extension Test.PhotoSelectorVC{
    final class ThumbnailFourFrameView:UIStackView{
        weak var vm: ThumbnailSelectorVM!{
            didSet{
                guard let vm else {return}
                vm.selectImageContainerSubject.sink {[weak self] containerList in
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
        private var imageViews:[FrameCardView] = (0..<4).map{FrameCardView(image: nil, number: $0 + 1)}
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
