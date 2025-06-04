//
//  OnboardingViewController.swift
//  Tracker
//
//  Created by Pavel Seleznev on 5/2/25.
//

import UIKit

final class OnboardingViewController: UIPageViewController {
    
    // MARK: - Private Properties
    private var onboardingFirstViewController = OnboardingFirstViewController()
    private var onboardingSecondViewController = OnboardingSecondViewController()
    
    private lazy var pages = [onboardingFirstViewController, onboardingSecondViewController]
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.pageIndicatorTintColor = .ypBlack.withAlphaComponent(0.3)
        pageControl.currentPageIndicatorTintColor = .ypBlack
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        view.addSubview(pageControl)
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    // MARK: - Internal Method
    func continueButtonTapped() {
        UserDefaults.standard.set(true, forKey: ReuseIdentifier.HasLaunchedBefore.rawValue)
        UIApplication.shared.windows.first?.rootViewController = TabBarController()
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }
}

// MARK: - OnboardingViewController UIPageViewControllerDataSource
extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController) -> UIViewController? {
            
            guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
                return nil
            }
            let previousIndex = viewControllerIndex - 1
            guard previousIndex >= 0 else {
                return nil
            }
            return pages[previousIndex]
        }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController) -> UIViewController? {
            
            guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
                return nil
            }
            let nextIndex = viewControllerIndex + 1
            guard nextIndex < pages.count else {
                return nil
            }
            return pages[nextIndex]
        }
}

// MARK: - OnboardingViewController UIPageViewControllerDelegate
extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool) {
            
            if let currentViewController = pageViewController.viewControllers?.first,
               let currentIndex = pages.firstIndex(of: currentViewController) {
                pageControl.currentPage = currentIndex
            }
        }
}
