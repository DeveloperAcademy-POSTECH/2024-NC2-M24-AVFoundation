//
//  CardView.swift
//  LiveFourCut
//
//  Created by 윤동주 on 6/18/24.
//

import UIKit
import SnapKit

class CardView: UIImageView {
    
    var thumbnail:UIImage?{
        didSet{
            guard let thumbnail else {
                numberLabel.isHidden = false
                self.image = nil
                return
            }
            self.image = thumbnail
            numberLabel.isHidden = true
        }
    }
    // MARK: - Properties

    lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        return label
    }()
    
    // MARK: - Initializer

    init(image: UIImage? = nil, number: Int?) {
        super.init(frame: .zero)
        self.setupView()
        self.image = image
        self.thumbnail = image
        if let number {
            self.numberLabel.text = "\(number)"
        }
        self.setupUI()
        self.setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setupView()
    }
    
    // MARK: - Setup
    
    private func setupUI(){
        self.addSubview(numberLabel)
    }
    
    private func setupConstraints() {
        self.snp.makeConstraints { make in
            make.height.equalTo(self.snp.width).multipliedBy(1.58)
        }
        numberLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
        
    // MARK: - Functions

    private func setupView() {
        self.backgroundColor = .systemGray
        self.layer.cornerRadius = 10
        self.contentMode = .scaleAspectFill // 이미지가 상하or좌우에 꽉 차도록 설정
        self.clipsToBounds = true // 벗어나는 범위는 자름
    }
}
