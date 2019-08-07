//
//  MapViewController.swift
//  SpotSaver
//
//  Created by Alex Ladines on 8/6/19.
//  Copyright © 2019 Alex Ladines. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    // MARK: - Properties
    var managedObjectContext: NSManagedObjectContext!

    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!

    // MARK: - IBActions

    //
    @IBAction func rightBarButtonItemTapped() {
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }

    @IBAction func leftBarButtonItemTapped() {

    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Methods

    // MARK: - Navigation

    // MARK: - Data Persistance

    // MARK: - MKMapViewDelegate

}
