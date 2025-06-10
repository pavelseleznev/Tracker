//
//  SceneDelegate.swift
//  Tracker
//
//  Created by Pavel Seleznev on 3/23/25.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        let isFirstLaunch = !UserDefaultsService.shared.hasLaunchedBefore
        
        if isFirstLaunch {
            UserDefaultsService.shared.hasLaunchedBefore = true
            
            let onboardingViewController = OnboardingViewController(
                transitionStyle: .scroll,
                navigationOrientation: .horizontal,
                options: nil)
            window?.rootViewController = onboardingViewController
        } else {
            let tabBarController = TabBarController()
            window?.rootViewController = tabBarController
        }
        
        window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {}
    
    func sceneDidBecomeActive(_ scene: UIScene) {}
    
    func sceneWillResignActive(_ scene: UIScene) {}
    
    func sceneWillEnterForeground(_ scene: UIScene) {}
    
    func sceneDidEnterBackground(_ scene: UIScene) {}
}
