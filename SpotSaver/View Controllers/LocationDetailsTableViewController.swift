//
//  LocationDetailsTableViewController.swift
//  SpotSaver
//
//  Created by Alex Ladines on 8/3/19.
//  Copyright © 2019 Alex Ladines. All rights reserved.
//

import UIKit
import CoreLocation

class LocationDetailsTableViewController: UITableViewController {
    // MARK: - Properties
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?

    // MARK: - IBOutlets
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    // MARK: - IBActions

    @IBAction func doneBarButtonItemPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func cancelBarButtonItemPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Life Cycle

    // MARK: - Methods

    // MARK: - Navigation

    // MARK: - Data Persistance

    // MARK: - UITableViewDataSource

    // MARK: - UITableViewDelegate
}
