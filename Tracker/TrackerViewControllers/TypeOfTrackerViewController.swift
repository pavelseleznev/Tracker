//
//  TypeOfTrackerViewController.swift
//  Tracker
//
//  Created by Pavel Seleznev on 4/12/25.
//

import UIKit

final class TypeOfTrackerViewController: UIViewController {
    
    // MARK: - Public Properties
    var typeOfTracker: Bool = false
    weak var delegate: TypeOfTrackerViewControllerDelegate?
    
    // MARK: - Private Properties
    private lazy var trackerNameInput: UITextField = {
        let trackerNameInput = UITextField()
        trackerNameInput.font = .systemFont(ofSize: 17, weight: .regular)
        trackerNameInput.leftView = UIView(
            frame: CGRect(
                x: 0,
                y: 0,
                width: 10,
                height: trackerNameInput.frame.height
            )
        )
        trackerNameInput.placeholder = "Введите название трекера"
        trackerNameInput.leftViewMode = .always
        trackerNameInput.clearButtonMode = .whileEditing
        trackerNameInput.layer.cornerRadius = 16
        trackerNameInput.backgroundColor = .ypLightGray.withAlphaComponent(0.3)
        trackerNameInput.textColor = AppColor.ypBlack
        trackerNameInput.tintColor = AppColor.ypBlack
        trackerNameInput.clipsToBounds = true
        trackerNameInput.delegate = self
        trackerNameInput.translatesAutoresizingMaskIntoConstraints = false
        return trackerNameInput
    }()
    
    private lazy var nameFieldCharacterLimitLabel: UILabel = {
        let nameFieldCharacterLimitLabel = UILabel()
        nameFieldCharacterLimitLabel.font = .systemFont(ofSize: 17, weight: .regular)
        nameFieldCharacterLimitLabel.text = "Ограничение 38 символов"
        nameFieldCharacterLimitLabel.textAlignment = .center
        nameFieldCharacterLimitLabel.textColor = AppColor.ypRed
        nameFieldCharacterLimitLabel.isHidden = true
        nameFieldCharacterLimitLabel.translatesAutoresizingMaskIntoConstraints = false
        return nameFieldCharacterLimitLabel
    }()
    
