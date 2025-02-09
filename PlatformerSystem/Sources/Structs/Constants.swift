//
//  Constants.swift
//  Platformer
//
//  Created by Richard Adem on 29/9/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

public let VELMOVINGFRICTION = Double(0.2)
public let TILESIZE = Int(32)
public let COLLISION_GIVE = Double(0.2) // Move back by this amount when colliding
public let BOUNCESTRENGTH = Double(0.5)
public let MAXVELY = Double(20.0)

public struct Constants {

  // Disabled in embedded.
  public static let kNotificationCollide = "kNotificationCollide" // NSNotification.Name(rawValue: "kNotificationCollide")
  public static let kCollideXPosition = "kCollideXPosition"
  public static let kCollideYLeftPosition = "kCollideYLeftPosition"
  public static let kCollideYRightPosition = "kCollideYRightPosition"

  // Disabled in embedded.
  public static let kNotificationMapChange = "kNotificationMapChange" // NSNotification.Name(rawValue: "kNotificationMapChange")
  public static let kMapChangePoint = "kMapChangePoint"
  public static let kMapChangeTileType = "kMapChangeTileType"
  
  public enum Layer: Double {
    case background = 0
    case active = 20
    case debug = 100
  }
}
