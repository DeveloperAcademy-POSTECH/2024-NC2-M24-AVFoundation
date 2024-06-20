//
//  SwipeBackHelper.swift
//  LiveFourCut
//
//  Created by Greem on 6/20/24.
//

import UIKit

//MARK: -- 네비게이션 swipe back 가능하게 만들기
extension UINavigationController: ObservableObject, UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.isHidden = true
        interactivePopGestureRecognizer?.delegate = self
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