    private lazy var createTrackerButton: UIButton = {
        let createTrackerButton = UIButton()
        createTrackerButton.titleLabel?.textAlignment = .center
        createTrackerButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createTrackerButton.setTitle("Создать", for: .normal)
        createTrackerButton.layer.cornerRadius = 16
        createTrackerButton.backgroundColor = AppColor.ypGray
        createTrackerButton.setTitleColor(AppColor.ypWhite, for: .normal)
        createTrackerButton.clipsToBounds = true
        createTrackerButton.isEnabled = false
        createTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        createTrackerButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return createTrackerButton
    }()
    
    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.clipsToBounds = true
        cancelButton.tintColor = AppColor.ypRed
        cancelButton.backgroundColor = AppColor.ypWhite
        cancelButton.layer.borderColor = UIColor.ypRed.cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.cornerRadius = 16
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return cancelButton
    }()
    
    private lazy var trackerProperties: UITableView = {
        let trackerPropertiesTableView = UITableView()
        trackerPropertiesTableView.register(
            TrackerPropertiesCell.self,
            forCellReuseIdentifier: ReuseIdentifier.Cell.rawValue
        )
        trackerPropertiesTableView.separatorInset = UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 0,
            right: 16
        )
        trackerPropertiesTableView.layer.masksToBounds = true
        trackerPropertiesTableView.layer.cornerRadius = 16
        trackerPropertiesTableView.layer.maskedCorners = [
            .layerMaxXMaxYCorner,
            .layerMaxXMinYCorner,
            .layerMinXMaxYCorner,
            .layerMinXMinYCorner
        ]
        trackerPropertiesTableView.translatesAutoresizingMaskIntoConstraints = false
        return trackerPropertiesTableView
    }()
    
    private lazy var emojiLabel: UILabel = {
        let emojiLabel = UILabel()
        emojiLabel.text = "Emoji"
        emojiLabel.textColor = .ypBlack
        emojiLabel.font = .systemFont(ofSize: 19, weight: .bold)
        emojiLabel.translatesAutoresizingMaskIntoConstraints = false
        return emojiLabel
    }()
    
    private lazy var emojiCollectionView: UICollectionView = {
        let emojiCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        emojiCollectionView.translatesAutoresizingMaskIntoConstraints = false
        emojiCollectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: ReuseIdentifier.EmojiCell.rawValue)
        emojiCollectionView.isScrollEnabled = false
        return emojiCollectionView
    }()
    
    private lazy var colorLabel: UILabel = {
        let colorLabel = UILabel()
        colorLabel.text = "Цвет"
        colorLabel.textColor = .ypBlack
        colorLabel.font = .systemFont(ofSize: 19, weight: .bold)
        colorLabel.translatesAutoresizingMaskIntoConstraints = false
        return colorLabel
    }()
    
    private lazy var colorCollectionView: UICollectionView = {
        let colorCollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        colorCollectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ReuseIdentifier.ColorCell.rawValue)
        colorCollectionView.isScrollEnabled = false
        return colorCollectionView
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .ypWhite
        return contentView
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delaysContentTouches = false
        return scrollView
    }()
    
    private var isTrackerNameEmpty: Bool = false
    private var categoryTitle: String?
    private var color: UIColor?
    private var emoji: String?
    private var schedule: [Weekdays?] = []
    
    private let emojiArray: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    
    private let colorArray: [UIColor] = [
        .colorSelection1,
        .colorSelection2,
        .colorSelection3,
        .colorSelection4,
        .colorSelection5,
        .colorSelection6,
        .colorSelection7,
        .colorSelection8,
        .colorSelection9,
        .colorSelection10,
        .colorSelection11,
        .colorSelection12,
        .colorSelection13,
        .colorSelection14,
        .colorSelection15,
        .colorSelection16,
        .colorSelection17,
        .colorSelection18
    ]
    
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
        cellCount: 6,
        height: 224,
        leftInset: 18,
        rightInset: 18,
        cellSpacing: 0
    )
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.ypWhite
        
        trackerProperties.dataSource = self
        trackerProperties.delegate = self
        
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
        
        emojiCollectionView.allowsMultipleSelection = false
        colorCollectionView.allowsMultipleSelection = false
        
        createNavigationBar()
        setupSubviews()
        setupConstraints()
        tapToHideKeyboard()
    }
    
    // MARK: - Private Methods
    private func createNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.topItem?.title = typeOfTracker ? "Новое нерегулярное событие" : "Новая привычка"
    }
    
    private func setupSubviews() {
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        contentView.addSubview(trackerNameInput)
        contentView.addSubview(nameFieldCharacterLimitLabel)
        contentView.addSubview(createTrackerButton)
        contentView.addSubview(cancelButton)
        contentView.addSubview(trackerProperties)
        contentView.addSubview(emojiLabel)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorLabel)
        contentView.addSubview(colorCollectionView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            trackerNameInput.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
            trackerNameInput.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trackerNameInput.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            trackerNameInput.heightAnchor.constraint(equalToConstant: 75),
            
            nameFieldCharacterLimitLabel.topAnchor.constraint(equalTo: trackerNameInput.bottomAnchor),
            nameFieldCharacterLimitLabel.leadingAnchor.constraint(equalTo: trackerNameInput.leadingAnchor, constant: 28),
            nameFieldCharacterLimitLabel.trailingAnchor.constraint(equalTo: trackerNameInput.trailingAnchor, constant: -28),
            nameFieldCharacterLimitLabel.heightAnchor.constraint(equalToConstant: 22),
            
            createTrackerButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 16),
            createTrackerButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createTrackerButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            createTrackerButton.heightAnchor.constraint(equalToConstant: 60),
            
            cancelButton.topAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 16),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.rightAnchor.constraint(equalTo: createTrackerButton.leftAnchor, constant: -8),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            trackerProperties.topAnchor.constraint(equalTo: nameFieldCharacterLimitLabel.bottomAnchor, constant: 24),
            trackerProperties.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            trackerProperties.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            trackerProperties.heightAnchor.constraint(equalToConstant: typeOfTracker ? 75 : 150),
            
            emojiLabel.topAnchor.constraint(equalTo: trackerProperties.bottomAnchor, constant: 32),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            emojiLabel.widthAnchor.constraint(equalToConstant: 52),
            emojiLabel.heightAnchor.constraint(equalToConstant: 18),
            
            emojiCollectionView.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: collectionParams.height),
            
            colorLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 16),
            colorLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            colorLabel.widthAnchor.constraint(equalToConstant: 48),
            colorLabel.heightAnchor.constraint(equalToConstant: 18),
            
            colorCollectionView.topAnchor.constraint(equalTo: colorLabel.bottomAnchor),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            colorCollectionView.heightAnchor.constraint(equalToConstant: collectionParams.height),
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func checkNameFieldAndScheduleFilled() {
        var allFullFill = false
        if typeOfTracker == false {
            allFullFill = !schedule.isEmpty && isTrackerNameEmpty
        } else {
            allFullFill = isTrackerNameEmpty
        }
        createTrackerButton.isEnabled = allFullFill
        createTrackerButton.backgroundColor = allFullFill ? AppColor.ypBlack : AppColor.ypGray
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func createButtonTapped() {
        let newTracker = Tracker(
            trackerID: UUID(),
            trackerName: trackerNameInput.text ?? "",
            trackerColor: self.color ?? .colorSelection17,
            trackerEmoji: self.emoji ?? "❤️",
            trackerSchedule: self.schedule,
            trackerDate: Date())
        let category = TrackerCategory(
            trackerCategoryTitle: self.categoryTitle ?? "Домашний уют",
            trackerCategoryList: [newTracker])
        delegate?.addNewTracker(newTracker: category)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - TypeOfTrackerViewController UITableViewDataSource
extension TypeOfTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        typeOfTracker ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ReuseIdentifier.Cell.rawValue,
            for: indexPath
        ) as? TrackerPropertiesCell else {
            return UITableViewCell()
        }
        cell.backgroundColor = .ypLightGray.withAlphaComponent(0.3)
        let lastCell = typeOfTracker ? 0 : 1
        if indexPath.row == lastCell {
            cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
        }
        cell.configure(indexPath: indexPath)
        if indexPath.row == 1 {
            let detailsText: String
            if schedule.count == 7 {
                detailsText = "Каждый день"
            } else {
                let shortDayNames = schedule.compactMap { $0?.shortDayName }
                detailsText = shortDayNames.joined(separator: ", ")
            }
            cell.setup(detailsText: detailsText)
        }
        cell.delegate = self
        return cell
    }
}

