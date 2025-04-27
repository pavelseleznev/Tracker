//
//  ColorCollectionCell.swift
//  Tracker
//
//  Created by Pavel Seleznev on 4/26/25.
//

import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    
    private let colorCollectionView: UIView = {
        let colorCollectionView = UIView()
        colorCollectionView.layer.cornerRadius = 8
        colorCollectionView.layer.masksToBounds = true
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        return colorCollectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupSubviews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(color: UIColor) {
        colorCollectionView.backgroundColor = color
    }
    
    private func setupSubviews() {
        contentView.addSubview(colorCollectionView)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            colorCollectionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorCollectionView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorCollectionView.widthAnchor.constraint(equalToConstant: 40),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
}
