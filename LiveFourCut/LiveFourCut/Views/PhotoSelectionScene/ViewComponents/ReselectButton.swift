//
//  ReselectButton.swift
//  LiveFourCut
//
//  Created by Greem on 6/20/24.
//

import UIKit
final class DescriptionBtn: UIButton{
    var action:(()->())?
    init(title:String){
        super.init(frame: .zero)
        var config = UIButton.Configuration.plain()
        config.attributedTitle = .init(title, attributes: .init([.font: UIFont.systemFont(ofSize: 15, weight: .medium),
                                                                        .underlineStyle: NSUnderlineStyle.single.rawValue]))
        self.configuration = config
        self.addTarget(self, action: #selector(Self.reselectPickerTapped(sender:)), for: .touchUpInside)
    }
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
    @objc func reselectPickerTapped(sender: UIButton){
        action?()
    }
}
extension PhotoSelectionViewController{
    final class ReSelectPhotoBtn: UIButton{
        var action:(()->())?
        init(){
            super.init(frame: .zero)
            var config = UIButton.Configuration.plain()
            config.attributedTitle = .init("사진 재선택", attributes: .init([.font: UIFont.systemFont(ofSize: 15, weight: .medium),
                                                                            .underlineStyle: NSUnderlineStyle.single.rawValue]))
            self.configuration = config
            self.addTarget(self, action: #selector(Self.reselectPickerTapped(sender:)), for: .touchUpInside)
        }
        required init?(coder: NSCoder) {
            fatalError("Don't use storyboard")
        }
        @objc func reselectPickerTapped(sender: UIButton){
            action?()
        }
    }
}
