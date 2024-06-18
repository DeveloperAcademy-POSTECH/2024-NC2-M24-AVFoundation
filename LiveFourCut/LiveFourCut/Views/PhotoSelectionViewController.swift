//
//  PhotoSelectionViewController.swift
//  LiveFourCut
//
//  Created by 윤동주 on 6/18/24.
//

import UIKit

class PhotoSelectionViewController: UIViewController {
    
    // MARK: - Properties

    /// 선택된 프레임의 Photo 개수
    var frameCount: Int?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // 뒤로가기 버튼 Action 추가
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    // MARK: - Functions

}
