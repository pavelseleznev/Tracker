//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Pavel Seleznev on 3/28/25.
//

import UIKit

final class StatisticsViewController: UIViewController {
    
    // MARK: Private Properties
    private var bestPeriod = 0
    private var idealDays = 0
    private var trackersCompleted = 0
    private var averageScore = 0
    private let trackerRecordStore = TrackerRecordStore()
    
    private lazy var placeholderImageView: UIImageView = {
        let placeholderImage = UIImage(named: "StatPlaceholder")
        let placeholderImageView = UIImageView(image: placeholderImage)
        placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
        return placeholderImageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let placeholderLabel = UILabel()
        placeholderLabel.text = NSLocalizedString("placeholderLabelStat", comment: "Placeholder stat label")
        placeholderLabel.font = .systemFont(ofSize: 12, weight: .medium)
        placeholderLabel.textAlignment = .center
        placeholderLabel.textColor = AppColor.ypBlack
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        return placeholderLabel
    }()
    
    private lazy var navigationBar: UINavigationBar = {
        let navigationBar = navigationController?.navigationBar ?? UINavigationBar()
        navigationBar.topItem?.title = NSLocalizedString("statistics.title", comment: "Statistics title")
        navigationBar.prefersLargeTitles = true
        navigationBar.topItem?.largeTitleDisplayMode = .always
        return navigationBar
    }()
    
