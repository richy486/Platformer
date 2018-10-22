//
//  Map.swift
//  Platformer
//
//  Created by Richard Adem on 19/9/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import Foundation

class Map {

    

    class func tile(point: IntPoint) -> TileTypeFlag {
        let mapValue = map(point: point)
        let tileType = TileTypeFlag(rawValue: mapValue)
        return tileType
    }
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
    
    class func isGap(point: IntPoint) -> Bool {
        
        let pointSolid = tile(point: point).contains(.solid)
        let leftSolid = tile(point: IntPoint(x: point.x-1, y: point.y) ).contains(.solid)
        let rightSolid = tile(point: IntPoint(x: point.x+1, y: point.y) ).contains(.solid)
        let topLeftSolid = tile(point: IntPoint(x: point.x-1, y: point.y-1) ).contains(.solid)
        let topSolid = tile(point: IntPoint(x: point.x, y: point.y-1) ).contains(.solid)
        let topRightSolid = tile(point: IntPoint(x: point.x+1, y: point.y-1) ).contains(.solid)
        
        let isGap = leftSolid && !pointSolid && rightSolid && !topLeftSolid && !topSolid && !topRightSolid
        
        return isGap
    }
    
    class func slopeDirection(forVelocity velocity: CGPoint, andTile tile: TileTypeFlag) -> Direction {
        var direction: Direction = .stationary
        
        if tile.intersection(.slope_right).rawValue != 0 {
            if velocity.x > 0 {
                direction = .downRight
            } else if velocity.x < 0 {
                direction = .upLeft
            }
            
        } else if tile.contains(.slope_left) {
            if velocity.x > 0 {
                direction = .upRight
            } else if velocity.x < 0 {
                direction = .downLeft
            }
        }
        
        return direction
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
        
        callMapChange(forPoint: IntPoint(x: x, y: y), tileType: tileType)
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
        
        let usedBreakable = mapTileType.intersection(.used) == .used && mapTileType.intersection(.breakable) == .breakable
        let collisionTile = mapTileType.intersection(tileType).rawValue != 0
        
        let collide = collisionTile && !usedBreakable
        
        if collide && direction == .up {
            print("stop")
        }
        
        if !noTrigger && mapTileType.intersection(.used) != .used {
            if collide && mapTileType.contains(.breakable) && direction == .up {
                let updatedTile = mapTileType.symmetricDifference(.solid).union(.used)
                setMap(x: point.x, y: point.y, tileType: updatedTile)
            }
            
            if collide && mapTileType.contains(.powerup) && direction == .up {
                setMap(x: point.x, y: point.y, tileType: mapTileType.union(.used))
            }
            
        }
        
        return collide
    }
    
    class func slopesBelow(position: CGPoint) -> (left: TileTypeFlag?, right: TileTypeFlag?) {
        
        var y = (Int(position.y) + PH_SLOPE) / TILESIZE
        let leftCheck = Int(position.x) / TILESIZE
        let centerCheck = (Int(position.x) + PW/2) / TILESIZE
        let rightCheck = (Int(position.x) + PW) / TILESIZE
        
        var foundSlopeLeft: TileTypeFlag? = nil
        var foundSlopeRight: TileTypeFlag? = nil
        
        var i = 0; // Check current tile and the next one
        while y < AppState.shared.blocks.count && i < 2 {
            
            guard foundSlopeLeft == nil || foundSlopeRight == nil else {
                break
            }
            
            let leftTile = Map.tile(point: IntPoint(x: leftCheck, y: y ))
            let centerTile = Map.tile(point: IntPoint(x: centerCheck, y: y ))
            let rightTile = Map.tile(point: IntPoint(x: rightCheck, y: y ))
            
            // Left side only cares about slopes that are facing right
            if foundSlopeLeft == nil && leftTile.intersection(.slope_right).rawValue != 0 {
                foundSlopeLeft = leftTile
            }
            if foundSlopeRight == nil && leftTile.intersection(.slope_left).rawValue != 0 {
                foundSlopeRight = leftTile
            }
            if centerTile != leftTile && foundSlopeLeft == nil && centerTile.intersection(.slope_right).rawValue != 0 {
                foundSlopeLeft = centerTile
            }
            if centerTile != rightTile && foundSlopeRight == nil && centerTile.intersection(.slope_left).rawValue != 0 {
                foundSlopeRight = centerTile
            }
            if foundSlopeRight == nil && rightTile.intersection(.slope_left).rawValue != 0 {
                foundSlopeRight = rightTile
            }
            if foundSlopeLeft == nil && rightTile.intersection(.slope_right).rawValue != 0 {
                foundSlopeLeft = rightTile
            }
            
            y += 1
            i += 1
        }
        
        return (left: foundSlopeLeft, right: foundSlopeRight)
    }
    
    typealias MapChangeCallback = (_ point: IntPoint, _ tileType: TileTypeFlag) -> Void
    static var mapChangeCallbacks: [MapChangeCallback] = []
    class func listenForMapChanges(_ update: @escaping MapChangeCallback) {
        mapChangeCallbacks.append(update)
    }
    private class func callMapChange(forPoint point: IntPoint, tileType: TileTypeFlag) {
        for update in mapChangeCallbacks {
            update(point, tileType)
        }
    }
}
