//
//  TileTypeFlag.swift
//  Platformer
//
//  Created by Richard Adem on 21/10/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import Foundation

public struct TileTypeFlag: OptionSet {
  
  public let rawValue: Int
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
  
  public static let nonsolid = TileTypeFlag(rawValue: 1 << 0)
  public static let solid = TileTypeFlag(rawValue: 1 << 1)
  public static let solid_on_top = TileTypeFlag(rawValue: 1 << 2)
  public static let breakable = TileTypeFlag(rawValue: 1 << 3)
  public static let used = TileTypeFlag(rawValue: 1 << 4)
  public static let powerup = TileTypeFlag(rawValue: 1 << 5)
  
  public static let slope_left = TileTypeFlag(rawValue: 1 << 6)  // ◿
  public static let slope_right = TileTypeFlag(rawValue: 1 << 7) // ◺
  
  public static let pickup = TileTypeFlag(rawValue: 1 << 8)
  public static let player_start = TileTypeFlag(rawValue: 1 << 9)
  public static let piggy = TileTypeFlag(rawValue: 1 << 10)
  
  
  // 0000
  // 1010
  // 8421
}

let S = TileTypeFlag.solid.rawValue
let T = TileTypeFlag.solid_on_top.rawValue
let B = TileTypeFlag.breakable.rawValue