    private let fistGradientImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Gradient")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let bestPeriodNumberLabel: UILabel = {
        let bestPeriodNumberLabel = UILabel()
        bestPeriodNumberLabel.text = "0"
        bestPeriodNumberLabel.textColor = AppColor.ypBlack
        bestPeriodNumberLabel.font = .systemFont(ofSize: 34, weight: .bold)
        bestPeriodNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        return bestPeriodNumberLabel
    }()
    
    private let bestPeriodTextLabel: UILabel = {
        let bestPeriodTextLabel = UILabel()
        bestPeriodTextLabel.text = NSLocalizedString("bestPeriod", comment: "Best period title")
        bestPeriodTextLabel.textColor = AppColor.ypBlack
        bestPeriodTextLabel.font = .systemFont(ofSize: 12, weight: .medium)
        bestPeriodTextLabel.translatesAutoresizingMaskIntoConstraints = false
        return bestPeriodTextLabel
    }()
    
    private let secondGradientImageView: UIImageView = {
        let secondGradientImageView = UIImageView()
        secondGradientImageView.image = UIImage(named: "Gradient")
        secondGradientImageView.translatesAutoresizingMaskIntoConstraints = false
        return secondGradientImageView
    }()
    
    private let idealDaysNumberLabel: UILabel = {
        let idealDaysNumberLabel = UILabel()
        idealDaysNumberLabel.text = "0"
        idealDaysNumberLabel.textColor = .ypBlack
        idealDaysNumberLabel.font = .systemFont(ofSize: 34, weight: .bold)
        idealDaysNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        return idealDaysNumberLabel
    }()
    
    private let idealDaysTextLabel: UILabel = {
        let idealDaysTextLabel = UILabel()
        idealDaysTextLabel.text = NSLocalizedString("idealDays", comment: "Ideal days title")
        idealDaysTextLabel.textColor = AppColor.ypBlack
        idealDaysTextLabel.font = .systemFont(ofSize: 12, weight: .medium)
        idealDaysTextLabel.translatesAutoresizingMaskIntoConstraints = false
        return idealDaysTextLabel
    }()
    
    private let thirdGradientImageView: UIImageView = {
        let thirdGradientImageView = UIImageView()
        thirdGradientImageView.image = UIImage(named: "Gradient")
        thirdGradientImageView.translatesAutoresizingMaskIntoConstraints = false
        return thirdGradientImageView
    }()
    
    private let trackersCompletedNumberLabel: UILabel = {
        let trackersCompletedNumberLabel = UILabel()
        trackersCompletedNumberLabel.text = "0"
        trackersCompletedNumberLabel.textColor = AppColor.ypBlack
        trackersCompletedNumberLabel.font = .systemFont(ofSize: 34, weight: .bold)
        trackersCompletedNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        return trackersCompletedNumberLabel
    }()
    
    private let trackersCompletedTextLabel: UILabel = {
        let trackersCompletedTextLabel = UILabel()
        trackersCompletedTextLabel.text = NSLocalizedString("trackersCompleted", comment: "Tracker completed title")
        trackersCompletedTextLabel.textColor = AppColor.ypBlack
        trackersCompletedTextLabel.font = .systemFont(ofSize: 12, weight: .medium)
        trackersCompletedTextLabel.translatesAutoresizingMaskIntoConstraints = false
        return trackersCompletedTextLabel
    }()
    
    private let fourthGradient: UIImageView = {
        let fourthGradient = UIImageView()
        fourthGradient.image = UIImage(named: "Gradient")
        fourthGradient.translatesAutoresizingMaskIntoConstraints = false
        return fourthGradient
    }()
    
    private let averageValueNumber: UILabel = {
        let averageValueNumber = UILabel()
        averageValueNumber.text = "0"
        averageValueNumber.textColor = AppColor.ypBlack
        averageValueNumber.font = .systemFont(ofSize: 34, weight: .bold)
        averageValueNumber.translatesAutoresizingMaskIntoConstraints = false
        return averageValueNumber
    }()
    
    private let averageValue: UILabel = {
        let averageValue = UILabel()
        averageValue.text = NSLocalizedString("averageScore", comment: "Average score label")
        averageValue.textColor = AppColor.ypBlack
        averageValue.font = .systemFont(ofSize: 12, weight: .medium)
        averageValue.translatesAutoresizingMaskIntoConstraints = false
        return averageValue
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.ypWhite
        
        setupSubviews()
        setupConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        calculateTrackerStat()
        updatePlaceholder()
        showStatistics()
    }
    
    // MARK: Private Methods
    private func setupSubviews(){
        view.addSubview(placeholderImageView)
        view.addSubview(placeholderLabel)
        view.addSubview(navigationBar)
        
        view.addSubview(fistGradientImageView)
        fistGradientImageView.addSubview(bestPeriodNumberLabel)
        fistGradientImageView.addSubview(bestPeriodTextLabel)
        
        view.addSubview(secondGradientImageView)
        secondGradientImageView.addSubview(idealDaysNumberLabel)
        secondGradientImageView.addSubview(idealDaysTextLabel)
        
        view.addSubview(thirdGradientImageView)
        thirdGradientImageView.addSubview(trackersCompletedNumberLabel)
        thirdGradientImageView.addSubview(trackersCompletedTextLabel)
        
        view.addSubview(fourthGradient)
        fourthGradient.addSubview(averageValueNumber)
        fourthGradient.addSubview(averageValue)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8),
            placeholderLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16),
            placeholderLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16),
            placeholderLabel.heightAnchor.constraint(equalToConstant: 18),
            
            fistGradientImageView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor, constant: 64),
            fistGradientImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            fistGradientImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            fistGradientImageView.heightAnchor.constraint(equalToConstant: 90),
            
            bestPeriodNumberLabel.topAnchor.constraint(equalTo: fistGradientImageView.topAnchor, constant: 12),
            bestPeriodNumberLabel.leadingAnchor.constraint(equalTo: fistGradientImageView.leadingAnchor, constant: 12),
            bestPeriodNumberLabel.trailingAnchor.constraint(equalTo: fistGradientImageView.trailingAnchor, constant: -12),
            bestPeriodNumberLabel.heightAnchor.constraint(equalToConstant: 41),
            
            bestPeriodTextLabel.leadingAnchor.constraint(equalTo: fistGradientImageView.leadingAnchor, constant: 12),
            bestPeriodTextLabel.trailingAnchor.constraint(equalTo: fistGradientImageView.trailingAnchor, constant: -12),
            bestPeriodTextLabel.heightAnchor.constraint(equalToConstant: 18),
            bestPeriodTextLabel.bottomAnchor.constraint(equalTo: fistGradientImageView.bottomAnchor, constant: -12),
            
            secondGradientImageView.topAnchor.constraint(equalTo: fistGradientImageView.bottomAnchor, constant: 12),
            secondGradientImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            secondGradientImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            secondGradientImageView.heightAnchor.constraint(equalToConstant: 90),
            
            idealDaysNumberLabel.topAnchor.constraint(equalTo: secondGradientImageView.topAnchor, constant: 12),
            idealDaysNumberLabel.leadingAnchor.constraint(equalTo: secondGradientImageView.leadingAnchor, constant: 12),
            idealDaysNumberLabel.trailingAnchor.constraint(equalTo: secondGradientImageView.trailingAnchor, constant: -12),
            idealDaysNumberLabel.heightAnchor.constraint(equalToConstant: 41),
            
            idealDaysTextLabel.leadingAnchor.constraint(equalTo: secondGradientImageView.leadingAnchor, constant: 12),
            idealDaysTextLabel.trailingAnchor.constraint(equalTo: secondGradientImageView.trailingAnchor, constant: -12),
            idealDaysTextLabel.heightAnchor.constraint(equalToConstant: 18),
            idealDaysTextLabel.bottomAnchor.constraint(equalTo: secondGradientImageView.bottomAnchor, constant: -12),
            
            thirdGradientImageView.topAnchor.constraint(equalTo: secondGradientImageView.bottomAnchor, constant: 12),
            thirdGradientImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            thirdGradientImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            thirdGradientImageView.heightAnchor.constraint(equalToConstant: 90),
            
            trackersCompletedNumberLabel.topAnchor.constraint(equalTo: thirdGradientImageView.topAnchor, constant: 12),
            trackersCompletedNumberLabel.leadingAnchor.constraint(equalTo: thirdGradientImageView.leadingAnchor, constant: 12),
            trackersCompletedNumberLabel.trailingAnchor.constraint(equalTo: thirdGradientImageView.trailingAnchor, constant: -12),
            trackersCompletedNumberLabel.heightAnchor.constraint(equalToConstant: 41),
            
            trackersCompletedTextLabel.leadingAnchor.constraint(equalTo: thirdGradientImageView.leadingAnchor, constant: 12),
            trackersCompletedTextLabel.trailingAnchor.constraint(equalTo: thirdGradientImageView.trailingAnchor, constant: -12),
            trackersCompletedTextLabel.heightAnchor.constraint(equalToConstant: 18),
            trackersCompletedTextLabel.bottomAnchor.constraint(equalTo: thirdGradientImageView.bottomAnchor, constant: -12),
            
            fourthGradient.topAnchor.constraint(equalTo: thirdGradientImageView.bottomAnchor, constant: 12),
            fourthGradient.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            fourthGradient.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            fourthGradient.heightAnchor.constraint(equalToConstant: 90),
            
            averageValueNumber.topAnchor.constraint(equalTo: fourthGradient.topAnchor, constant: 12),
            averageValueNumber.leadingAnchor.constraint(equalTo: fourthGradient.leadingAnchor, constant: 12),
            averageValueNumber.trailingAnchor.constraint(equalTo: fourthGradient.trailingAnchor, constant: -12),
            averageValueNumber.heightAnchor.constraint(equalToConstant: 41),
            
            
            averageValue.leadingAnchor.constraint(equalTo: fourthGradient.leadingAnchor, constant: 12),
            averageValue.trailingAnchor.constraint(equalTo: fourthGradient.trailingAnchor, constant: -12),
            averageValue.heightAnchor.constraint(equalToConstant: 18),
            averageValue.bottomAnchor.constraint(equalTo: fourthGradient.bottomAnchor, constant: -12)
        ])
    }
    
    private func updatePlaceholder() {
        if trackersCompleted == 0 {
            fistGradientImageView.isHidden = true
            secondGradientImageView.isHidden = true
            thirdGradientImageView.isHidden = true
            fourthGradient.isHidden = true
            placeholderLabel.isHidden = false
            placeholderImageView.isHidden = false
        } else {
            fistGradientImageView.isHidden = false
            secondGradientImageView.isHidden = false
            thirdGradientImageView.isHidden = false
            fourthGradient.isHidden = false
            placeholderLabel.isHidden = true
            placeholderImageView.isHidden = true
        }
    }
    
    private func calculateTrackerStat() {
        (bestPeriod, idealDays, trackersCompleted) = (0, 0, 0)
        var weekdaysCount: [Int: Int] = [:]
        var completedCount: [Date: Int] = [:]
        var eventArray: [Date] = []
        var currentBestPeriod = 0
        let calendar = Calendar.current
        
        guard
            let allTrackers = try? trackerRecordStore.fetchAllTrackers(),
            let startDate = try? trackerRecordStore.fetchInitialDate()
        else { return }
        
        for tracker in allTrackers {
            if !tracker.completedAt.isEmpty {
                trackersCompleted += 1
                for date in tracker.completedAt {
                    completedCount[date, default: 0] += 1
                }
            }
            if !tracker.schedule.isEmpty {
                for weekday in tracker.schedule {
                    guard let weekdayNumber = weekday?.numberValue else { return }
                    weekdaysCount[weekdayNumber, default: 0] += 1
                }
            } else {
                eventArray.append(tracker.dateEvent ?? startDate - 1)
            }
        }
        
        averageScore = Int(Double((completedCount.reduce(0) { $0 + $1.value } / completedCount.count)).rounded())
        
        let endDay = Date().createDateForTracker()
        var currentDate = startDate
        guard let endDay = endDay else { return }
        
        while currentDate <= endDay {
            let filterWeekday = calendar.component(.weekday, from: currentDate)
            let allHabitNumber = weekdaysCount[filterWeekday] ?? 0
            let allEventNumber = eventArray.filter { $0 == currentDate }.count
            
            if completedCount[currentDate] == allHabitNumber + allEventNumber {
                idealDays += 1
                currentBestPeriod += 1
            } else {
                if currentBestPeriod > bestPeriod {
                    bestPeriod = currentBestPeriod
                }
                currentBestPeriod = 0
            }
            
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        
        if currentBestPeriod > bestPeriod {
            bestPeriod = currentBestPeriod
        }
    }
    
    private func showStatistics() {
        bestPeriodNumberLabel.text = "\(bestPeriod)"
        idealDaysNumberLabel.text = "\(idealDays)"
        trackersCompletedNumberLabel.text = "\(trackersCompleted)"
        averageValueNumber.text = "\(averageScore)"
    }
}
