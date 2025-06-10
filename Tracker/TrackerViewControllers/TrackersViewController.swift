//
//  ViewController.swift
//  Tracker
//
//  Created by Pavel Seleznev on 3/23/25.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Private Properties
    private var visibleCategories: [TrackerCategory] {
        return viewModel?.trackerCategory ?? [TrackerCategory]()
    }
    private var isCategoriesEmpty: Bool = false {
        didSet {
            self.updateCategoriesView()
            self.updatePlaceholder()
        }
    }
    
    private var currentDate = Date().createDateForTracker()
    private var viewModel: TrackerViewModel?
    
    private struct CollectionParams {
        let cellCount: Int
        let height: CGFloat
        let leftInset: CGFloat
        let rightInset: CGFloat
        let cellSpacing: CGFloat
        
        init(
            cellCount: Int,
            height: CGFloat,
            leftInset: CGFloat,
            rightInset: CGFloat,
            cellSpacing: CGFloat
        ) {
            self.cellCount = cellCount
            self.height = height
            self.leftInset = leftInset
            self.rightInset = rightInset
            self.cellSpacing = cellSpacing
        }
    }
    
    private let collectionParams = CollectionParams(
        cellCount: 2,
        height: 148,
        leftInset: 16,
        rightInset: -16,
        cellSpacing: 9
    )
    
    private lazy var placeholderImageView: UIImageView = {
        let placeholderImage = UIImage(named: "TrackerPlaceholder")
        let placeholderImageView = UIImageView(image: placeholderImage)
        placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
        return placeholderImageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let placeholderLabel = UILabel()
        placeholderLabel.text = "Что будем отслеживать?"
        placeholderLabel.font = .systemFont(ofSize: 12, weight: .medium)
        placeholderLabel.textAlignment = .center
        placeholderLabel.textColor = AppColor.ypBlack
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        return placeholderLabel
    }()
    
    private lazy var searchEmptyImage: UIImageView = {
        let searchEmpty = UIImage(named: "SearchEmptyImage")
        let searchEmptyImage = UIImageView(image: searchEmpty)
        searchEmptyImage.translatesAutoresizingMaskIntoConstraints = false
        return searchEmptyImage
    }()
    
    private lazy var searchEmptyLabel: UILabel = {
        let searchEmptyLabel = UILabel()
        searchEmptyLabel.text = "Ничего не найдено"
        searchEmptyLabel.font = .systemFont(ofSize: 12, weight: .medium)
        searchEmptyLabel.textAlignment = .center
        searchEmptyLabel.textColor = AppColor.ypBlack
        searchEmptyLabel.translatesAutoresizingMaskIntoConstraints = false
        return searchEmptyLabel
    }()
    
    private lazy var searchTextField: UISearchTextField = {
        let textField = UISearchTextField()
        textField.placeholder = "Поиск"
        textField.font = .systemFont(ofSize: 17, weight: .medium)
        textField.backgroundColor = .clear
        textField.textColor = AppColor.ypBlack
        textField.tintColor = AppColor.ypBlack
        textField.delegate = self
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.tintColor = AppColor.ypBlue
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    private lazy var trackersCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.register(
            TrackerViewCell.self,
            forCellWithReuseIdentifier: ReuseIdentifier.cell.rawValue
        )
        collectionView.register(
            HeaderSectionView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: ReuseIdentifier.header.rawValue
        )
        return collectionView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppLifecycle()
    }
    
    // MARK: - Private Methods
    private func setupAppLifecycle() {
        view.backgroundColor = AppColor.ypWhite
        trackersCollectionView.backgroundColor = AppColor.ypWhite
        
        viewModel = TrackerViewModel()
        viewModel?.categoriesBinding = { [weak self] categories in
            guard let self else { return }
            self.updatePlaceholder()
            self.trackersCollectionView.reloadData()
        }
        if viewModel != nil {
            guard let viewModel = viewModel else { return }
            isCategoriesEmpty = viewModel.isCategoriesEmpty
        }
        
        trackersCollectionView.dataSource = self
        trackersCollectionView.delegate = self
        
        setupNavigationBar()
        setupSubviews()
        setupConstraints()
        
        updatePlaceholder()
        updateCategoriesView()
        datePickerValueChanged()
        tapToHideKeyboard()
    }
    
    private func setupNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.topItem?.title = "Трекеры"
        navigationBar.prefersLargeTitles = true
        navigationBar.topItem?.largeTitleDisplayMode = .always
        
        let leftButton = UIBarButtonItem(
            image: UIImage(named: "AddTracker"),
            style: .plain,
            target: self,
            action: #selector(self.createNewTracker)
        )
        leftButton.tintColor = AppColor.ypBlack
        navigationItem.leftBarButtonItem = leftButton
        
        let rightButton = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = rightButton
    }
    
    private func setupSubviews() {
        view.addSubview(trackersCollectionView)
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        view.addSubview(searchTextField)
        view.addSubview(searchEmptyImage)
        view.addSubview(searchEmptyLabel)
        searchEmptyImage.isHidden = true
        searchEmptyLabel.isHidden = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: placeholderImageView.centerXAnchor),
            
            searchEmptyImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            searchEmptyImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            searchEmptyLabel.topAnchor.constraint(equalTo: searchEmptyImage.bottomAnchor, constant: 8),
            searchEmptyLabel.centerXAnchor.constraint(equalTo: searchEmptyImage.centerXAnchor),
            
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 36),
            
            datePicker.heightAnchor.constraint(equalToConstant: 34),
            datePicker.widthAnchor.constraint(equalToConstant: 97),
            
            trackersCollectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 34),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: collectionParams.leftInset),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: collectionParams.rightInset),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func updatePlaceholder() {
        if !isCategoriesEmpty && visibleCategories.isEmpty {
            searchEmptyImage.isHidden = false
            searchEmptyLabel.isHidden = false
            placeholderImageView.isHidden = true
            placeholderLabel.isHidden = true
        } else {
            searchEmptyImage.isHidden = true
            searchEmptyLabel.isHidden = true
        }
    }
    
    private func updateCategoriesView() {
        if isCategoriesEmpty {
            trackersCollectionView.isHidden = true
            placeholderImageView.isHidden = false
            placeholderLabel.isHidden = false
        } else {
            trackersCollectionView.isHidden = false
            placeholderImageView.isHidden = true
            placeholderLabel.isHidden = true
            searchEmptyImage.isHidden = true
            searchEmptyLabel.isHidden = true
        }
    }
    
    private func updateCurrentTrackers(text: String?, date: Date) {
        viewModel?.updateTrackerStore(with: date, text: text ?? "")
        updatePlaceholder()
    }
    
    @objc private func createNewTracker() {
        let createTrackerViewController = CreateTrackerViewController()
        createTrackerViewController.delegate = self
        let navigationViewController = UINavigationController(rootViewController: createTrackerViewController)
        present(navigationViewController, animated: true)
    }
    
    @objc private func datePickerValueChanged() {
        if let unwrappedDate = datePicker.date.createDateForTracker() {
            currentDate = unwrappedDate
            updateCurrentTrackers(text: searchTextField.text, date: unwrappedDate)
        } else {
            assertionFailure("[datePickerValueChanged]: Failed to create a valid date from the date picker")
            currentDate = nil
        }
    }
}

