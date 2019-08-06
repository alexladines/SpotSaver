//
//  Functions.swift
//  SpotSaver
//
//  Created by Alex Ladines on 8/6/19.
//  Copyright © 2019 Alex Ladines. All rights reserved.
//

import Foundation

// Find Core Data data store location
let applicationDocumentDirectory: URL = {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}()

// Catching Save Errors from Core Data
let CoreDataSaveFailedNotification = Notification.Name(rawValue: "CoreDataSaveFailedNotification")

// Output to console, then send notification expecting some object to listen
func fatalCoreDataError(_ error: Error) {
    print("*** Fatal error: \(error)")
    NotificationCenter.default.post(name: CoreDataSaveFailedNotification, object: nil)
}
