//
//  ScheduleViewController.swift
//  Tracker
//
//  Created by Pavel Seleznev on 4/12/25.
//

import UIKit

final class ScheduleViewController: UIViewController {
    
    // MARK: - Public Properties
    var initialSelectedWeekdays: [Weekdays?]?
    weak var delegate: ScheduleViewControllerDelegate?
    
    // MARK: - Private Properties
    private  lazy var scheduleDoneButton: UIButton = {
        let scheduleDoneButton = UIButton()
        scheduleDoneButton.setTitle(NSLocalizedString("doneButton.title", comment: "Done button title"), for: .normal)
        scheduleDoneButton.titleLabel?.textAlignment = .center
        scheduleDoneButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        scheduleDoneButton.backgroundColor = AppColor.ypBlack
        scheduleDoneButton.setTitleColor(AppColor.ypWhite, for: .normal)
        scheduleDoneButton.clipsToBounds = true
        scheduleDoneButton.layer.cornerRadius = 16
        scheduleDoneButton.translatesAutoresizingMaskIntoConstraints = false
        scheduleDoneButton.addTarget(self, action: #selector(scheduleSelectedButtonTapped), for: .touchUpInside)
        return scheduleDoneButton
    }()
    
    private lazy var scheduleView: UITableView = {
        let scheduleView = UITableView()
        scheduleView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: ReuseIdentifier.cell.rawValue
        )
        scheduleView.separatorInset = UIEdgeInsets(
            top: 0,
            left: 16,
            bottom: 0,
            right: 16
        )
        scheduleView.separatorStyle = .singleLine
        scheduleView.separatorColor = .lightGray
        scheduleView.layer.cornerRadius = 16
        scheduleView.layer.masksToBounds = true
        scheduleView.layer.maskedCorners = [
            .layerMaxXMaxYCorner,
            .layerMaxXMinYCorner,
            .layerMinXMaxYCorner,
            .layerMinXMinYCorner
        ]
        scheduleView.translatesAutoresizingMaskIntoConstraints = false
        return scheduleView
    }()
    
    private var switches = [UISwitch]()
    private var selectedWeekdays: [Weekdays] = []
    private let weekdays: [Weekdays] = Weekdays.allCases
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.ypWhite
        
        scheduleView.dataSource = self
        scheduleView.delegate = self
        
        setupNavigationBar()
        setupSubviews()
        setupConstraints()
        setupSwitches()
    }
    
    // MARK: - Private Methods
    private func setupNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.topItem?.title = NSLocalizedString("schedule.title", comment: "Schedule title")
    }
    
    private func setupSubviews(){
        view.addSubview(scheduleDoneButton)
        view.addSubview(scheduleView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scheduleDoneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            scheduleDoneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            scheduleDoneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            scheduleDoneButton.heightAnchor.constraint(equalToConstant: 60),
            
            scheduleView.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            scheduleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scheduleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scheduleView.heightAnchor.constraint(equalToConstant: 525)
        ])
    }
    
    private func setupSwitches() {
        for day in weekdays {
            let switchControl = UISwitch()
            switchControl.onTintColor = AppColor.ypBlue
            switchControl.tintColor = .white
            switchControl.backgroundColor = .white
            switchControl.thumbTintColor = .white
            switchControl.layer.cornerRadius = 16
            switchControl.clipsToBounds = true
            switchControl.addTarget(self, action: #selector(switchValueChanged(_:)), for: .valueChanged)
            switches.append(switchControl)
            
            guard let initialSelectedWeekdays = initialSelectedWeekdays else { return }
            let isSelected = initialSelectedWeekdays.contains(day)
            switchControl.isOn = isSelected
            switchControl.sendActions(for: .valueChanged)
        }
    }
    
    @objc private func switchValueChanged(_ sender: UISwitch) {
        if let index = switches.firstIndex(of: sender) {
            let dayOfWeek = weekdays[index]
            if sender.isOn {
                selectedWeekdays.append(dayOfWeek)
                initialSelectedWeekdays?.append(dayOfWeek)
            } else {
                if let selectedWeekdaysRemove = selectedWeekdays.firstIndex(of: dayOfWeek) {
                    selectedWeekdays.remove(at: selectedWeekdaysRemove)
                }
                if let initialSelectedWeekdaysRemove = initialSelectedWeekdays?.firstIndex(of: dayOfWeek) {
                    initialSelectedWeekdays?.remove(at: initialSelectedWeekdaysRemove)
                }
            }
        }
    }
    
    @objc private func scheduleSelectedButtonTapped() {
        delegate?.didSelectWeekdays(selectedWeekdays)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - ScheduleViewController UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        weekdays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ReuseIdentifier.cell.rawValue,
            for: indexPath
        )
        
        cell.backgroundColor = AppColor.ypBackgroundColor
        if indexPath.row == 6 {
            cell.separatorInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: 0,
                right: .greatestFiniteMagnitude
            )
        }
        cell.textLabel?.text = weekdays[indexPath.row].localizedNameFull
        cell.accessoryView = switches[indexPath.row]
        return cell
    }
}

// MARK: - ScheduleViewController UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        CGFloat(75)
    }
}
