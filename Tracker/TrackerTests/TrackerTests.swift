//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Pavel Seleznev on 6/13/25.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testViewController() {
        let viewModel = TrackerViewModel()
        let trackersViewController = TrackersViewController(viewModel: viewModel)
        viewModel.updateCategories(with: Date(), text: "", completedFilter: nil)
        trackersViewController.trackersCollectionView.reloadData()
        assertSnapshot(of: trackersViewController, as: .image(traits: .init(userInterfaceStyle: .light)))
    }
}
