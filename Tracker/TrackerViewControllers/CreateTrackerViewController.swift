//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Pavel Seleznev on 4/12/25.
//

import UIKit

final class CreateTrackerViewController: UIViewController {
    
    //MARK: - Public Property
    weak var delegate: CreateTrackerViewControllerDelegate?
    
    //MARK: - Private Properties
    private lazy var regularHabitButton: UIButton = {
        let regularHabitButton = UIButton()
        regularHabitButton.setTitle("Привычка", for: .normal)
        regularHabitButton.clipsToBounds = true
        regularHabitButton.layer.cornerRadius = 16
        regularHabitButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        regularHabitButton.titleLabel?.textAlignment = .center
        regularHabitButton.titleLabel?.textColor = AppColor.ypWhite
        regularHabitButton.tintColor = AppColor.ypWhite
        regularHabitButton.backgroundColor = AppColor.ypBlack
        regularHabitButton.translatesAutoresizingMaskIntoConstraints = false
        regularHabitButton.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        return regularHabitButton
    }()
    
    private lazy var singleTrackerButton: UIButton = {
        let singleTrackerButton = UIButton()
        singleTrackerButton.setTitle("Нерегулярные событие", for: .normal)
        singleTrackerButton.clipsToBounds = true
        singleTrackerButton.layer.cornerRadius = 16
        singleTrackerButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        singleTrackerButton.titleLabel?.textAlignment = .center
        singleTrackerButton.titleLabel?.textColor = AppColor.ypWhite
        singleTrackerButton.tintColor = AppColor.ypWhite
        singleTrackerButton.backgroundColor = AppColor.ypBlack
        singleTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        singleTrackerButton.addTarget(self, action: #selector(singleTrackerButtonTapped), for: .touchUpInside)
        return singleTrackerButton
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.ypWhite
        
        setupNavigationBar()
        setupSubviews()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.topItem?.title = "Создание трекера"
    }
    
    private func setupSubviews() {
        view.addSubview(regularHabitButton)
        view.addSubview(singleTrackerButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            regularHabitButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            regularHabitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            regularHabitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            regularHabitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            regularHabitButton.heightAnchor.constraint(equalToConstant: 60),
            
            singleTrackerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            singleTrackerButton.topAnchor.constraint(equalTo: regularHabitButton.bottomAnchor, constant: 16),
            singleTrackerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            singleTrackerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            singleTrackerButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    @objc private func habitButtonTapped() {
        let newHabitViewController = TypeOfTrackerViewController()
        newHabitViewController.typeOfTracker = false
        newHabitViewController.delegate = self
        let navigationViewController = UINavigationController(rootViewController: newHabitViewController)
        present(navigationViewController, animated: true)
    }
    
    @objc private func singleTrackerButtonTapped() {
        let newHabitViewController = TypeOfTrackerViewController()
        newHabitViewController.typeOfTracker = true
        newHabitViewController.delegate = self
        let navigationViewController = UINavigationController(rootViewController: newHabitViewController)
        present(navigationViewController, animated: true)
    }
}

extension CreateTrackerViewController: TypeOfTrackerViewControllerDelegate {
    func addNewTracker(newTracker: TrackerCategory) {
        delegate?.trackerCategoryList(newTracker: newTracker)
        if let navigationController = self.navigationController {
            navigationController.dismiss(animated: true, completion: nil)
            dismiss(animated: true, completion: nil)
        }
    }
}

protocol CreateTrackerViewControllerDelegate: AnyObject {
    func trackerCategoryList(newTracker: TrackerCategory)
}
