//
//  UIViewController.swift
//  Tracker
//
//  Created by Pavel Seleznev on 4/13/25.
//

import UIKit

extension UIViewController {
    func tapToHideKeyboard() {
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(
                UIViewController.dismissKeyboard
            )
        )
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}
