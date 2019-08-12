//
//  UIImage+Resize.swift
//  SpotSaver
//
//  Created by Alex Ladines on 8/12/19.
//  Copyright © 2019 Alex Ladines. All rights reserved.
//

import UIKit

// To make images fit in 52x52 square, images need to be scaled down
// Plan: Scale down images before putting them in table view cell.
// Don't forget to change content mode on storyboard
extension UIImage {
    func resized(withBounds bounds: CGSize) -> UIImage {
        let horizontalRatio = bounds.width / size.width
        let verticalRatio = bounds.height / size.height
        let ratio = min(horizontalRatio, verticalRatio)
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
}
