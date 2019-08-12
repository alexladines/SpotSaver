//
//  SpotSaverTabBarController.swift
//  SpotSaver
//
//  Created by Alex Ladines on 8/12/19.
//  Copyright © 2019 Alex Ladines. All rights reserved.
//

import UIKit

class SpotSaverTabBarController: UITabBarController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    // All children will look to this vc for the preferredStatusBarStyle
    override var childForStatusBarStyle: UIViewController? {
        return nil
    }

}
