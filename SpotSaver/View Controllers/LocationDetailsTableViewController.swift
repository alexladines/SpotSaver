//
//  LocationDetailsTableViewController.swift
//  SpotSaver
//
//  Created by Alex Ladines on 8/3/19.
//  Copyright © 2019 Alex Ladines. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData

// lazy creation to not use too mucb battery
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

class LocationDetailsTableViewController: UITableViewController, UINavigationControllerDelegate {

    // MARK: - Properties
    var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var placemark: CLPlacemark?
    var categoryName = "No Category"
    var managedObjectContext: NSManagedObjectContext!
    var date = Date()
    var image: UIImage? {
        didSet {
            if let image = image {
                imageView.image = image
                imageView.isHidden = false
                addPhotoLabel.text = ""
                imageHeight.constant = 260
                tableView.reloadData()
            }
        }
    }

    // For editing segue
    var descriptionText = ""
    var locationToEdit: Location? {
        didSet {
            if let location = locationToEdit {
                descriptionText = location.locationDescription
                categoryName = location.category
                date = location.date
                coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
                placemark = location.placemark
            }
        }
    }


    // MARK: - IBOutlets
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addPhotoLabel: UILabel!
    @IBOutlet weak var imageHeight: NSLayoutConstraint!


    // MARK: - IBActions

    @IBAction func doneBarButtonItemPressed(_ sender: UIBarButtonItem) {
        let hudView = HudView.hud(inView: navigationController!.view, animated: true)
        hudView.text = "Tagged"

        // Either get a location from Core Data or use the one from the Edit Segue
        let location: Location
        if let temp = locationToEdit {
            hudView.text = "Updated"
            location = temp
        }
        else {
            hudView.text = "Tagged"
            location = Location(context: managedObjectContext)
            location.photoID = nil
        }

        // Set properties
        location.locationDescription = descriptionTextView.text
        location.category = categoryName
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        location.date = date
        location.placemark = placemark

        // Save Photo
        if let image = image {
            if !location.hasPhoto {
                location.photoID = Location.nextPhotoID() as NSNumber
            }

            if let data = image.jpegData(compressionQuality: 0.5) {
                do {
                    try data.write(to: location.photoURL, options: .atomic)
                }
                catch {
                    print("Error writing to file: \(error)")
                }
            }
        }

        // Save object context
        do {
            try managedObjectContext.save()
            // Close screen after 0.6 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                hudView.hide()
                self.navigationController?.popViewController(animated: true)
            }
        }
        catch {
            fatalCoreDataError(error)
        }
    }

    @IBAction func cancelBarButtonItemPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Check if this was from the editing segue
        if let location = locationToEdit {
            title = "Edit Location"

            if location.hasPhoto {
                if let theImage = location.photoImage {
                    image = theImage
                }
            }
        }
        

        descriptionTextView.text = descriptionText
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

        dateLabel.text = format(date: date)

        // Gesture Recognizer for keyboard
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)

        // Listen for background notification
        listenForBackgroundNotification()
    }

    // MARK: - Methods
    func string(from placemark: CLPlacemark) -> String {
        var line = ""
        line.add(text: placemark.subThoroughfare)
        line.add(text: placemark.thoroughfare, separatedBy: " ")
        line.add(text: placemark.locality, separatedBy: ", ")
        line.add(text: placemark.administrativeArea, separatedBy: ", ")
        line.add(text: placemark.postalCode, separatedBy: " ")
        line.add(text: placemark.country, separatedBy: ", ")
        return line
    }

    func format(date: Date) -> String {
        return dateFormatter.string(from: date)
    }

    @objc func hideKeyboard(_ gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: point)
        // Check if user selected a cell other than the text view
        if let indexPath = indexPath {
            if indexPath.section != 0 && indexPath.row != 0 {
                descriptionTextView.resignFirstResponder()
            }
        }
        // User tapped on another point on the screen
        else {
            descriptionTextView.resignFirstResponder()
        }

        descriptionTextView.resignFirstResponder()

        // Also on storyboard -> Table View -> Dismiss keyboard when scrolling.
    }

    func takePhotoWithCamera() {
        let imagePicker = LightVersionImagePickerController()
        imagePicker.view.tintColor = view.tintColor
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }

    func choosePhotoFromLibrary() {
        let imagePicker = LightVersionImagePickerController()
        imagePicker.view.tintColor = view.tintColor
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }

    func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        }
        else {
            choosePhotoFromLibrary()
        }
    }

    func showPhotoMenu() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(cancelAction)

        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.takePhotoWithCamera()
        })

        alert.addAction(takePhotoAction)

        let libraryAction = UIAlertAction(title: "Choose From Library", style: .default, handler: { _ in
            self.choosePhotoFromLibrary()
        })

        alert.addAction(libraryAction)

        present(alert, animated: true)
    }

    // Check if going to home screen
    func listenForBackgroundNotification() {
        NotificationCenter.default.addObserver(forName: UIApplication.didEnterBackgroundNotification, object: nil, queue: OperationQueue.main) { [weak self] _ in

            if let weakSelf = self {
                if weakSelf.presentedViewController != nil {
                    weakSelf.dismiss(animated: false, completion: nil)
                }

                weakSelf.descriptionTextView.resignFirstResponder()
            }

        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PickCategory" {
            let vc = segue.destination as! CategoryPickerTableViewController
            vc.selectedCategoryName = categoryName
            vc.delegate = self
        }
    }

}

// MARK: - UITableViewDelegate
extension LocationDetailsTableViewController {
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .darkGray
        cell.selectedBackgroundView = backgroundView
    }

    // Only taps in the first 2 sections are valid
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 1 {
            return indexPath
        }
        else {
            return nil
        }
    }

    // Make textfield active if user taps anywhere in the cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            descriptionTextView.becomeFirstResponder()
        }
        else if indexPath.section == 1 && indexPath.row == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            pickPhoto()
        }
    }
}

// MARK: - UIImagePickerControllerDelegate
extension LocationDetailsTableViewController: UIImagePickerControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage

        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - CategoryPickerTableViewControllerDelegate
extension LocationDetailsTableViewController: CategoryPickerTableViewControllerDelegate {
    func categoryPickerTableViewController(_ controller: CategoryPickerTableViewController, didFinishSelecting category: String) {
        categoryName = category
        categoryLabel.text = categoryName
        navigationController?.popViewController(animated: true)
    }
}

