//
//  CreateCategoryViewController.swift
//  Tracker
//
//  Created by Pavel Seleznev on 5/7/25.
//

import UIKit

final class CreateCategoryViewController: UIViewController {
    
    // MARK: - Public Properties
    weak var delegate: CreateCategoryViewControllerDelegate?
    var categoryName = ""
    
    // MARK: - Private Properties
    private lazy var categoryNameField: UITextField = {
        let categoryNameField = UITextField()
        categoryNameField.font = .systemFont(ofSize: 17, weight: .regular)
        categoryNameField.leftView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: 10,
                height: categoryNameField.frame.height
            )
        )
        categoryNameField.placeholder = "Введите название категории"
        categoryNameField.leftViewMode = .always
        categoryNameField.clearButtonMode = .whileEditing
        categoryNameField.layer.cornerRadius = 16
        categoryNameField.backgroundColor = .ypLightGray.withAlphaComponent(0.3)
        categoryNameField.textColor = AppColor.ypBlack
        categoryNameField.tintColor = AppColor.ypBlack
        categoryNameField.clipsToBounds = true
        categoryNameField.delegate = self
        categoryNameField.translatesAutoresizingMaskIntoConstraints = false
        return categoryNameField
    }()
    
    private lazy var createCategoryButton: UIButton = {
        let createCategoryButton = UIButton()
        createCategoryButton.titleLabel?.textAlignment = .center
        createCategoryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createCategoryButton.setTitle("Готово", for: .normal)
        createCategoryButton.layer.cornerRadius = 16
        createCategoryButton.backgroundColor = AppColor.ypGray
        createCategoryButton.setTitleColor(AppColor.ypWhite, for: .normal)
        createCategoryButton.clipsToBounds = true
        createCategoryButton.isEnabled = false
        createCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        createCategoryButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return createCategoryButton
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppColor.ypWhite
        setupNavigationBar()
        setupSubviews()
        setupConstraints()
        tapToHideKeyboard()
    }
    
    // MARK: - Private Methods
    private func setupNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.topItem?.title = "Новая категория"
    }
    
    private func setupSubviews() {
        view.addSubview(categoryNameField)
        view.addSubview(createCategoryButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            categoryNameField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoryNameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryNameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryNameField.heightAnchor.constraint(equalToConstant: 75),
            
            createCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc private func createButtonTapped() {
        delegate?.addNewCategory(newCategory: categoryName)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - CreateCategoryViewController UITextFieldDelegate
extension CreateCategoryViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let newCategoryText = textField.text else {
            return
        }
        let newCategoryTextEntered = !newCategoryText.isEmpty
        createCategoryButton.isEnabled = newCategoryTextEntered
        createCategoryButton.backgroundColor = newCategoryTextEntered ? AppColor.ypBlack : AppColor.ypGray
        categoryName = newCategoryText
    }
}
