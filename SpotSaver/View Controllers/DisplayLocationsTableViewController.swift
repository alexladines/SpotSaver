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
    var managedObjectContext: NSManagedObjectContext!
    var locations = [Location]()

    // MARK: - IBOutlets

    // MARK: - IBActions

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create request with object I want
        let fetchRequest = NSFetchRequest<Location>()

        // Looking for Location Entities
        let entity = Location.entity()
        fetchRequest.entity = entity

        // Sort on the date, dates added first will appear first.
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        do {
            // .fetch gives back an array
            locations = try managedObjectContext.fetch(fetchRequest)
        }
        catch {
            fatalCoreDataError(error)
        }

    }

    // MARK: - Methods

    // MARK: - Navigation

    // MARK: - Data Persistance

    // MARK: - UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LocationCell", for: indexPath) as! DisplayLocationTableViewCell

        let location = locations[indexPath.row]
        
        cell.configure(for: location)

        return cell
    }

    // MARK: - UITableViewDelegate
}
