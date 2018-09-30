//
//  Constants.swift
//  Platformer
//
//  Created by Richard Adem on 29/9/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import Foundation

struct Constants {
//    let
//    public static let NSCalendarDayChanged: NSNotification.Name
    public static let kNotificationCollide = NSNotification.Name(rawValue: "kNotificationCollide")
    public static let kCollideXPosition = "kCollideXPosition"
    public static let kCollideYLeftPosition = "kCollideYLeftPosition"
    public static let kCollideYRightPosition = "kCollideYRightPosition"
    
    enum Layer: CGFloat {
        case background = 0
        case active = 20
        case debug = 100
    }
}
