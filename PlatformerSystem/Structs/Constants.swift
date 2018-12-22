//
//  Constants.swift
//  Platformer
//
//  Created by Richard Adem on 29/9/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import Foundation

public let VELMOVINGFRICTION = CGFloat(0.2)
public let TILESIZE = Int(32)
public let COLLISION_GIVE = CGFloat(0.2) // Move back by this amount when colliding
public let BOUNCESTRENGTH = CGFloat(0.5)
public let MAXVELY = CGFloat(20.0)

public struct Constants {
  
  public static let kNotificationCollide = NSNotification.Name(rawValue: "kNotificationCollide")
  public static let kCollideXPosition = "kCollideXPosition"
  public static let kCollideYLeftPosition = "kCollideYLeftPosition"
  public static let kCollideYRightPosition = "kCollideYRightPosition"
  
  public static let kNotificationMapChange = NSNotification.Name(rawValue: "kNotificationMapChange")
  public static let kMapChangePoint = "kMapChangePoint"
  public static let kMapChangeTileType = "kMapChangeTileType"
  
  public enum Layer: CGFloat {
    case background = 0
    case active = 20
    case debug = 100
  }
}
