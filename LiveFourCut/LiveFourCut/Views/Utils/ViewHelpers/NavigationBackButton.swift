//
//  BackButton.swift
//  LiveFourCut
//
//  Created by Greem on 6/20/24.
//

import UIKit

final class NavigationBackButton:UIButton{
    var action:(()->())?
    init() {
        super.init(frame: .zero)
        var config = UIButton.Configuration.plain()
        let imageConfig = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 14, weight: .bold))
        config.image = UIImage(systemName: "chevron.backward", withConfiguration: imageConfig)
        
        config.baseForegroundColor = .white
        config.background.visualEffect = UIBlurEffect(style: .regular)
        config.background.backgroundColor = .black
        config.contentInsets = .init(top: 6, leading: 6, bottom: 6, trailing: 6)
        config.cornerStyle = .capsule
        self.configuration = config
        self.tintColor = .tintColor
        self.addTarget(self, action: #selector(Self.btnTapped(sender:)), for: .touchUpInside)
    }
    required init?(coder: NSCoder) {
        fatalError("Don't use storyboard")
    }
    @objc func btnTapped(sender: UIButton) {
        action?()
    }
}
