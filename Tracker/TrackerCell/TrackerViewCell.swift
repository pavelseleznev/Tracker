//
//  TrackerViewCell.swift
//  Tracker
//
//  Created by Pavel Seleznev on 4/10/25.
//

import UIKit

final class TrackerViewCell: UICollectionViewCell {
    
    private let trackerViewCell: UIView = {
        let trackerViewCell = UIView()
        trackerViewCell.layer.cornerRadius = 16
        trackerViewCell.translatesAutoresizingMaskIntoConstraints = false
        return trackerViewCell
    }()
    
    private let viewCellLabel: UILabel = {
        let viewCellLabel = UILabel()
        viewCellLabel.font = .systemFont(ofSize: 12, weight: .medium)
        viewCellLabel.numberOfLines = 0
        viewCellLabel.textColor = AppColor.ypWhite
        viewCellLabel.translatesAutoresizingMaskIntoConstraints = false
        return viewCellLabel
    }()
    
    private let viewCellEmoji: UILabel = {
        let viewCellEmoji = UILabel()
        
        viewCellEmoji.font = .systemFont(ofSize: 16, weight: .medium)
        viewCellEmoji.layer.cornerRadius = 12
        viewCellEmoji.textAlignment = .center
        viewCellEmoji.clipsToBounds = true
        viewCellEmoji.backgroundColor = .ypWhite.withAlphaComponent(0.3)
        viewCellEmoji.translatesAutoresizingMaskIntoConstraints = false
        return viewCellEmoji
    }()
    
    private lazy var viewCellPlusButton: UIButton = {
        let viewCellPlusButton = UIButton(type: .system)
        let pointSize = UIImage.SymbolConfiguration(pointSize: 11)
        let image = UIImage(systemName: "plus")
        viewCellPlusButton.setImage(image, for: .normal)
        viewCellPlusButton.layer.cornerRadius = 17
        viewCellPlusButton.clipsToBounds = true
        viewCellPlusButton.tintColor = AppColor.ypWhite
        viewCellPlusButton.translatesAutoresizingMaskIntoConstraints = false
        viewCellPlusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        return viewCellPlusButton
    }()
    
    private let viewCellPlusImage: UIImage = {
        let pointSize = UIImage.SymbolConfiguration(pointSize: 11)
        let image = UIImage(systemName: "plus", withConfiguration: pointSize)
        return image ?? UIImage()
    }()
    
    private let viewCellDayCounter: UILabel = {
        let viewCellDayCounter = UILabel()
        viewCellDayCounter.textColor = AppColor.ypBlack
        viewCellDayCounter.text = "0 дней"
        viewCellDayCounter.font = .systemFont(ofSize: 12, weight: .medium)
        viewCellDayCounter.textAlignment = .left
        viewCellDayCounter.translatesAutoresizingMaskIntoConstraints = false
        return viewCellDayCounter
    }()
    
    private let doneImage = UIImage(named: "DoneImage")
    private var isCompletedToday: Bool = false
    private var trackerID: UUID?
    private var indexPath: IndexPath?
    weak var delegate: TrackerCellDelegate?
    
    func configure(with tracker: Tracker, isCompletedToday: Bool, completedDays: Int, indexPath: IndexPath) {
        self.trackerID = tracker.trackerID
        self.isCompletedToday = isCompletedToday
        self.indexPath = indexPath
        
        trackerViewCell.backgroundColor = tracker.trackerColor
        viewCellPlusButton.backgroundColor = tracker.trackerColor
        
        viewCellLabel.text = tracker.trackerName
        viewCellEmoji.text = tracker.trackerEmoji
        let image = isCompletedToday ? doneImage : viewCellPlusImage
        viewCellPlusButton.setImage(image, for: .normal)
        viewCellPlusButton.alpha = isCompletedToday ? 0.3 : 1.0
        viewCellDayCounter.text = completedDays.days()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        contentView.addSubview(trackerViewCell)
        contentView.addSubview(viewCellLabel)
        contentView.addSubview(viewCellEmoji)
        contentView.addSubview(viewCellPlusButton)
        contentView.addSubview(viewCellDayCounter)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            trackerViewCell.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerViewCell.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerViewCell.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            trackerViewCell.heightAnchor.constraint(equalToConstant: 90),
            
            viewCellLabel.leadingAnchor.constraint(equalTo: trackerViewCell.leadingAnchor, constant: 12),
            viewCellLabel.trailingAnchor.constraint(equalTo: trackerViewCell.trailingAnchor, constant: -12),
            viewCellLabel.bottomAnchor.constraint(equalTo: trackerViewCell.bottomAnchor, constant: -12),
            
            viewCellEmoji.topAnchor.constraint(equalTo: trackerViewCell.topAnchor, constant: 12),
            viewCellEmoji.leadingAnchor.constraint(equalTo: trackerViewCell.leadingAnchor, constant: 12),
            viewCellEmoji.widthAnchor.constraint(equalToConstant: 24),
            viewCellEmoji.heightAnchor.constraint(equalToConstant: 24),
            
            viewCellPlusButton.topAnchor.constraint(equalTo: trackerViewCell.bottomAnchor, constant: 8),
            viewCellPlusButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            viewCellPlusButton.widthAnchor.constraint(equalToConstant: 34),
            viewCellPlusButton.heightAnchor.constraint(equalToConstant: 34),
            
            viewCellDayCounter.topAnchor.constraint(equalTo: trackerViewCell.bottomAnchor, constant: 16),
            viewCellDayCounter.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            viewCellDayCounter.widthAnchor.constraint(equalToConstant: 101),
            viewCellDayCounter.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    @objc private func plusButtonTapped() {
        guard let trackerID = trackerID,
              let indexPath = indexPath
        else {
            assertionFailure("[plusButtonTapped]: Error trackerID not found")
            return
        }
        delegate?.completeTracker(id: trackerID, at: indexPath)
    }
}

protocol TrackerCellDelegate: AnyObject {
    func completeTracker(id: UUID, at indexPath: IndexPath)
}
