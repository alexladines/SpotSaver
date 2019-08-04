//
//  LocationDetailsTableViewController.swift
//  SpotSaver
//
//  Created by Alex Ladines on 8/3/19.
//  Copyright © 2019 Alex Ladines. All rights reserved.
//

import UIKit
import CoreLocation

// lazy creation to not use too mucb battery
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

class LocationDetailsTableViewController: UITableViewController, CategoryPickerTableViewControllerDelegate {

    // MARK: - Properties
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    var categoryName = "No Category"

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
    override func viewDidLoad() {
        super.viewDidLoad()

        descriptionTextView.text = ""
        categoryLabel.text = ""

        latitudeLabel.text = String(format: "%.8f", coordinate.latitude)
        longitudeLabel.text = String(format: "%.8f", coordinate.longitude)

        if let placemark = placemark {
            addressLabel.text = string(from: placemark)
        }
        else {
            addressLabel.text = "No Address Found"
        }

        categoryLabel.text = categoryName
        print(categoryLabel.text!)
        print(categoryName)

        dateLabel.text = format(date: Date())
    }

    // MARK: - Methods
    func string(from placemark: CLPlacemark) -> String {
        var text = ""
        if let s = placemark.subThoroughfare {
            text += s + " "
        }
        if let s = placemark.thoroughfare {
            text += s + ", "
        }
        if let s = placemark.locality {
            text += s + ", "
        }
        if let s = placemark.administrativeArea {
            text += s + " "
        }
        if let s = placemark.postalCode {
            text += s + ", "
        }
        if let s = placemark.country {
            text += s
        }
        return text
    }

    func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let vc = segue.destination as! CategoryPickerTableViewController
            vc.selectedCategoryName = categoryName
            vc.delegate = self
        }
    }

    // MARK: - Data Persistance

    // MARK: - UITableViewDataSource

    // MARK: - UITableViewDelegate

    // MARK: - CategoryPickerTableViewControllerDelegate
    func categoryPickerTableViewController(_ controller: CategoryPickerTableViewController, didFinishSelecting category: String) {
        categoryName = category
        categoryLabel.text = categoryName
        navigationController?.popViewController(animated: true)
    }
}
