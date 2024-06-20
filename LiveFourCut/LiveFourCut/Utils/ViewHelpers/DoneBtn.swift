//
//  DoneBtn.swift
//  LiveFourCut
//
//  Created by Greem on 6/20/24.
//

import UIKit

final class DoneBtn: UIButton{
    var action: (()->())?
    init(title:String){
        super.init(frame: .zero)
        self.addTarget(self, action: #selector(Self.doneTapped(sender:)), for: .touchUpInside)
        var config = UIButton.Configuration.filled()
        config.attributedTitle = .init(title, attributes: .init([.font: UIFont.systemFont(ofSize: 17, weight: .semibold)]))
        self.configuration = config
    }
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
    @objc func doneTapped(sender: UIButton){
        self.action?()
    }
}
