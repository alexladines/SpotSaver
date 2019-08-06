//
//  DisplayLocationsTableViewController.swift
//  SpotSaver
//
//  Created by Alex Ladines on 8/6/19.
//  Copyright © 2019 Alex Ladines. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

class DisplayLocationsTableViewController: UITableViewController {
    // MARK: - Properties
    var managedContext: NSManagedObjectContext!

    // MARK: - IBOutlets

    // MARK: - IBActions

    // MARK: - Life Cycle

    // MARK: - Methods

    // MARK: - Navigation

    // MARK: - Data Persistance

    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath)
        let descriptionLabel = cell.viewWithTag(100) as! UILabel
        descriptionLabel.text = "Hello"

        let addressLabel = cell.viewWithTag(101) as! UILabel
        addressLabel.text = "It's me!"

        return cell
    }

    // MARK: - UITableViewDelegate
}
