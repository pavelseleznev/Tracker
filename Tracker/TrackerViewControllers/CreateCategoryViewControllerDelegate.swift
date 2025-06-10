//
//  CreateCategoryViewControllerDelegate.swift
//  Tracker
//
//  Created by Pavel Seleznev on 6/4/25.
//

import Foundation

protocol CreateCategoryViewControllerDelegate: AnyObject {
    func addNewCategory(newCategory: String)
}
