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
    
    private let colorCellLayerView: UIView = {
        let colorCellLayerView = UIView()
        colorCellLayerView.layer.cornerRadius = 8
        colorCellLayerView.layer.borderWidth = 3
        colorCellLayerView.layer.masksToBounds = true
        colorCellLayerView.translatesAutoresizingMaskIntoConstraints = false
        colorCellLayerView.isHidden = true
        return colorCellLayerView
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
        colorCellLayerView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
    }
    
    func showColorCellLayerView(isVisible: Bool) {
        colorCellLayerView.isHidden = !isVisible
    }
    
    private func setupSubviews() {
        contentView.addSubview(colorCollectionView)
        contentView.addSubview(colorCellLayerView)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            colorCollectionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorCollectionView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorCollectionView.widthAnchor.constraint(equalToConstant: 40),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 40),
            
            colorCellLayerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorCellLayerView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorCellLayerView.widthAnchor.constraint(equalToConstant: 52),
            colorCellLayerView.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
}
