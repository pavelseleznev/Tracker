//
//  FiltersCell.swift
//  Tracker
//
//  Created by Pavel Seleznev on 6/13/25.
//

import UIKit

final class FiltersCell: UITableViewCell {
    
    //MARK: - Properties
    private let filterTitle: UILabel = {
        let filterTitle = UILabel()
        filterTitle.textColor = AppColor.ypBlack
        filterTitle.font = .systemFont(ofSize: 17, weight: .regular)
        return filterTitle
    }()
    
    private let checkmarkImage: UIImageView = {
        let checkmarkImage = UIImageView(image: UIImage(named: "DoneImage")?.withRenderingMode(.alwaysOriginal))
        checkmarkImage.isHidden = true
        return checkmarkImage
    }()
    
    private let separatorImage: UIImageView = {
        let separatorImage = UIImageView()
        separatorImage.image = UIImage(named: "BottomDivider")
        return separatorImage
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = AppColor.ypBackgroundColor
        setupSubviews()
        setupConstraints()
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -  Methods
    private func setupSubviews() {
        contentView.addSubview(filterTitle)
        [filterTitle, checkmarkImage, separatorImage].forEach {
            contentView.addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            filterTitle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            filterTitle.heightAnchor.constraint(equalToConstant: 24),
            filterTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            filterTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            checkmarkImage.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkImage.heightAnchor.constraint(equalToConstant: 24),
            checkmarkImage.widthAnchor.constraint(equalToConstant: 24),
            checkmarkImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            separatorImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            separatorImage.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    func configure(text: String) {
        filterTitle.text = text
    }
    
    func setCheckmarkVisible(_ visible: Bool) {
        checkmarkImage.isHidden = !visible
    }
    
    func hideSeparatorImageView() {
        separatorImage.isHidden = true
    }
}
