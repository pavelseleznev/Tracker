//
//  ListOfCategoriesDelegate.swift
//  Tracker
//
//  Created by Pavel Seleznev on 6/4/25.
//

import Foundation

protocol ListOfCategoriesDelegate: AnyObject {
    func didSelectCategory(_ category: String)
}
