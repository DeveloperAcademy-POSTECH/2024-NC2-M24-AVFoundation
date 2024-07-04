//
//  BaseVC.swift
//  LiveFourCut
//
//  Created by Greem on 6/19/24.
//

import Foundation
import UIKit
class BaseVC: UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
        configureConstraints()
        configureNavigation()
        configureView()
    }
    func configureLayout(){ }
    func configureConstraints(){ }
    func configureView(){ }
    func configureNavigation(){ }
}
