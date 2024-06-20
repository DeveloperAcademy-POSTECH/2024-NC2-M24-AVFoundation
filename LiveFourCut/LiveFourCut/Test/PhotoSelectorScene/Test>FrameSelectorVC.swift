//
//  Test>FrameSelectorVC.swift
//  LiveFourCut
//
//  Created by Greem on 6/19/24.
//
//MARK: -- 임시로 프레임 선택하는 뷰 컨트롤러
import UIKit
import Combine
import Photos
import PhotosUI
extension Test{
    final class FrameSelectorVC: BaseVC{
        let btn = UIButton(frame: .zero)
        override func viewDidLoad() {
            super.viewDidLoad()
        }
        override func configureLayout() {
            view.addSubview(btn)
            btn.translatesAutoresizingMaskIntoConstraints = false
        }
        override func configureConstraints() {
            NSLayoutConstraint.activate([
                btn.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                btn.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                btn.widthAnchor.constraint(equalToConstant: 120),
                btn.heightAnchor.constraint(equalToConstant: 44)
            ])
        }
        override func configureView() {
            self.view.backgroundColor = .systemBackground
            btn.setTitle("앨범 열기", for: .normal)
            btn.setTitleColor(.tintColor, for: .normal)
            btn.addAction(.init(handler: { [weak self] _ in
                let vc = PhotoSelectorVC()
                vc.limitedNumber = 4
                self?.navigationController?.pushViewController(vc, animated: true)
            }), for: .touchUpInside)
        }
        override func configureNavigation() {
            navigationItem.title = "앨범 선택 테스트 뷰"
        }
    }
}
