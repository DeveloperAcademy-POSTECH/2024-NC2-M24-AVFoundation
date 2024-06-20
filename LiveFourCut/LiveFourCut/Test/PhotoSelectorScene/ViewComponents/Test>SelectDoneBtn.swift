//
//  SelectDoneBtn.swift
//  LiveFourCut
//
//  Created by Greem on 6/19/24.
//

import UIKit
extension Test.PhotoSelectorVC{
    final class SelectDoneBtn: UIButton{
        var action: (()->())?
        init(){
            super.init(frame: .zero)
            self.addTarget(self, action: #selector(Self.doneTapped(sender:)), for: .touchUpInside)
            var config = UIButton.Configuration.filled()
            config.attributedTitle = .init("4컷 영상 미리보기", attributes: .init([.font: UIFont.systemFont(ofSize: 17, weight: .semibold)]))
            self.configuration = config
        }
        required init?(coder: NSCoder) {
            fatalError("Don't use storyboard")
        }
        @objc func doneTapped(sender: UIButton){
            self.action?()
        }
    }
}
