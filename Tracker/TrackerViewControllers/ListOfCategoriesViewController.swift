//
//  ListOfCategoriesViewController.swift
//  Tracker
//
//  Created by Pavel Seleznev on 5/7/25.
//

import UIKit

final class ListOfCategoriesViewController: UIViewController {
    
    // MARK: - Public Properties
    weak var delegate: ListOfCategoriesDelegate?
    var selectedCategory: String?
    
    // MARK: - Private Properties
    private var selectedIndexPath: IndexPath?
    private var trackerCategoryTitle: [String] = []
    private var editingIndex: Int?
    
    private lazy var categoriesTableView: UITableView = {
        let categoriesTableView = UITableView()
        categoriesTableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: ReuseIdentifier.categoryCell.rawValue
        )
        categoriesTableView.separatorStyle = .none
        categoriesTableView.layer.cornerRadius = 16
        categoriesTableView.layer.maskedCorners = [
            .layerMaxXMaxYCorner,
            .layerMaxXMinYCorner,
            .layerMinXMaxYCorner,
            .layerMinXMinYCorner
        ]
        categoriesTableView.layer.masksToBounds = true
        categoriesTableView.translatesAutoresizingMaskIntoConstraints = false
        return categoriesTableView
    }()
    
    private lazy var placeholderImageView: UIImageView = {
        let placeholderImage = UIImage(named: "TrackerPlaceholder")
        let placeholderImageView = UIImageView(image: placeholderImage)
        placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
        return placeholderImageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let placeholderLabel = UILabel()
        placeholderLabel.text = "Привычки и события можно объединить по смыслу"
        placeholderLabel.font = .systemFont(ofSize: 12, weight: .medium)
        placeholderLabel.numberOfLines = 2
        placeholderLabel.textAlignment = .center
        placeholderLabel.textColor = AppColor.ypBlack
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        return placeholderLabel
    }()
    
    private lazy var createCategoryButton: UIButton = {
        let createCategoryButton = UIButton()
        createCategoryButton.titleLabel?.textAlignment = .center
        createCategoryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createCategoryButton.setTitle("Добавить категорию", for: .normal)
        createCategoryButton.layer.cornerRadius = 16
        createCategoryButton.backgroundColor = AppColor.ypBlack
        createCategoryButton.setTitleColor(AppColor.ypWhite, for: .normal)
        createCategoryButton.clipsToBounds = true
        createCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        createCategoryButton.addTarget(self, action: #selector(createCategoryButtonTapped), for: .touchUpInside)
        return createCategoryButton
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = AppColor.ypWhite
        trackerCategoryTitle = UserDefaults.standard.array(
            forKey: ReuseIdentifier.trackerCategoryTitle.rawValue
        ) as? [String] ?? []
        categoriesTableView.dataSource = self
        categoriesTableView.delegate = self
        
        setupNavigationBar()
        setupSubviews()
        setupConstraints()
        updatePlaceholder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let savedCategory = UserDefaults.standard.string(forKey: ReuseIdentifier.selectedCategory.rawValue) {
            selectedCategory = savedCategory
            
            guard let selectedCategory = selectedCategory else { return }
            if let index = trackerCategoryTitle.firstIndex(of: selectedCategory) {
                selectedIndexPath = IndexPath(row: index, section: 0)
            } else {
                selectedIndexPath = nil
            }
        } else {
            selectedIndexPath = nil
        }
        categoriesTableView.reloadData()
    }
    
    // MARK: - Private Methods
    private func setupNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.topItem?.title = "Категория"
    }
    
    private func setupSubviews() {
        view.addSubview(categoriesTableView)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        view.addSubview(createCategoryButton)
    }
    
    private func addSeparatorLineBetweenCells(cell: UITableViewCell) {
        let separatorImageView = UIImageView()
        separatorImageView.image = UIImage(named: "BottomDivider")
        separatorImageView.tag = 0
        separatorImageView.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(separatorImageView)
        
        NSLayoutConstraint.activate([
            separatorImageView.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 16),
            separatorImageView.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -16),
            separatorImageView.bottomAnchor.constraint(equalTo: cell.bottomAnchor),
            separatorImageView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            categoriesTableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            categoriesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoriesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoriesTableView.heightAnchor.constraint(equalToConstant: CGFloat(trackerCategoryTitle.count * 75)),
            
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 80),
            placeholderLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -80),
            placeholderLabel.heightAnchor.constraint(equalToConstant: 36),
            
            createCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func updatePlaceholder() {
        categoriesTableView.isHidden = trackerCategoryTitle.isEmpty
        placeholderLabel.isHidden = !trackerCategoryTitle.isEmpty
        placeholderImageView.isHidden = !trackerCategoryTitle.isEmpty
    }
    
    private func updateTableView() {
        let newIndexPath = IndexPath(row: trackerCategoryTitle.count - 1, section: 0)
        let heightConstraints = categoriesTableView.constraints.filter { $0.firstAttribute == .height }
        categoriesTableView.removeConstraints(heightConstraints)
        categoriesTableView.heightAnchor.constraint(equalToConstant: CGFloat(trackerCategoryTitle.count * 75)).isActive = true
        categoriesTableView.beginUpdates()
        categoriesTableView.insertRows(at: [newIndexPath], with: .automatic)
        categoriesTableView.endUpdates()
        view.layoutIfNeeded()
    }
    
    private func addTrackerCategory() {
        guard let selectedCategory = selectedCategory else { return }
        delegate?.didSelectCategory(selectedCategory)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func createCategoryButtonTapped() {
        let newCategoryViewController = CreateCategoryViewController()
        newCategoryViewController.delegate = self
        let navigationViewController = UINavigationController(rootViewController: newCategoryViewController)
        present(navigationViewController, animated: true)
    }
}

