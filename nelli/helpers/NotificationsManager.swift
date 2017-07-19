//
//  NotificationsManager.swift
//  nelli
//
//  Created by César Guadarrama on 7/19/17.
//  Copyright © 2017 César Guadarrama. All rights reserved.
//

import Foundation
import UserNotifications

class NotificationsManager {
    
    static func getAuthorizationStatus(handler: @escaping (UNNotificationSettings) -> Void)   {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings(completionHandler: handler)
    }
    
    static func requestAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.badge, .sound, .alert]) { (granted, error) in
            if (error != nil) {
                print("Notification request error \(error!)")
                return
            }
        }
    }
    
    static func sendNotificationWith(title: String, body: String, identifier: String) {
        print("Sending notification \(title)\n\(body)")
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default()
    
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: nil)
    
        let center = UNUserNotificationCenter.current()
        center.add(request, withCompletionHandler: { error in
            if let error = error {
                print("User notification request error.\n\(error)")
                return
            }
            print("Completed!")
        })
    }
}
