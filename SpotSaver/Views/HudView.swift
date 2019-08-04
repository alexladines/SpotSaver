//
//  HudView.swift
//  SpotSaver
//
//  Created by Alex Ladines on 8/4/19.
//  Copyright © 2019 Alex Ladines. All rights reserved.
//

import UIKit

class HudView: UIView {
    // MARK: - Properties
    var text = ""

    class func hud(inView view: UIView, animated: Bool) -> HudView {
        let hudView = HudView(frame: view.bounds)

        hudView.isOpaque = false

        view.addSubview(hudView)
        view.isUserInteractionEnabled = false

        hudView.show(animated: animated)
        return hudView
    }

    // MARK: - Methods
    override func draw(_ rect: CGRect) {
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96

        let x = round((bounds.size.width - boxWidth) / 2)
        let y = round((bounds.size.height - boxHeight) / 2)

        let boxRect = CGRect(x: x, y: y, width: boxWidth, height: boxHeight)

        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)

        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()

        // Draw Checkmark
        if let image = UIImage(named: "Checkmark") {
            let x = center.x - round(image.size.width / 2)
            let y = center.y - round(image.size.height / 2) - boxHeight/8

            let imagePoint = CGPoint(x: x, y: y)
            image.draw(at: imagePoint)
        }

        // Draw text
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.white]

        let textSize = text.size(withAttributes: attributes)

        let textXPoint = center.x - round(textSize.width / 2)
        let textYPoint = center.y - round(textSize.height / 2) + boxHeight / 4

        let textPoint = CGPoint(x: textXPoint, y: textYPoint)

        text.draw(at: textPoint, withAttributes: attributes)
    }

    // Transparent and small to regular size
    func show(animated: Bool) {
        if animated {
            // Fully transparent at first
            alpha = 0
            // Scaled up larger than it normally is
            transform = CGAffineTransform(scaleX: 1.3, y: 1.3)

            // Animation
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
                self.alpha = 1
                self.transform = CGAffineTransform.identity
            })

        }
    }

    // Remove view with animation
    func hide() {
        UIView.animate(withDuration: 0.2, animations: { self.alpha = 0.0}) { _ in
            self.removeFromSuperview()
        }

        superview?.isUserInteractionEnabled = true
    }
}

