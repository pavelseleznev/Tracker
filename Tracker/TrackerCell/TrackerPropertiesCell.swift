//
//  TrackerPropertiesCell.swift
//  Tracker
//
//  Created by Pavel Seleznev on 4/12/25.
//

import UIKit

final class TrackerPropertiesCell: UITableViewCell {
    
    weak var delegate: TrackerPropertiesCellDelegate?
    private var indexPath: IndexPath?
    private let properties = ["Категория", "Расписание"]
    
    private lazy var categoryAndScheduleLabels: UILabel = {
        let propertiesTitleLabel = UILabel()
        propertiesTitleLabel.font = .systemFont(ofSize: 17, weight: .regular)
        propertiesTitleLabel.textColor = AppColor.ypBlack
        propertiesTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        return propertiesTitleLabel
    }()
    
    private lazy var selectedScheduleDays: UILabel = {
        let detailsLabel = UILabel()
        detailsLabel.font = .systemFont(ofSize: 17, weight: .regular)
        detailsLabel.textColor = AppColor.ypGray
        detailsLabel.translatesAutoresizingMaskIntoConstraints = false
        return detailsLabel
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var detailsButton: UIButton = {
        let nextButton = UIButton(type: .custom)
        nextButton.setImage(UIImage(named: "Chevron"), for: .normal)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        nextButton.addTarget(self, action: #selector(trackerDetailsButtonTapped), for: .touchUpInside)
        return nextButton
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(indexPath: IndexPath) {
        self.indexPath = indexPath
        categoryAndScheduleLabels.text = properties[indexPath.row]
    }
    
    func setup(detailsText: String?) {
        selectedScheduleDays.text = detailsText
        selectedScheduleDays.isHidden = detailsText == nil
    }
    
    private func setupSubviews() {
        stackView.addArrangedSubview(categoryAndScheduleLabels)
        stackView.addArrangedSubview(selectedScheduleDays)
        contentView.addSubview(stackView)
        contentView.addSubview(detailsButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -46),
            stackView.heightAnchor.constraint(equalToConstant: 45),
            
            detailsButton.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            detailsButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            detailsButton.widthAnchor.constraint(equalToConstant: 46),
            detailsButton.heightAnchor.constraint(equalToConstant: 46)
        ])
    }
    
    @objc private func trackerDetailsButtonTapped(_ sender: UIButton) {
        guard let indexPath = indexPath else { return }
        delegate?.trackerDetailsButtonTapped(at: indexPath)
    }
}

protocol TrackerPropertiesCellDelegate: AnyObject {
    func trackerDetailsButtonTapped(at indexPath: IndexPath)
}
