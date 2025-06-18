//
//  ExtensionString.swift
//  Tracker
//
//  Created by Pavel Seleznev on 6/11/25.
//

import Foundation

extension String {
    func NSLocalizedString(
        _ key: String,
        tableName: String? = nil,
        bundle: Bundle = Bundle.main,
        value: String = "",
        comment: String
    ) -> String {
        return Foundation.NSLocalizedString(
            key,
            tableName: tableName,
            bundle: bundle,
            value: value,
            comment: comment
        )
    }
}
