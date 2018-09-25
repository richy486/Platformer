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
    static let breakable = TileTypeFlag(rawValue: 1 << 3)
    
    // 0000
    // 1010
    // 8421
}

let S = TileTypeFlag.solid.rawValue
let T = TileTypeFlag.solid_on_top.rawValue
let B = TileTypeFlag.breakable.rawValue

class Map {

    static var basicTileTypes: [TileTypeFlag] = [
        .nonsolid,
        .solid,
        .solid_on_top,
        .breakable,
    ]

    // Probably should rename this to tile(x:y:)
    class func map(point: IntPoint) -> Int {
        return map(x: point.x, y: point.y)
    }
    class func map(x: Int, y: Int) -> Int {
        
        guard y >= 0 && y < AppState.shared.blocks.count else {
            return -1
        }
        let xBlocks = AppState.shared.blocks[y]
        guard x >= 0 && x < xBlocks.count else {
            return -1
        }
        
        return xBlocks[x]
    }

    class func setMap(x: Int, y: Int, tileType: TileTypeFlag) {
        
        guard y >= 0 && y < AppState.shared.blocks.count else {
            return
        }
        let xBlocks = AppState.shared.blocks[y]
        guard x >= 0 && x < xBlocks.count else {
            return
        }
        
        AppState.shared.blocks[y][x] = tileType.rawValue
        
        callMapChange(forPoint: IntPoint(x: x, y: y))
    }

    class func posToTilePos(_ position: CGPoint) -> (x: Int, y: Int) {
        let x = Int(position.x + 0.5) / TILESIZE
        let y = (Int(position.y + 0.5) / TILESIZE) //+ 1
        
        return (x, y)
    }

    class func posToTile(_ position: CGPoint) -> Int {
        let tilePos = posToTilePos(position)
        
        return map(x: tilePos.x, y: tilePos.y)
    }
    
    class func collide(atPoint point: IntPoint, tileType: TileTypeFlag, direction: Direction, noTrigger: Bool = false) -> Bool {
        let tile = map(point: point)
        let mapTileType = TileTypeFlag(rawValue: tile)
        let collide = mapTileType.intersection(tileType).rawValue != 0
        
        if !noTrigger {
            if collide && mapTileType.contains(.breakable) && direction == .up {
                setMap(x: point.x, y: point.y, tileType: .nonsolid)
            }
        }
        
        return collide
    }
    
    typealias MapChangeCallback = (_ point: IntPoint) -> Void
    static var mapChangeCallbacks: [MapChangeCallback] = []
    class func listenForMapChanges(_ update: @escaping MapChangeCallback) {
        mapChangeCallbacks.append(update)
    }
    private class func callMapChange(forPoint point: IntPoint) {
        for update in mapChangeCallbacks {
            update(point)
        }
    }
}
