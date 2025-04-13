//
//  TabBarController.swift
//  Tracker
//
//  Created by Pavel Seleznev on 3/28/25.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarAppearance()
        
        let trackerViewController = TrackersViewController()
        let statisticsViewController = StatisticsViewController()
        
        let trackerNavigationViewController = UINavigationController(
            rootViewController: trackerViewController
        )
        let statisticsNavigationViewController = UINavigationController(
            rootViewController: statisticsViewController
        )
        
        trackerViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(
                named: "Tracker"
            ),
            selectedImage: nil
        )
        
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(
                named: "Stats"
            ),
            selectedImage: nil
        )
        
        viewControllers = [
            trackerNavigationViewController,
            statisticsNavigationViewController
        ]
    }
    
    private func setupTabBarAppearance() {
        self.tabBar.layer.borderWidth = 0.5
        self.tabBar.layer.borderColor = UIColor.gray.cgColor
        let normalColor = AppColor.ypGray
        let selectedColor = AppColor.ypBlue
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor: normalColor as Any],
            for: .normal
        )
        UITabBarItem.appearance().setTitleTextAttributes(
            [NSAttributedString.Key.foregroundColor: selectedColor as Any],
            for: .selected
        )
    }
}
