//
//  String+AddText.swift
//  SpotSaver
//
//  Created by Alex Ladines on 8/12/19.
//  Copyright © 2019 Alex Ladines. All rights reserved.
//

import Foundation

// Make code that converts placemarks to strings cleaner
extension String {
    mutating func add(text: String?, separatedBy separator: String = "") {
        if let text = text {
            if !isEmpty {
                self += separator
            }
            self += text
        }
    }
}
