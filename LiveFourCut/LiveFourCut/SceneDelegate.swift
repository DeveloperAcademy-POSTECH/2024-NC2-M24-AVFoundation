//
//  SceneDelegate.swift
//  LiveFourCut
//
//  Created by 윤동주 on 6/14/24.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        self.window?.rootViewController = UINavigationController(rootViewController: FrameSelectionViewController())
//        Test.main
//        UINavigationController(rootViewController: FrameSelectionViewController())
        
//        UINavigationController(rootViewController: FrameSelectionViewController())
//        self.window?.rootViewController = UINavigationController(rootViewController: SharingViewController())
        self.window?.makeKeyAndVisible()
    }

}