// MARK: - TypeOfTrackerViewController UITableViewDelegate
extension TypeOfTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        trackerDetailsButtonTapped(at: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        CGFloat(75)
    }
}

// MARK: - TypeOfTrackerViewController TrackerPropertiesCellDelegate
extension TypeOfTrackerViewController: TrackerPropertiesCellDelegate {
    func trackerDetailsButtonTapped(at indexPath: IndexPath) {
        if indexPath.row == 1 {
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.delegate = self
            scheduleViewController.initialSelectedWeekdays = schedule
            let navigationViewController = UINavigationController(rootViewController: scheduleViewController)
            present(navigationViewController, animated: true)
        }
    }
}

// MARK: - TypeOfTrackerViewController UITextFieldDelegate
extension TypeOfTrackerViewController: UITextFieldDelegate {
    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard let currentText = textField.text else {
            return true
        }
        let newText = (
            currentText as NSString
        ).replacingCharacters(
            in: range,
            with: string
        )
        
        isTrackerNameEmpty = !newText.isEmpty
        checkNameFieldAndScheduleFilled()
        
        let maxLength = 38
        nameFieldCharacterLimitLabel.isHidden = newText.count < maxLength
        return newText.count <= maxLength
    }
}

// MARK: - TypeOfTrackerViewController ScheduleViewControllerDelegate
extension TypeOfTrackerViewController: ScheduleViewControllerDelegate {
    func didSelectWeekdays(_ weekdays: [Weekdays]) {
        schedule = weekdays
        schedule.sort { $0?.numberValueRus ?? 0 < $1?.numberValueRus ?? 0 }
        trackerProperties.reloadData()
        checkNameFieldAndScheduleFilled()
    }
}

// MARK: - TypeOfTrackerViewController: UICollectionViewDataSource
extension TypeOfTrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        colorArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ReuseIdentifier.EmojiCell.rawValue,
                for: indexPath
            ) as? EmojiCollectionViewCell else {
                return UICollectionViewCell()
            }
            let emoji = emojiArray[indexPath.row]
            cell.configure(emoji: emoji)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ReuseIdentifier.ColorCell.rawValue,
                for: indexPath
            ) as? ColorCollectionViewCell else {
                return UICollectionViewCell()
            }
            let color = colorArray[indexPath.row]
            cell.configure(color: color)
            return cell
        }
    }
}

// MARK: - TypeOfTrackerViewController: UICollectionViewDelegateFlowLayout
extension TypeOfTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(
            top: 24,
            left: collectionParams.leftInset,
            bottom: 24,
            right: collectionParams.rightInset
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let paddingWidth: CGFloat = collectionParams.leftInset + collectionParams.rightInset + CGFloat((collectionParams.cellCount - 1)) * collectionParams.cellSpacing
        let availableWidth = collectionView.frame.width - paddingWidth
        let cellWidth = availableWidth / CGFloat(collectionParams.cellCount)
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        collectionParams.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        if collectionView == emojiCollectionView {
            emoji = emojiArray[indexPath.row]
            cell?.contentView.backgroundColor = .ypLightGray
        } else {
            color = colorArray[indexPath.row]
            cell?.contentView.layer.borderWidth = 3
            cell?.contentView.layer.borderColor = UIColor.ypGreen.withAlphaComponent(0.3).cgColor
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        if collectionView == emojiCollectionView {
            cell?.contentView.backgroundColor = .ypWhite
        } else {
            color = colorArray[indexPath.row]
            cell?.contentView.layer.borderWidth = 0
            cell?.contentView.layer.borderColor = UIColor.ypGreen.withAlphaComponent(0.3).cgColor
        }
    }
}

protocol TypeOfTrackerViewControllerDelegate: AnyObject {
    func addNewTracker(newTracker: TrackerCategory)
}
