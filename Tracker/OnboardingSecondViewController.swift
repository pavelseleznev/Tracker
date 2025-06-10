//
//  OnboardingSecondViewController.swift
//  Tracker
//
//  Created by Pavel Seleznev on 5/27/25.
//

import UIKit

final class OnboardingSecondViewController: UIViewController {
    
    // MARK: - Private Properties
    private var onboardingViewController: OnboardingViewController?
    
    private lazy var onboardingRedImageView: UIImageView = {
        let onboardingRedImageView = UIImageView()
        onboardingRedImageView.contentMode  = .scaleAspectFill
        onboardingRedImageView.image = UIImage(resource: .onboardingRed)
        onboardingRedImageView.translatesAutoresizingMaskIntoConstraints = false
        return onboardingRedImageView
    }()
    
    private lazy var textLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.text = "Даже если это не литры воды и йога"
        textLabel.textColor = AppColor.ypBlack
        textLabel.numberOfLines = 0
        textLabel.textAlignment = .center
        textLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        return textLabel
    }()
    
    private  lazy var continueButton: UIButton = {
        let continueButton = UIButton()
        continueButton.backgroundColor = AppColor.ypBlack
        continueButton.tintColor = AppColor.ypWhite
        continueButton.setTitle("Вот это технологии!", for: .normal)
        continueButton.titleLabel?.textColor = AppColor.ypWhite
        continueButton.titleLabel?.textAlignment = .center
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        continueButton.layer.cornerRadius = 16
        continueButton.clipsToBounds = true
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        return continueButton
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(onboardingRedImageView)
        view.addSubview(textLabel)
        view.addSubview(continueButton)
        setupConstraints()
        onboardingViewController = OnboardingViewController()
    }
    
    // MARK: - Private Methods
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            onboardingRedImageView.topAnchor.constraint(equalTo: view.topAnchor),
            onboardingRedImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            onboardingRedImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            onboardingRedImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            textLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 70),
            textLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textLabel.heightAnchor.constraint(equalToConstant: 114),
            
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            continueButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func continueButtonTapped() {
        onboardingViewController?.continueButtonTapped()
    }
}
