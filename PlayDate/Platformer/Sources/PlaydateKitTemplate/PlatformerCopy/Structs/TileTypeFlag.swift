//
//  TileTypeFlag.swift
//  Platformer
//
//  Created by Richard Adem on 21/10/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

// import Foundation

public struct TileTypeFlag: OptionSet {
  
  public let rawValue: Int
  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
  
  public static var nonsolid: TileTypeFlag { TileTypeFlag(rawValue: 1 << 0) }
  public static var solid: TileTypeFlag { TileTypeFlag(rawValue: 1 << 1) }
  public static var solid_on_top: TileTypeFlag { TileTypeFlag(rawValue: 1 << 2) }
  public static var breakable: TileTypeFlag { TileTypeFlag(rawValue: 1 << 3) }
  public static var used: TileTypeFlag { TileTypeFlag(rawValue: 1 << 4) }
  public static var powerup: TileTypeFlag { TileTypeFlag(rawValue: 1 << 5) }

  public static var slope_left: TileTypeFlag { TileTypeFlag(rawValue: 1 << 6) } // ◿
  public static var slope_right: TileTypeFlag { TileTypeFlag(rawValue: 1 << 7) } // ◺ }

  public static var pickup: TileTypeFlag { TileTypeFlag(rawValue: 1 << 8) }
  public static var player_start: TileTypeFlag { TileTypeFlag(rawValue: 1 << 9) }
  public static var piggy: TileTypeFlag { TileTypeFlag(rawValue: 1 << 10) }
  public static var jsItem: TileTypeFlag { TileTypeFlag(rawValue: 1 << 11) }
  public static var pickAxe: TileTypeFlag { TileTypeFlag(rawValue: 1 << 12) }
  public static var door: TileTypeFlag { TileTypeFlag(rawValue: 1 << 13) }

  // 0000
  // 1010
  // 8421
}

let S = TileTypeFlag.solid.rawValue
let T = TileTypeFlag.solid_on_top.rawValue
let B = TileTypeFlag.breakable.rawValue
