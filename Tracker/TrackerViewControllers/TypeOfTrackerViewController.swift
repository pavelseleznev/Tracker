//
//  TypeOfTrackerViewController.swift
//  Tracker
//
//  Created by Pavel Seleznev on 4/12/25.
//

import UIKit

final class TypeOfTrackerViewController: UIViewController {
    
    //MARK: - Public Properties
    var typeOfTracker: Bool = false
    weak var delegate: TypeOfTrackerViewControllerDelegate?
    
    //MARK: - Private Properties
    private  lazy var trackerNameInput: UITextField = {
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
    
    private let nameFieldCharacterLimitLabel: UILabel = {
        let nameFieldCharacterLimitLabel = UILabel()
        nameFieldCharacterLimitLabel.font = .systemFont(ofSize: 17, weight: .regular)
        nameFieldCharacterLimitLabel.text = "Ограничение 38 символов"
        nameFieldCharacterLimitLabel.textAlignment = .center
        nameFieldCharacterLimitLabel.textColor = AppColor.ypRed
        nameFieldCharacterLimitLabel.isHidden = true
        nameFieldCharacterLimitLabel.translatesAutoresizingMaskIntoConstraints = false
        return nameFieldCharacterLimitLabel
    }()
    
    private  lazy var createTrackerButton: UIButton = {
        let createTrackerButton = UIButton()
        createTrackerButton.titleLabel?.textAlignment = .center
        createTrackerButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createTrackerButton.setTitle("Создать", for: .normal)
        createTrackerButton.layer.cornerRadius = 16
        createTrackerButton.backgroundColor = AppColor.ypGray
        createTrackerButton.tintColor = AppColor.ypWhite
        createTrackerButton.clipsToBounds = true
        createTrackerButton.isEnabled = false
        createTrackerButton.translatesAutoresizingMaskIntoConstraints = false
        createTrackerButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return createTrackerButton
    }()
    
    private  lazy var cancelButton: UIButton = {
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.clipsToBounds = true
        cancelButton.tintColor = AppColor.ypRed
        cancelButton.backgroundColor = .white
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
            forCellReuseIdentifier: AccessibilityIdentifier.cellReuseIdentifier.rawValue
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
    
    private var isTrackerNameEmpty: Bool = false
    private var categoryTitle: String?
    private var color: UIColor?
    private var emoji: String?
    private var schedule: [Weekdays?] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.ypWhite
        
        trackerProperties.dataSource = self
        trackerProperties.delegate = self
        
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
    
    private func setupSubviews(){
        view.addSubview(trackerNameInput)
        view.addSubview(nameFieldCharacterLimitLabel)
        view.addSubview(createTrackerButton)
        view.addSubview(cancelButton)
        view.addSubview(trackerProperties)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            trackerNameInput.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            trackerNameInput.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerNameInput.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerNameInput.heightAnchor.constraint(equalToConstant: 75),
            
            nameFieldCharacterLimitLabel.topAnchor.constraint(equalTo: trackerNameInput.bottomAnchor, constant: 8),
            nameFieldCharacterLimitLabel.leadingAnchor.constraint(equalTo: trackerNameInput.leadingAnchor, constant: 28),
            nameFieldCharacterLimitLabel.trailingAnchor.constraint(equalTo: trackerNameInput.trailingAnchor, constant: -28),
            nameFieldCharacterLimitLabel.heightAnchor.constraint(equalToConstant: 22),
            
            createTrackerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createTrackerButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createTrackerButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            createTrackerButton.heightAnchor.constraint(equalToConstant: 60),
            
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.rightAnchor.constraint(equalTo: createTrackerButton.leftAnchor, constant: -8),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            trackerProperties.topAnchor.constraint(equalTo: nameFieldCharacterLimitLabel.bottomAnchor, constant: 24),
            trackerProperties.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            trackerProperties.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            trackerProperties.heightAnchor.constraint(equalToConstant: typeOfTracker ? 75 : 150)
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
            trackerColor: self.color ?? .ypGreen,
            trackerEmoji: self.emoji ?? "❤️",
            trackerSchedule: self.schedule)
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
            withIdentifier: AccessibilityIdentifier.cellReuseIdentifier.rawValue,
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

protocol TypeOfTrackerViewControllerDelegate: AnyObject {
    func addNewTracker(newTracker: TrackerCategory)
}
