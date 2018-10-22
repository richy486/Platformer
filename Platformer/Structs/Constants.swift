//
//  Constants.swift
//  Platformer
//
//  Created by Richard Adem on 29/9/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import Foundation

struct Constants {

    public static let kNotificationCollide = NSNotification.Name(rawValue: "kNotificationCollide")
    public static let kCollideXPosition = "kCollideXPosition"
    public static let kCollideYLeftPosition = "kCollideYLeftPosition"
    public static let kCollideYRightPosition = "kCollideYRightPosition"
    
    public static let kNotificationMapChange = NSNotification.Name(rawValue: "kNotificationMapChange")
    public static let kMapChangePoint = "kMapChangePoint"
    public static let kMapChangeTileType = "kMapChangeTileType"
    
    enum Layer: CGFloat {
        case background = 0
        case active = 20
        case debug = 100
    }
}