// MARK: - TrackersViewController UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        viewModel?.trackerCategory.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel?.trackerCategory[section].trackerCategoryList.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: ReuseIdentifier.header.rawValue,
            for: indexPath
        ) as? HeaderSectionView else {
            return UICollectionReusableView()
        }
        let titleCategory = visibleCategories[indexPath.section].trackerCategoryTitle
        view.headerSectionLabel.text = titleCategory
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ReuseIdentifier.cell.rawValue,
            for: indexPath
        ) as? TrackerViewCell else {
            return UICollectionViewCell()
        }
        let cellData = visibleCategories
        let tracker = cellData[indexPath.section].trackerCategoryList[indexPath.row]
        let viewModelCompletedDays = viewModel?.completedDays(for: tracker.trackerID)
        cell.delegate = self
        cell.configure(
            with: tracker,
            isCompletedToday: viewModelCompletedDays?.completed ?? false,
            completedDays: viewModelCompletedDays?.number ?? 0,
            indexPath: indexPath
        )
        return cell
    }
}

// MARK: - TrackersViewController UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: (collectionView.bounds.width - collectionParams.cellSpacing) / CGFloat(collectionParams.cellCount),
               height: collectionParams.height)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        collectionParams.cellSpacing
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 30)
    }
}

// MARK: - TrackersViewController UUITextFieldDelegate
extension TrackersViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let currentDate = Date().createDateForTracker() {
            updateCurrentTrackers(text: searchTextField.text, date: currentDate)
        }
        return true
    }
}

// MARK: - TrackersViewController TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
    func completeTracker(trackerID: UUID, at indexPath: IndexPath) {
        if let unwrappedDate = datePicker.date.createDateForTracker() {
            currentDate = unwrappedDate
            viewModel?.completedTrackers(trackerID: trackerID, date: unwrappedDate)
            trackersCollectionView.reloadItems(at: [indexPath])
        } else {
            assertionFailure("[completeTracker]: Failed to create a valid date from the date picker")
            currentDate = nil
        }
    }
}

// MARK: - TrackersViewController CreateTrackerViewControllerDelegate
extension TrackersViewController: CreateTrackerViewControllerDelegate {
    func addNewTrackers(newTracker: TrackerCategory) {
        let habitOrTracker = addTrackerDate(newTracker: newTracker)
        isCategoriesEmpty = false
        viewModel?.addNewTracker(habitOrTracker.trackerCategoryList[0], with: habitOrTracker)
    }
    
    private func addTrackerDate(newTracker: TrackerCategory) -> TrackerCategory {
        let tracker = newTracker.trackerCategoryList[0]
        if tracker.trackerSchedule.isEmpty {
            let updatedTracker = Tracker(
                trackerID: tracker.trackerID,
                trackerName: tracker.trackerName,
                trackerColor: tracker.trackerColor,
                trackerEmoji: tracker.trackerEmoji,
                trackerSchedule: tracker.trackerSchedule,
                trackerDate: currentDate
            )
            return TrackerCategory(
                trackerCategoryTitle: newTracker.trackerCategoryTitle,
                trackerCategoryList: [updatedTracker]
            )
        }
        else {
            return newTracker
        }
    }
}
