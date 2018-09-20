//
//  Map.swift
//  Platformer
//
//  Created by Richard Adem on 19/9/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import Foundation

struct TileTypeFlag: OptionSet {
    
    let rawValue: Int
    
    static let nonsolid = TileTypeFlag(rawValue: 1 << 0)
    static let solid = TileTypeFlag(rawValue: 1 << 1)
    static let solid_on_top = TileTypeFlag(rawValue: 1 << 2)
}

let S = TileTypeFlag.solid.rawValue
let T = TileTypeFlag.solid_on_top.rawValue

func map(x: Int, y: Int) -> Int {
    
    guard y >= 0 && y < AppState.shared.blocks.count else {
        return -1
    }
    let xBlocks = AppState.shared.blocks[y]
    guard x >= 0 && x < xBlocks.count else {
        return -1
    }
    
    return xBlocks[x]
}

func setMap(x: Int, y: Int, tileType: TileTypeFlag) {
    
    guard y >= 0 && y < AppState.shared.blocks.count else {
        return
    }
    let xBlocks = AppState.shared.blocks[y]
    guard x >= 0 && x < xBlocks.count else {
        return
    }
    
    AppState.shared.blocks[y][x] = tileType.rawValue
}

func posToTilePos(_ position: CGPoint) -> (x: Int, y: Int) {
    let x = Int(position.x + 0.5) / TILESIZE
    let y = (Int(position.y + 0.5) / TILESIZE) //+ 1
    
    return (x, y)
}

func posToTile(_ position: CGPoint) -> Int {
    let tilePos = posToTilePos(position)
    
    return map(x: tilePos.x, y: tilePos.y)
}
