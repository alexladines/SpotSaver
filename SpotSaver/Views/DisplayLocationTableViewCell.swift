//
//  DisplayLocationTableViewCell.swift
//  SpotSaver
//
//  Created by Alex Ladines on 8/6/19.
//  Copyright © 2019 Alex Ladines. All rights reserved.
//

import UIKit

class DisplayLocationTableViewCell: UITableViewCell {

    // MARK: - Properties

    // MARK: - IBOutlets
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!

    // MARK: - IBActions

    // MARK: - Life Cycle

    override func awakeFromNib() {
        super.awakeFromNib()
        let backgroundView = UIView()
        backgroundView.backgroundColor = .darkGray
        selectedBackgroundView = backgroundView
    }

    // MARK: - Methods
    func configure(for location: Location) {
        if location.locationDescription.isEmpty {
            descriptionLabel.text = "(No Description)"
        }
        else {
            descriptionLabel.text = location.locationDescription
        }

        if let placemark = location.placemark {
            var text = ""
            text.add(text: placemark.subThoroughfare)
            text.add(text: placemark.thoroughfare, separatedBy: " ")
            text.add(text: placemark.locality, separatedBy: ", ")
            addressLabel.text = text
        }
        else {
            addressLabel.text = String(format: "Lat: %.8f, Long: %.8f", location.latitude, location.longitude)
        }

        photoImageView.image = thumbnail(for: location)
    }

    func thumbnail(for location: Location) -> UIImage {
        if location.hasPhoto, let image = location.photoImage {
            return image.resized(withBounds: CGSize(width: 52, height: 52))
        }
        else {
            return UIImage(named: "No Photo")!
        }
    }

    // MARK: - Navigation

    // MARK: - Data Persistance

}
