//
//  TileTypeFlag.swift
//  Platformer
//
//  Created by Richard Adem on 21/10/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import Foundation

struct TileTypeFlag: OptionSet {
    
    let rawValue: Int
    
    static let nonsolid = TileTypeFlag(rawValue: 1 << 0)
    static let solid = TileTypeFlag(rawValue: 1 << 1)
    static let solid_on_top = TileTypeFlag(rawValue: 1 << 2)
    static let breakable = TileTypeFlag(rawValue: 1 << 3)
    static let used = TileTypeFlag(rawValue: 1 << 4)
    static let powerup = TileTypeFlag(rawValue: 1 << 5)
    
    static let slope_left = TileTypeFlag(rawValue: 1 << 6)  // ◿
    static let slope_right = TileTypeFlag(rawValue: 1 << 7) // ◺
    
    static let pickup = TileTypeFlag(rawValue: 1 << 8)
    static let player_start = TileTypeFlag(rawValue: 1 << 9)
    
    // 0000
    // 1010
    // 8421
}

let S = TileTypeFlag.solid.rawValue
let T = TileTypeFlag.solid_on_top.rawValue
let B = TileTypeFlag.breakable.rawValue
