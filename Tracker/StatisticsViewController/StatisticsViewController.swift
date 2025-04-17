//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Pavel Seleznev on 3/28/25.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    // MARK: Private Properties
    private lazy var placeholderImageView: UIImageView = {
        let placeholderImage = UIImage(named: "StatPlaceholder")
        let placeholderImageView = UIImageView(image: placeholderImage)
        placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
        return placeholderImageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let placeholderLabel = UILabel()
        placeholderLabel.text = "Анализировать пока нечего"
        placeholderLabel.font = .systemFont(ofSize: 12, weight: .medium)
        placeholderLabel.textAlignment = .center
        placeholderLabel.textColor = UIColor(named: "Black")
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        return placeholderLabel
    }()
    
    private lazy var navigationBar: UINavigationBar = {
        let navigationBar = navigationController?.navigationBar ?? UINavigationBar()
        navigationBar.topItem?.title = "Статистика"
        navigationBar.prefersLargeTitles = true
        navigationBar.topItem?.largeTitleDisplayMode = .always
        return navigationBar
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.ypWhite
        
        setupSubviews()
        setupConstraints()
    }
    
    // MARK: Private Methods
    private func setupSubviews(){
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        view.addSubview(navigationBar)
    }
    
    private func setupConstraints() {
        placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        placeholderImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        placeholderImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8).isActive = true
        placeholderLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        placeholderLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        placeholderLabel.heightAnchor.constraint(equalToConstant: 18).isActive = true
    }
}
