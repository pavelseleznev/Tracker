//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Pavel Seleznev on 6/13/25.
//

import UIKit

final class FiltersViewController: UIViewController {
    
    //MARK: - Public Properties
    var selectedFilter: Filters?
    weak var delegate: FiltersViewControllerDelegate?
    
    //MARK: - Private Properties
    private lazy var filtersTable: UITableView = {
        let filtersTable = UITableView()
        filtersTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        filtersTable.separatorStyle = .none
        filtersTable.layer.cornerRadius = 16
        filtersTable.layer.masksToBounds = true
        filtersTable.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner]
        filtersTable.translatesAutoresizingMaskIntoConstraints = false
        return filtersTable
    }()
    
    private var filtersArray: [Filters] = Filters.allCases
    private  var selectedIndexPath: IndexPath?
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        view.addSubview(filtersTable)
        filtersTable.dataSource = self
        filtersTable.delegate = self
        createNavigationBar()
        setupConstraints()
    }
    
    //MARK: - Private Functions
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            filtersTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filtersTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filtersTable.topAnchor.constraint(equalTo: view.topAnchor, constant: 80),
            filtersTable.heightAnchor.constraint(equalToConstant: 300)
        ])
    }
    
    private func createNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        navigationBar.topItem?.title = NSLocalizedString("filterButton.title", comment: "Filter button")
    }
    
    private func createSeparatorImageView(cell: UITableViewCell) {
        let separatorImageView = UIImageView()
        separatorImageView.image = UIImage(named: "BottomDivider")
        separatorImageView.tag = 100
        separatorImageView.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(separatorImageView)
        
        NSLayoutConstraint.activate([
            separatorImageView.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 16),
            separatorImageView.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -16),
            separatorImageView.bottomAnchor.constraint(equalTo: cell.bottomAnchor),
            separatorImageView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}

// MARK: - FiltersViewController UITableViewDataSource
extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filtersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = AppColor.ypBackgroundColor
        cell.selectionStyle = .none
        
        let filterKey = filtersArray[indexPath.row].rawValue
        cell.textLabel?.text = NSLocalizedString(filterKey, comment: "Filter name for \(filterKey)")
        
        cell.accessoryView = nil
        if filtersArray[indexPath.row] == selectedFilter {
            selectedIndexPath = indexPath
            let checkmarkImageView = UIImageView(image: UIImage(named: "DoneImage"))
            cell.accessoryView = checkmarkImageView
        }
        cell.viewWithTag(100)?.removeFromSuperview()
        if indexPath.row != filtersArray.count - 1 {
            createSeparatorImageView(cell: cell)
        }
        return cell
    }
}

// MARK: - FiltersViewController UITableViewDelegate
extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedFilter = selectedFilter, selectedFilter != filtersArray[indexPath.row] {
            let lastIndexPath = filtersArray.firstIndex(of: selectedFilter)
            tableView.cellForRow(at: IndexPath(row: lastIndexPath ?? 0, section: 0))?.accessoryView = nil
            self.selectedFilter = filtersArray[indexPath.row]
            let checkmarkImageView = UIImageView(image: UIImage(named: "DoneImage"))
            tableView.cellForRow(at: indexPath)?.accessoryView = checkmarkImageView
            UserDefaults.standard.set(self.selectedFilter?.rawValue, forKey: selectedFilter.rawValue)
        }
        delegate?.useSelectedFilter(selectedFilter: self.selectedFilter ?? Filters.allTrackers)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        CGFloat(75)
    }
}

protocol FiltersViewControllerDelegate: AnyObject {
    func useSelectedFilter(selectedFilter: Filters)
}
