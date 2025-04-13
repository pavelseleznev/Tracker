//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Pavel Seleznev on 3/28/25.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    //MARK: Private Properties
    private lazy var placeholderImageView: UIImageView = {
        let image = UIImage(named: "StatPlaceholder")
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.textColor = UIColor(named: "Black")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var navigationBar: UINavigationBar = {
        let navigationBar = navigationController?.navigationBar ?? UINavigationBar()
        navigationBar.topItem?.title = "Статистика"
        navigationBar.prefersLargeTitles = true
        navigationBar.topItem?.largeTitleDisplayMode = .always
        return navigationBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.ypWhite
        
        setupSubviews()
        setupConstraints()
    }
    
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
