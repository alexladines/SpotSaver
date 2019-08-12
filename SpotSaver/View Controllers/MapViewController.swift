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
    var managedObjectContext: NSManagedObjectContext! {
        didSet {
            // Update whenever a change to the data store is made
            NotificationCenter.default.addObserver(forName: Notification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext, queue: OperationQueue.main) { _ in
                // Will not scale if too many items
                if self.isViewLoaded {
                    self.updateLocations()
                }
            }
        }
    }

    var locations = [Location]()

    // MARK: - IBOutlets
    @IBOutlet weak var mapView: MKMapView!

    // MARK: - IBActions

    // Titled - User
    @IBAction func rightBarButtonItemTapped() {
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }

    // Titled - Locations
    @IBAction func leftBarButtonItemTapped() {
        let theRegion = region(for: locations)
        mapView.setRegion(theRegion, animated: true)
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLocations()
        mapView.delegate = self

        if !locations.isEmpty {
            leftBarButtonItemTapped()
        }
    }

    // MARK: - Methods
    func updateLocations() {
        mapView.removeAnnotations(locations)

        let entity = Location.entity()
        let fetchRequest = NSFetchRequest<Location>()
        fetchRequest.entity = entity

        locations = try! managedObjectContext.fetch(fetchRequest)
        mapView.addAnnotations(locations)
    }

    func region(for annotations: [MKAnnotation]) -> MKCoordinateRegion {
        let region: MKCoordinateRegion

        switch annotations.count {
        // No saved Locations
        case 0:
            region = MKCoordinateRegion(
                center: mapView.userLocation.coordinate,
                latitudinalMeters: 1000, longitudinalMeters: 1000)
        // Zoom in on map for 1 annotation
        case 1:
            let annotation = annotations[annotations.count - 1]
            region = MKCoordinateRegion(
                center: annotation.coordinate,
                latitudinalMeters: 1000, longitudinalMeters: 1000)
        // Get all annotations in one view
        default:
            var topLeft = CLLocationCoordinate2D(latitude: -90,
                                                 longitude: 180)
            var bottomRight = CLLocationCoordinate2D(latitude: 90,
                                                     longitude: -180)
            for annotation in annotations {
                topLeft.latitude = max(topLeft.latitude, annotation.coordinate.latitude)
                topLeft.longitude = min(topLeft.longitude,
                                        annotation.coordinate.longitude)
                bottomRight.latitude = min(bottomRight.latitude,
                                           annotation.coordinate.latitude)
                bottomRight.longitude = max(bottomRight.longitude,
                                            annotation.coordinate.longitude)
            }
            let center = CLLocationCoordinate2D(latitude: topLeft.latitude -
                    (topLeft.latitude - bottomRight.latitude) / 2,
                longitude: topLeft.longitude -
                    (topLeft.longitude - bottomRight.longitude) / 2)
            let extraSpace = 1.1
            let span = MKCoordinateSpan(latitudeDelta: abs(topLeft.latitude -
                    bottomRight.latitude) * extraSpace,
                longitudeDelta: abs(topLeft.longitude -
                    bottomRight.longitude) * extraSpace)
            region = MKCoordinateRegion(center: center, span: span)
        }
        return mapView.regionThatFits(region)

    }

    @objc func showLocationDetails(_ sender: UIButton) {
        performSegue(withIdentifier: "EditLocation", sender: sender)
    }


    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditLocation" {
            let vc = segue.destination as! LocationDetailsTableViewController
            vc.managedObjectContext = managedObjectContext

            let button = sender as! UIButton
            let location = locations[button.tag]
            vc.locationToEdit = location
        }
    }

    // MARK: - Data Persistance

    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 1 Only make annotations for locations, not the blue location dot
        guard annotation is Location else {
            return nil
        }

        // 2 Dequeue an annotation
        let identifier = "Location"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)

            // 3 Set some of the properties
            pinView.isEnabled = true
            pinView.canShowCallout = true
            pinView.animatesDrop = false
            pinView.pinTintColor = .black
            pinView.tintColor = UIColor(white: 0.0, alpha: 0.5)

            // 4 Add target-action
            let rightButton = UIButton(type: .detailDisclosure)
            rightButton.addTarget(self, action: #selector(showLocationDetails(_:)), for: .touchUpInside)
            pinView.rightCalloutAccessoryView = rightButton

            annotationView = pinView
        }

        if let annotationView = annotationView {
            annotationView.annotation = annotation

            // 5 Set the index so we can find the object in the array for later
            let button = annotationView.rightCalloutAccessoryView as! UIButton

            if let index = locations.firstIndex(of: annotation as! Location) {
                button.tag = index
            }
        }

        return annotationView
    }



}
