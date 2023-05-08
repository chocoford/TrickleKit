//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/5/8.
//

import Foundation
import UserNotifications

class UserNotificationCenter {
    static let shared = UserNotificationCenter()
    
    var center: UNUserNotificationCenter { UNUserNotificationCenter.current() }
    
    var granted: Bool = false
    
    init() {
//        requestPermission()
    }
    
    func requestPermission() {
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            self.granted = granted
        }
    }
    
    func pushNormalNotification(title: String, subtitle: String, body: String, sound: UNNotificationSound = .default) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        content.body = body
        content.sound = sound
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        center.add(request)
    }
}
