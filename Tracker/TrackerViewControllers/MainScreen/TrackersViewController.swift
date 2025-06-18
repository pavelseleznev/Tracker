//
//  ViewController.swift
//  Tracker
//
//  Created by Pavel Seleznev on 3/23/25.
//

import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Public Properties
    weak var editingDelegate: TypeOfTrackerViewControllerDelegate?
    
    lazy var trackersCollectionView: UICollectionView = {
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
    
    // MARK: - Private Properties
    private var visibleCategories: [TrackerCategory] {
        return viewModel?.trackerCategory ?? [TrackerCategory]()
    }
    private var trackersAreEmpty: Bool = true {
        didSet {
            updateCategoriesView()
        }
    }
    
    private var currentDate = Date().createDateForTracker()
    private var viewModel: TrackerViewModel?
    private var completedFilter: Bool?
    private var savedFilter: Filters?
    private var trackersForToday = false
    
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
        placeholderLabel.text = NSLocalizedString("emptyState.title", comment: "No tracker created title")
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
        searchEmptyLabel.text = NSLocalizedString("searchEmptyLabel.text", comment: "Search is empty label")
        searchEmptyLabel.font = .systemFont(ofSize: 12, weight: .medium)
        searchEmptyLabel.textAlignment = .center
        searchEmptyLabel.textColor = AppColor.ypBlack
        searchEmptyLabel.translatesAutoresizingMaskIntoConstraints = false
        return searchEmptyLabel
    }()
    
    private lazy var searchTextField: UISearchTextField = {
        let textField = UISearchTextField()
        textField.placeholder = NSLocalizedString("searchTextField.placeholder", comment: "Enter search tech")
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
        datePicker.backgroundColor = AppColor.ypWhite
        datePicker.layer.cornerRadius = 8
        datePicker.layer.masksToBounds = true
        datePicker.overrideUserInterfaceStyle = .light
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()
    
    private lazy var filterButton: UIButton = {
        let filterButton = UIButton()
        filterButton.backgroundColor = AppColor.ypBlue
        filterButton.setTitle(NSLocalizedString("filterButton.title", comment: "Filter button title"), for: .normal)
        filterButton.tintColor = AppColor.ypWhite
        filterButton.titleLabel?.textAlignment = .center
        filterButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        filterButton.clipsToBounds = true
        filterButton.layer.cornerRadius = 16
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return filterButton
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppLifecycle()
    }
    
    init(viewModel: TrackerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.screenDidAppearAnalytics()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel?.screenDidDisappearAnalytics()
    }
    
    // MARK: - Private Methods
    private func setupAppLifecycle() {
        view.backgroundColor = AppColor.ypWhite
        trackersCollectionView.backgroundColor = AppColor.ypWhite
        
        trackersAreEmpty = visibleCategories.isEmpty
        viewModel?.categoriesBinding = { [weak self] _ in
            guard let self else { return }
            self.trackersCollectionView.reloadData()
            self.updatePlaceholder()
        }
        
        trackersCollectionView.dataSource = self
        trackersCollectionView.delegate = self
        
        setupNavigationBar()
        setupSubviews()
        setupConstraints()
        
        savedFilter = loadFilter()
        useSelectedFilter(selectedFilter: savedFilter ?? Filters.allTrackers)
        
        tapToHideKeyboard()
    }
    
    private func setupNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.topItem?.title = NSLocalizedString("trackers.title", comment: "Trackers title")
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
        view.addSubview(filterButton)
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
            datePicker.widthAnchor.constraint(equalToConstant: 77),
            
            trackersCollectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 34),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: collectionParams.leftInset),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: collectionParams.rightInset),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func updatePlaceholder() {
        if !trackersAreEmpty && visibleCategories.isEmpty {
            searchEmptyImage.isHidden = false
            searchEmptyLabel.isHidden = false
            placeholderImageView.isHidden = true
            placeholderLabel.isHidden = true
        } else {
            searchEmptyImage.isHidden = true
            searchEmptyLabel.isHidden = true
        }
        trackersForToday = checkTrackersForToday()
        filterButton.isHidden = !trackersForToday
    }
    
    private func updateCategoriesView() {
        if trackersAreEmpty {
            trackersCollectionView.isHidden = true
            placeholderImageView.isHidden = false
            placeholderLabel.isHidden = false
            filterButton.isHidden = true
        } else {
            trackersCollectionView.isHidden = false
            placeholderImageView.isHidden = true
            placeholderLabel.isHidden = true
            searchEmptyImage.isHidden = true
            searchEmptyLabel.isHidden = true
            filterButton.isHidden = false
            let additionalSpace: CGFloat = 60.0
            trackersCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: additionalSpace, right: 0)
        }
    }
    
    private func updateCurrentTrackers(text: String?, date: Date) {
        viewModel?.updateCategories(with: date, text: text ?? "", completedFilter: completedFilter)
    }
    
    private func checkTrackerStoreIsEmpty() {
        if let viewModel = viewModel {
            self.trackersAreEmpty = !viewModel.availableTracker(for: Date.distantPast)
        } else {
            self.trackersAreEmpty = true
        }
    }
    
    private func checkTrackersForToday() -> Bool {
        guard let viewModel = viewModel, let currentDate = currentDate else {
            return false
        }
        return viewModel.availableTracker(for: currentDate)
    }
    
    private func loadFilter() -> Filters {
        if let savedFilterString = UserDefaults.standard.string(forKey: "selectedFilter"),
           let savedFilter = Filters(rawValue: savedFilterString) {
            return savedFilter
        }
        return Filters.allTrackers
    }
    
    private func showEditingViewController(selectedTracker: Tracker, categoryTitle: String, daysCounter: String) {
        viewModel?.showEditingViewControllerAnalytics()
        let isHabitTracker: Bool = selectedTracker.trackerSchedule.contains(where: { $0 == nil })
        let trackerEditViewController = TypeOfTrackerViewController()
        
        trackerEditViewController.typeOfTracker = isHabitTracker
        trackerEditViewController.categoryTitle = categoryTitle
        trackerEditViewController.editingTracker = selectedTracker
        trackerEditViewController.daysCounter = daysCounter
        trackerEditViewController.editingDelegate = self
        
        let navVC = UINavigationController(rootViewController: trackerEditViewController)
        self.present(navVC, animated: true)
    }
    
    private func showAlert(for selectedTracker: Tracker) {
        let alert = UIAlertController(
            title: nil,
            message: NSLocalizedString("delete.confirmation", comment: "Delete confirmation"), preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(
            title: NSLocalizedString("delete", comment: "Delete action"), style: .destructive) { [weak self] _ in
                guard let self else { return }
                guard let currentDate = currentDate else { return }
                self.viewModel?.deleteTracker(selectedTracker)
                self.checkTrackerStoreIsEmpty()
                self.updateCurrentTrackers(text: "", date: currentDate)
            }
        
        let cancelAction = UIAlertAction(
            title: NSLocalizedString("cancel",
                                     comment: "Cancel action"),
            style: .cancel) { [weak self] _ in
                guard let self else { return }
                self.dismiss(animated: true)
            }
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func createNewTracker() {
        viewModel?.createNewTrackerAnalytics()
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
    
    @objc private func filterButtonTapped() {
        viewModel?.filterButtonTappedAnalytics()
        let filtersViewController = FiltersViewController()
        filtersViewController.delegate = self
        filtersViewController.selectedFilter = savedFilter
        let navVC = UINavigationController(rootViewController: filtersViewController)
        present(navVC, animated: true)
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
        let category = visibleCategories[indexPath.section]
        let tracker = category.trackerCategoryList[indexPath.row]
        cell.delegate = self
        let completedDays = viewModel?.completedDays(for: tracker.trackerID)
        cell.configure(
            with: tracker,
            category: category.trackerCategoryTitle,
            isCompletedToday: completedDays?.completed ?? false,
            completedDays: completedDays?.number ?? 0,
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
    
    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        guard let selectedIndexPath = indexPaths.first else { return nil }
        let selectedTrackerCategory = visibleCategories[selectedIndexPath.section]
        let selectedTracker = selectedTrackerCategory.trackerCategoryList[selectedIndexPath.item]
        let cell = collectionView.cellForItem(at: indexPaths[0]) as? TrackerViewCell
        
        return UIContextMenuConfiguration(actionProvider: { _ in
            let pinnedTitleEnglish = "Pinned"
            let pinnedTitleRussian = "Закрепленные"
            
            let title: String
            if selectedTrackerCategory.trackerCategoryTitle == pinnedTitleEnglish || selectedTrackerCategory.trackerCategoryTitle == pinnedTitleRussian {
                title = NSLocalizedString("unpin", comment: "Unpin action")
            } else {
                title = NSLocalizedString("pin", comment: "Pin action")
            }
            
            let pinAction = UIAction(title: title, image: nil) { [weak self] _ in
                guard let self = self else { return }
                self.viewModel?.togglePin(selectedTracker)
            }
            
            let editAction = UIAction(title: NSLocalizedString("edit", comment: "Edit action"), image: nil) { [weak self] _ in
                guard let self = self else { return }
                self.showEditingViewController(selectedTracker: selectedTracker, categoryTitle: selectedTrackerCategory.trackerCategoryTitle, daysCounter: cell?.viewCellDayCounter.text ?? "")
            }
            
            let deleteAction = UIAction(title: NSLocalizedString("delete", comment: "Delete confirmation"), image: nil, attributes: .destructive) { [weak self] _ in
                guard let self = self else { return }
                self.viewModel?.deleteTrackerTappedAnalytics()
                self.showAlert(for: selectedTracker)
            }
            
            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        })
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfiguration configuration: UIContextMenuConfiguration,
        highlightPreviewForItemAt indexPath: IndexPath
    ) -> UITargetedPreview? {
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerViewCell else { return nil }
        let targetPreview = UITargetedPreview(view: cell.trackerViewCell)
        return targetPreview
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
        viewModel?.completeTrackerAnalytics()
        if let unwrappedDate = datePicker.date.createDateForTracker() {
            currentDate = unwrappedDate
            viewModel?.completedTrackers(trackerID: trackerID, date: unwrappedDate)
            self.updateCurrentTrackers(text: "", date: unwrappedDate)
        } else {
            assertionFailure("[completeTracker]: Failed to create a valid date from the date picker")
            currentDate = nil
        }
    }
}

// MARK: - TrackersViewController FiltersViewControllerDelegate
extension TrackersViewController: FiltersViewControllerDelegate {
    func useSelectedFilter(selectedFilter: Filters) {
        savedFilter = selectedFilter
        guard let currentDate = currentDate else { return }
        switch selectedFilter {
        case Filters.todayTrackers:
            completedFilter = nil
            datePicker.date = Date()
            datePickerValueChanged()
        case Filters.completedTrackers:
            completedFilter = true
            updateCurrentTrackers(text: "", date: currentDate)
        case Filters.notCompletedTrackers:
            completedFilter = false
            updateCurrentTrackers(text: "", date: currentDate)
        default:
            completedFilter = nil
            datePickerValueChanged()
        }
    }
}

// MARK: - TrackersViewController CreateTrackerViewControllerDelegate
extension TrackersViewController: CreateTrackerViewControllerDelegate, TypeOfTrackerViewControllerDelegate {
    func addNewTracker(newTracker: TrackerCategory) {
        let habitOrTracker = addTrackerDate(newTracker: newTracker)
        if let editingTracker = newTracker.trackerCategoryList.first {
            viewModel?.deleteTracker(editingTracker)
        }
        if let unwrappedDate = datePicker.date.createDateForTracker() {
            currentDate = unwrappedDate
            viewModel?.addNewTracker(habitOrTracker.trackerCategoryList[0], with: habitOrTracker)
            self.updateCurrentTrackers(text: "", date: unwrappedDate)
        } else {
            assertionFailure("[completeTracker]: Failed to create a valid date from the date picker")
            currentDate = nil
        }
        checkTrackerStoreIsEmpty()
        datePickerValueChanged()
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
