//
//  CategoryPickerTableViewController.swift
//  SpotSaver
//
//  Created by Alex Ladines on 8/4/19.
//  Copyright © 2019 Alex Ladines. All rights reserved.
//

import UIKit

protocol CategoryPickerTableViewControllerDelegate: class {
    func categoryPickerTableViewController(_ controller: CategoryPickerTableViewController, didFinishSelecting category: String)
}

class CategoryPickerTableViewController: UITableViewController {
    // MARK: - Properties
    var selectedCategoryName = ""

    let categories = [
        "No Category",
        "Apple Store",
        "Bar",
        "Bookstore",
        "Club",
        "Grocery Store",
        "Historic Building",
        "House",
        "Icecream Vendor",
        "Landmark",
        "Park"]

    var selectedIndexPath = IndexPath()
    weak var delegate: CategoryPickerTableViewControllerDelegate?

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Find the one that was selected in the beginning
        for i in 0..<categories.count {
            if categories[i] == selectedCategoryName {
                selectedIndexPath = IndexPath(row: i, section: 0)
                break
            }
        }

    }

    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Category", for: indexPath)

        let categoryName = categories[indexPath.row]
        cell.textLabel?.text = categoryName

        if categoryName == selectedCategoryName {
            cell.accessoryType = .checkmark
        }
        else {
            cell.accessoryType = .none
        }

        return cell
    }

    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .darkGray
        cell.selectedBackgroundView = backgroundView
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Check if the row tapped is the one with the checkmark
        if indexPath.row != selectedIndexPath.row {

            // Selected cell gets a checkmark
            if let newCell = tableView.cellForRow(at: indexPath) {
                newCell.accessoryType = .checkmark
            }

            if let oldCell = tableView.cellForRow(at: selectedIndexPath) {
                oldCell.accessoryType = .none
            }

            selectedIndexPath = indexPath
        }

        delegate?.categoryPickerTableViewController(self, didFinishSelecting: categories[selectedIndexPath.row])
    }
}
