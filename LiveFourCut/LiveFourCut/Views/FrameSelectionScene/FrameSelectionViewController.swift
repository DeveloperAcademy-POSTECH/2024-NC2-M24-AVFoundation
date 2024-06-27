//
//  FrameSelectionViewController.swift
//  LiveFourCut
//
//  Created by 윤동주 on 6/14/24.
//

import UIKit
import SnapKit

class FrameSelectionViewController: UIViewController {
    
    // MARK: - Properties
    
    /// 프레임 선택 title
    let frameLabel: UILabel = {
        var label = UILabel()
        
        label.text = "프레임 선택하소~"
        label.font = .systemFont(ofSize: 25, weight: .bold)
        
        return label
    }()
    
    /// 2 프레임 View
    var twoFrameStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.layer.cornerRadius = 20
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.backgroundColor = .systemGray3
        
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        stackView.isUserInteractionEnabled = true
        stackView.tag = 1
        
        return stackView
    }()
    
    /// 프레임 구분선
    let divider: UIView = {
        var view = UIView()
        
        view.backgroundColor = .black
        
        return view
    }()
    
    /// /// 4 프레임 View
    var fourFrameStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.layer.cornerRadius = 20
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        stackView.backgroundColor = .systemGray3
        
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        stackView.isUserInteractionEnabled = true
        stackView.tag = 2
        
        return stackView
    }()
    
    /// 4 프레임 상단 StackView
    var upperRowStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }()
    
    /// 4 프레임 하단  StackView
    var lowerRowStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        return stackView
    }()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.title = "프레임 선택"
        
        let twoFrameTapGesture = UITapGestureRecognizer(target: self, 
                                                        action: #selector(frameStackViewTapped(_:)))
        let fourFrameTapGesture = UITapGestureRecognizer(target: self, 
                                                         action: #selector(frameStackViewTapped(_:)))
        
        twoFrameStackView.addGestureRecognizer(twoFrameTapGesture)
        fourFrameStackView.addGestureRecognizer(fourFrameTapGesture)
        
        self.setupUI()
        self.setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Setup
    
    private func setupUI(){
        [frameLabel,
         twoFrameStackView,
         divider,
         fourFrameStackView].forEach { self.view.addSubview($0) }
        
        // 2 프레임 Card 추가
        for i in 0..<2 {
            let frameView = CardView(image: UIImage(named:i == 0 ? "Hanroro1" : "Hanroro2"),number: nil)
            twoFrameStackView.addArrangedSubview(frameView)
        }
        
        // 4 프레임 Card 추가
        [upperRowStackView, lowerRowStackView].forEach { fourFrameStackView.addArrangedSubview($0) }
        for i in 0..<2 {
            let upperFrameView = CardView(image: UIImage(named: i == 0 ? "Hanroro3" : "Hanroro4"), number: nil)
            let lowerFrameView = CardView(number: i+2)
            upperRowStackView.addArrangedSubview(upperFrameView)
            lowerRowStackView.addArrangedSubview(lowerFrameView)
        }
        
    }
    
    private func setupConstraints() {
        
        frameLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(38)
            $0.centerX.equalToSuperview()
        }
        
        twoFrameStackView.snp.makeConstraints {
            $0.top.equalTo(frameLabel.snp.bottom).offset(45)
            $0.height.equalTo(181)
            $0.leading.trailing.equalTo(self.view).inset(80)
            $0.centerX.equalToSuperview()
        }
        
        divider.snp.makeConstraints {
            $0.top.equalTo(twoFrameStackView.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(1)
            $0.width.equalTo(200)
        }
        fourFrameStackView.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(352)
            $0.leading.trailing.equalToSuperview().inset(80)
        }
    }
    
    // MARK: - Functions
    
    /// 프레임에 추가할 새로운 Frame 생성하는 함수
    
    
    /// 버튼 클릭 시 줄어드는 동작 함수
    /// Button으로 덮지 않고 animation 효과를 반영
    private func animateView(_ view: UIView, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.1, animations: {
            view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1) {
                view.transform = CGAffineTransform.identity
            } completion: { _ in
                completion()
            }
        })
    }
    
    /// 프레임이 선택되었을 시 동작 함수
    @objc private func frameStackViewTapped(_ sender: UITapGestureRecognizer) {
        guard let stackView = sender.view as? UIStackView else { return }
        var frameCount = 0
        if stackView.tag == 1 {
            frameCount = 2
            animateView(stackView) {
                print("2 Frame Stack View Tapped")
                let photoSelectionViewController = PhotoSelectionViewController()
                photoSelectionViewController.frameCount = frameCount
                self.navigationController?.pushViewController(photoSelectionViewController, animated: true)
            }
        } else if stackView.tag == 2 {
            frameCount = 4
            animateView(stackView) {
                print("4 Frame Stack View Tapped")
                let photoSelectionViewController = PhotoSelectionViewController()
                photoSelectionViewController.frameCount = frameCount
                self.navigationController?.pushViewController(photoSelectionViewController, animated: true)
            }
        }
    }
}