// MARK: - ListOfCategoriesViewController UITableViewDataSource
extension ListOfCategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        trackerCategoryTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let categoryCell = tableView.dequeueReusableCell(
            withIdentifier: ReuseIdentifier.categoryCell.rawValue,
            for: indexPath
        )
        
        categoryCell.textLabel?.text = trackerCategoryTitle[indexPath.row]
        categoryCell.backgroundColor = AppColor.ypLightGray?.withAlphaComponent(0.3)
        categoryCell.accessoryView = nil
        
        if indexPath == selectedIndexPath {
            let doneImageView = UIImageView(image: UIImage(named: "DoneImage"))
            categoryCell.accessoryView = doneImageView
        }
        
        categoryCell.viewWithTag(0)?.removeFromSuperview()
        
        UserDefaults.standard.set(trackerCategoryTitle, forKey: ReuseIdentifier.trackerCategoryTitle.rawValue)
        
        if indexPath.row != trackerCategoryTitle.count - 1 {
            addSeparatorLineBetweenCells(cell: categoryCell)
        }
        
        return categoryCell
    }
}

// MARK: - ListOfCategoriesViewController UITableViewDelegate
extension ListOfCategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        CGFloat(75)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let prevSelectedIndexPath = selectedIndexPath {
            categoriesTableView.cellForRow(at: prevSelectedIndexPath)?.accessoryView = nil
        }
        
        let checkmarkImageView = UIImageView(image: UIImage(named: "DoneImage"))
        categoriesTableView.cellForRow(at: indexPath)?.accessoryView = checkmarkImageView
        
        selectedIndexPath = indexPath
        selectedCategory = trackerCategoryTitle[indexPath.row]
        
        UserDefaults.standard.set(selectedCategory, forKey: ReuseIdentifier.selectedCategory.rawValue)
        
        if let selectedCategory = selectedCategory {
            delegate?.didSelectCategory(selectedCategory)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let configuration = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            let editAction = UIAction(title: "Редактировать", image: nil) { [weak self] _ in
                guard let self = self else { return }
                let categoryToEdit = self.trackerCategoryTitle[indexPath.row]
                
                let editingCategoryViewController = EditingCategoryViewController()
                editingCategoryViewController.delegate = self
                editingCategoryViewController.editingCategory = categoryToEdit
                editingCategoryViewController.editingIndex = indexPath.row // Pass the index for updating later
                
                let navigationViewController = UINavigationController(rootViewController: editingCategoryViewController)
                self.present(navigationViewController, animated: true)
            }
            
            let deleteAction = UIAction(title: "Удалить", image: nil, attributes: .destructive) { [weak self] _ in
                guard let self = self else { return }
                
                let alert = UIAlertController(title: "Эта категория точно не нужна?", message: nil, preferredStyle: .actionSheet)
                alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: { _ in
                    self.trackerCategoryTitle.remove(at: indexPath.row)
                    UserDefaults.standard.set(self.trackerCategoryTitle, forKey: ReuseIdentifier.trackerCategoryTitle.rawValue)
                    
                    if let selectedIndexPath = self.selectedIndexPath, selectedIndexPath == indexPath {
                        self.selectedIndexPath = nil
                        self.selectedCategory = nil
                    }
                    self.categoriesTableView.beginUpdates()
                    self.categoriesTableView.deleteRows(at: [indexPath], with: .automatic)
                    self.categoriesTableView.endUpdates()
                    self.updatePlaceholder()
                }))
                
                self.present(alert, animated: true, completion: nil)
            }
            
            return UIMenu(title: "", children: [editAction, deleteAction])
        }
        return configuration
    }
}

// MARK: - ListOfCategoriesViewController CreateCategoryViewControllerDelegate
extension ListOfCategoriesViewController: CreateCategoryViewControllerDelegate {
    func addNewCategory(newCategory: String) {
        trackerCategoryTitle.append(newCategory)
        UserDefaults.standard.set(trackerCategoryTitle, forKey: ReuseIdentifier.trackerCategoryTitle.rawValue)
        updatePlaceholder()
        updateTableView()
    }
}

// MARK: - ListOfCategoriesViewController EditingCategoryViewControllerDelegate
extension ListOfCategoriesViewController: EditingCategoryViewControllerDelegate {
    func didUpdateCategory(at index: Int, with newCategory: String) {
        trackerCategoryTitle[index] = newCategory
        
        UserDefaults.standard.set(trackerCategoryTitle, forKey: ReuseIdentifier.trackerCategoryTitle.rawValue)
        
        categoriesTableView.reloadData()
    }
}
