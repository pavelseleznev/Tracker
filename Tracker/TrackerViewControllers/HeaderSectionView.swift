//
//  HeaderSectionView.swift
//  Tracker
//
//  Created by Pavel Seleznev on 4/12/25.
//

import UIKit

final class HeaderSectionView: UICollectionReusableView {
    
    let headerSectionLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        headerSectionLabel.font = .systemFont(ofSize: 19, weight: .bold)
        headerSectionLabel.textAlignment = .left
        headerSectionLabel.textColor = AppColor.ypBlack
        headerSectionLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(headerSectionLabel)
        
        NSLayoutConstraint.activate([
            headerSectionLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            headerSectionLabel.topAnchor.constraint(equalTo: topAnchor),
            headerSectionLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
