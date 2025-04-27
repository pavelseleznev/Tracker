//
//  EmojiCollectionViewCell.swift
//  Tracker
//
//  Created by Pavel Seleznev on 4/20/25.
//

import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    
    private let emojiCollectionCellLabel: UILabel = {
        let emojiCellLabel = UILabel()
        emojiCellLabel.font = .systemFont(ofSize: 32, weight: .bold)
        emojiCellLabel.textAlignment = .center
        emojiCellLabel.translatesAutoresizingMaskIntoConstraints = false
        return emojiCellLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(emoji: String) {
        emojiCollectionCellLabel.text = emoji
    }
    
    private func setupSubviews() {
        contentView.addSubview(emojiCollectionCellLabel)
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 16
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            emojiCollectionCellLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiCollectionCellLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            emojiCollectionCellLabel.widthAnchor.constraint(equalToConstant: 32),
            emojiCollectionCellLabel.heightAnchor.constraint(equalToConstant: 38)
        ])
    }
}
