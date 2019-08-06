//
//  CurrentLocationViewController.swift
//  SpotSaver
//
//  Created by Alex Ladines on 8/1/19.
//  Copyright © 2019 Alex Ladines. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

// For Info.plist -> Need Privacy - Location When In Usage Description
// For Info.plist ->

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {

    // MARK: - Properties
    var locationManager = CLLocationManager()
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError: Error?
    var managedObjectContext: NSManagedObjectContext!

    // Reverse Geocoding
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: Error?

    // MARK: - IBOutlets
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagLocationButton: UIButton!
    @IBOutlet weak var getMyLocationButton: UIButton!

    // MARK: - IBActions
    @IBAction func getMyLocationButtonTapped(_ sender: UIButton) {
        // Request Permission
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return 
        }

        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }

        // If currently updating then stop
        if updatingLocation {
            stopLocationManager()
        }
        else {
            location = nil
            lastLocationError = nil
            placemark = nil
            lastGeocodingError = nil
            startLocationManager()
        }

        updateLabels()
    }

    // MARK: - Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
    }

    // MARK: - Methods
    func configureGetButton() {
        if updatingLocation {
            getMyLocationButton.setTitle("Stop", for: .normal)
        }
        else {
            getMyLocationButton.setTitle("Get My Location", for: .normal)
        }
    }

    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable location services for this app in Settings.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        present(alert, animated: true)
    }

    func updateLabels() {
        if let location = location {
            latitudeLabel.text = String(format: "%.8f", location.coordinate.latitude)
            longitudeLabel.text = String(format: "%.8f", location.coordinate.longitude)
            tagLocationButton.isHidden = false
            messageLabel.text = ""

            if let placemark = placemark {
                addressLabel.text = string(from: placemark)
            }
            else if performingReverseGeocoding {
                addressLabel.text = "Searching for Address..."
            }
            else if lastGeocodingError != nil {
                addressLabel.text = "Error Finding Address"
            }
            else {
                addressLabel.text = "No Address Found"
            }
        }
        else {
            latitudeLabel.text = ""
            longitudeLabel.text = ""
            addressLabel.text = ""
            tagLocationButton.isHidden = true

            let statusMessage: String
            if let error = lastLocationError as NSError? {
                if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                    statusMessage = "Location Services Disabled"
                }
                else {
                    statusMessage = "Error Getting Location"
                }
            }
            else if !CLLocationManager.locationServicesEnabled() {
                statusMessage = "Location Services Disabled"
            }
            else if updatingLocation {
                statusMessage = "Searching..."
            }
            else {
                statusMessage = "Tap 'Get My Location' to Start"
            }

            messageLabel.text = statusMessage

        }

        configureGetButton()
    }

    func string(from placemark: CLPlacemark) -> String {
        var line1 = ""
        // House Number
        if let s = placemark.subThoroughfare {
            line1 += s + " "
        }

        // Street Name
        if let s = placemark.thoroughfare {
            line1 += s
        }

        print(line1)

        var line2 = ""
        // City
        if let s = placemark.locality {
            line2 += s + " "
        }
        // State
        if let s = placemark.administrativeArea {
            line2 += s + " "
        }
        // Zip Code
        if let s = placemark.postalCode {
            line2 += s

        }

        print(line2)

        // Attach them
        return line1 + "\n" + line2


    }

    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            updatingLocation = true
        }
    }

    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TagLocation" {
            let vc = segue.destination as! LocationDetailsTableViewController
            vc.coordinate = location!.coordinate
            vc.placemark = placemark
            vc.managedObjectContext = managedObjectContext
        }
    }

    // MARK: - Data Persistance

    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("didFailWithError \(error.localizedDescription)")

        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }

        lastLocationError = error
        stopLocationManager()
        updateLabels()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")

        // Ignore old results
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            return
        }
        // Ignore invalid measurements
        if newLocation.horizontalAccuracy < 0 {
            return
        }

        // Calculate distance from new reading and previous reading
        // If first reading -> huge distance!
        var distance = CLLocationDistance(Double.greatestFiniteMagnitude)
        if let location = location {
            distance = newLocation.distance(from: location)
        }

        // NOTE: Larger accuracy values = less accurate
        // If location == nil -> First measurement we are taking
        if location == nil || location!.horizontalAccuracy > newLocation.horizontalAccuracy {

            // Store the result
            lastLocationError = nil
            location = newLocation
            // We obtained a good result so we can stop updating and draining the battery.
            if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy {
                print("*** We're done!")
                stopLocationManager()
                // Force a reverse geocoding for final location as its the most accurate one
                if distance > 0 {
                    performingReverseGeocoding = false
                }
            }

            updateLabels()

            if !performingReverseGeocoding {
                print("*** Going to geocode")

                performingReverseGeocoding = true

                geocoder.reverseGeocodeLocation(newLocation) { (placemarks, error) in
                    self.lastGeocodingError = error
                    if error == nil, let p = placemarks, !p.isEmpty {
                        self.placemark = p.last!
                    }
                    else {
                        self.placemark = nil
                    }

                    self.performingReverseGeocoding = false
                    self.updateLabels()
                }
            }
            // If distance is not very different and it's been > 10 seconds since orginal reading then we will just stop. This is necessary to not drain battery of devices after multiple tries.
            else if distance < 1 {
                let timeInterval = newLocation.timestamp.timeIntervalSince(location!.timestamp)

                if timeInterval > 10 {
                    print("*** Force done!")
                    stopLocationManager()
                    updateLabels()
                }
            }

        }
        updateLabels()
    }





}
