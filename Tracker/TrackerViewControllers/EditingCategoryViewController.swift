//
//  EditingCategoryViewController.swift
//  Tracker
//
//  Created by Pavel Seleznev on 5/24/25.
//

import UIKit

final class EditingCategoryViewController: UIViewController {
    
    // MARK: - Public Properties
    weak var delegate: EditingCategoryViewControllerDelegate?
    var editingCategory = ""
    var editingIndex: Int?
    
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
    
    private lazy var saveCategoryButton: UIButton = {
        let saveCategoryButton = UIButton()
        saveCategoryButton.titleLabel?.textAlignment = .center
        saveCategoryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        saveCategoryButton.setTitle("Готово", for: .normal)
        saveCategoryButton.layer.cornerRadius = 16
        saveCategoryButton.tintColor = AppColor.ypWhite
        saveCategoryButton.backgroundColor = AppColor.ypGray
        saveCategoryButton.clipsToBounds = true
        saveCategoryButton.isEnabled = false
        saveCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        saveCategoryButton.addTarget(self, action: #selector(saveEditingCategoryButtonTapped), for: .touchUpInside)
        return saveCategoryButton
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppColor.ypWhite
        view.addSubview(categoryNameField)
        view.addSubview(saveCategoryButton)
        categoryNameField.text = editingCategory
        createNavigationBar()
        setupConstraints()
        tapToHideKeyboard()
    }
    
    //MARK: - Private Methods
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            categoryNameField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoryNameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryNameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryNameField.heightAnchor.constraint(equalToConstant: 75),
            
            saveCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            saveCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            saveCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            saveCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func createNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.topItem?.title = "Редактирование категории"
    }
    
    @objc private func saveEditingCategoryButtonTapped() {
        guard let newCategory = categoryNameField.text, !newCategory.isEmpty else { return }
        guard let editingIndex = editingIndex else { return }
        
        delegate?.didUpdateCategory(at: editingIndex, with: newCategory)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - EditingCategoryViewController UITextFieldDelegate
extension EditingCategoryViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let newText = textField.text else {
            return
        }
        let isNameFilled = !newText.isEmpty
        saveCategoryButton.isEnabled = isNameFilled
        saveCategoryButton.backgroundColor = isNameFilled ? AppColor.ypBlack : AppColor.ypGray
        editingCategory = newText
    }
}
