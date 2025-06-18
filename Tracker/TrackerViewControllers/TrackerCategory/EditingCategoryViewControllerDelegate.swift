//
//  EditingCategoryViewControllerDelegate.swift
//  Tracker
//
//  Created by Pavel Seleznev on 6/4/25.
//

import Foundation

protocol EditingCategoryViewControllerDelegate: AnyObject {
    func didUpdateCategory(at index: Int, with newCategory: String)
}
