//
//  Collision.swift
//  Platformer
//
//  Created by Richard Adem on 20/10/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import Foundation

protocol Collision {

}

extension Collision {

    // bool CPlayer::collision_slope(int sx, int sy, int &tsx;, int &tsy;)
    // https://web.archive.org/web/20100526071550/http://jnrdev.72dpiarmy.com:80/en/jnrdev2/
    // Shouldn't change f in this function, TODO: put into protocol extension
    func collision_slope(movePosition position: CGPoint, velocity: CGPoint, forTile tilePosition: IntPoint? = nil, force: Bool = false) -> (position: CGPoint, collide: Bool, collideTile: IntPoint) {

        //        let s: IntPoint
        //        if let tilePosition = tilePosition {
        //            s = tilePosition
        //        } else {
        let s = IntPoint(x: Int(position.x) + (PW>>1) + Int(velocity.x),
                         y: Int(position.y) + PH)
        //        }

        var resultingPosition = position
        var collide = false
        //map coordinates of the tile we check against

        let ts = IntPoint(x: s.x / TILESIZE, y: s.y / TILESIZE)

        //        let ts: IntPoint
        //        if let tilePosition = tilePosition {
        //            ts = tilePosition
        //        } else {
        //            ts = IntPoint(x: s.x / TILESIZE, y: s.y / TILESIZE)
        //        }

        let t = Map.tile(point: ts)

        //if we found a slope we set align y to the slope.
        if t.contains(.slope_right) {
            // ◺
            if AppState.shared.printCollisions {
                print("◺: \(ts)")
            }
            let yGround = (ts.y+1) * TILESIZE       // y pixel coordinate of the ground of the tile
            let inside = TILESIZE - (s.x%TILESIZE)  // minus how far sx is inside the tile (16 pixels in the exapmle)

            // PH: minus the height (sx is located at the bottom of the player, but y is at the top)
            // -1: we don't want to stick in a tile, this would cause complications in the next frame
            resultingPosition.y = CGFloat(yGround - inside - PH - 1)

            if position.y + velocity.y >= resultingPosition.y || force{
                if AppState.shared.printCollisions {
                    print("no slope ◺: \(ts)")
                }
                collide = true
            }
        } else if t.contains(.slope_left) {
            // ◿
            if AppState.shared.printCollisions {
                print("◿: \(ts)")
            }
            resultingPosition.y = CGFloat((ts.y+1)*TILESIZE - s.x%TILESIZE - PH - 1)
            if position.y + velocity.y >= resultingPosition.y  || force {
                if AppState.shared.printCollisions {
                    print("no slope ◿: \(ts)")
                }
                collide = true
            }
        } else {
            if AppState.shared.printCollisions {
                print("no slope: \(ts)")
            }
        }

        return (resultingPosition, collide, ts)
    }

    func adjustToSlope(potentialPosition: CGPoint) -> (position: CGPoint, collide: Bool, collideTile: IntPoint) {

        //        let s: IntPoint
        //        if let tilePosition = tilePosition {
        //            s = tilePosition
        //        } else {
        let s = IntPoint(x: Int(potentialPosition.x),// + (PW>>1) + Int(velocity.x),
            y: Int(potentialPosition.y))// + PH)
        //        }
        //        let s = potentialPosition

        var resultingPosition = potentialPosition
        var collide = false
        //map coordinates of the tile we check against

        let ts = IntPoint(x: s.x / TILESIZE, y: s.y / TILESIZE)

        //        let ts: IntPoint
        //        if let tilePosition = tilePosition {
        //            ts = tilePosition
        //        } else {
        //            ts = IntPoint(x: s.x / TILESIZE, y: s.y / TILESIZE)
        //        }

        let t = Map.tile(point: ts)

        //if we found a slope we set align y to the slope.
        if t.contains(.slope_right) {
            // ◺
            if AppState.shared.printCollisions {
                print("◺: \(ts)")
            }
            let yGround = (ts.y+1) * TILESIZE       // y pixel coordinate of the ground of the tile
            let inside = TILESIZE - (s.x%TILESIZE)  // minus how far sx is inside the tile (16 pixels in the exapmle)

            // PH: minus the height (sx is located at the bottom of the player, but y is at the top)
            // -1: we don't want to stick in a tile, this would cause complications in the next frame
            resultingPosition.y = CGFloat(yGround - inside - PH - 1)

            //            if position.y + vel.y >= resultingPosition.y || force{
            if AppState.shared.printCollisions {
                print("no slope ◺: \(ts)")
            }
            collide = true
            //            }
        } else if t.contains(.slope_left) {
            // ◿
            if AppState.shared.printCollisions {
                print("◿: \(ts)")
            }
            resultingPosition.y = CGFloat((ts.y+1)*TILESIZE - s.x%TILESIZE - PH - 1)
            //            if position.y + vel.y >= resultingPosition.y  || force {
            if AppState.shared.printCollisions {
                print("no slope ◿: \(ts)")
            }
            collide = true
            //            }
        } else {
            if AppState.shared.printCollisions {
                print("no slope: \(ts)")
            }
        }

        return (resultingPosition, collide, ts)
    }


    // Shouldn't change f in this function, TODO: put into protocol extension
    func mapcolldet_moveHorizontal(movePosition position: CGPoint, velocity: CGPoint, horizontallyInDirection direction: Int, size: CGSize) -> (position: CGPoint, velocity: CGPoint, collide: Bool) {
        // left 1
        // right 3
        var position = position
        var velocity = velocity

        //Could be optimized with bit shift >> 5
        let ty = Int(position.y) / TILESIZE
        let ty2 = Int(position.y + size.height) / TILESIZE
        var tx = -1

        if direction == 1 {
            //moving left
            tx = Int(position.x) / TILESIZE;
        } else {
            //moving right
            tx = Int(position.x + size.width) / TILESIZE;
        }

        let topTilePoint = IntPoint(x: tx, y: ty)
        let bottomTilePoint = IntPoint(x: tx, y: ty2)

        // Top tile
        var collide = false
        if Map.collide(atPoint: topTilePoint, tileType: [.solid], direction: direction == 1 ? .left : .right) {
            collide = true
            if AppState.shared.printCollisions {
                print("--: \(IntPoint(x: tx, y: ty))")
            }
            NotificationCenter.default.post(name: Constants.kNotificationCollide,
                                            object: self,
                                            userInfo: [Constants.kCollideXPosition: CGPoint(x: tx * TILESIZE, y: ty * TILESIZE)])

        } else if Map.collide(atPoint: bottomTilePoint, tileType: [.solid], direction: direction == 1 ? .left : .right) {
            collide = true
            if AppState.shared.printCollisions {
                print("--: \(IntPoint(x: tx, y: ty2))")
            }
            NotificationCenter.default.post(name: Constants.kNotificationCollide,
                                            object: self,
                                            userInfo: [Constants.kCollideXPosition: CGPoint(x: tx * TILESIZE, y: ty2 * TILESIZE)])
        }

        if collide {
            if direction == 1 {
                // move to the edge of the tile
                position.x = CGFloat((tx << 5) + TILESIZE) + COLLISION_GIVE
            } else {
                // move to the edge of the tile (tile on the right -> mind the player width)
                position.x = CGFloat((tx << 5) - PW) - COLLISION_GIVE
            }

            if abs(velocity.x) > 0.0 {
                print("collide x")
                velocity.x = 0.0
            }

        }
        return (position, velocity, collide)
    }

    // Shouldn't change f in this function, TODO: put into protocol extension
    func mapcolldet_moveUpward(movePosition position: CGPoint,
                               txl: Int,
                               txc: Int,
                               txr: Int,
                               alignedBlockX: Int,
                               unAlignedBlockX: Int,
                               unAlignedBlockFX: CGFloat) -> (position: CGPoint, collide: Bool) {
        var position = position

        // moving up
        let ty = Int(position.y) / TILESIZE

        //Player hit a solid
        if Map.collide(atPoint: IntPoint(x: alignedBlockX, y: ty), tileType: [.solid], direction: .up) {
            //            print("collided top")
            if AppState.shared.printCollisions {
                print(" | top: \(IntPoint(x: txr, y: ty))")
            }
            position.y = CGFloat((ty << 5) + TILESIZE) + COLLISION_GIVE

            return (position: position, collide: true)
        }

        //Player squeezed around the block
        if Map.collide(atPoint: IntPoint(x: unAlignedBlockX, y: ty), tileType: [.solid], direction: .up, noTrigger: true) {
            print("squeezed")
            position.x = unAlignedBlockFX
        }

        return (position: position, collide: false)
    }

    // Shouldn't change f in this function, TODO: put into protocol extension
    func mapcolldet_moveDownward(movePosition position: CGPoint,
                                 oldPosition: CGPoint,
                                 velocity: CGPoint,
                                 txl: Int,
                                 txc: Int,
                                 txr: Int,
                                 alignedBlockX: Int,
                                 unAlignedBlockX: Int,
                                 unAlignedBlockFX: CGFloat) -> (position: CGPoint, collide: Bool, inAir: Bool, groundPosition: Int) {

        var position = position

        let ty = (Int(position.y) + PH) / TILESIZE


        let collideTiles: TileTypeFlag = [.solid]
        let leftTilePos = IntPoint(x: txl, y: ty)
        let rightTilePos = IntPoint(x: txr, y: ty)

        // Can run over gaps
        let fGapSupport = (velocity.x >= AppState.shared.VELTURBOMOVING || velocity.x <= -AppState.shared.VELTURBOMOVING)
            && (Map.isGap(point: leftTilePos) || Map.isGap(point: rightTilePos))

        let fSolidTileUnderPlayerLeft = Map.collide(atPoint: leftTilePos, tileType: collideTiles, direction: .down)
        let fSolidTileUnderPlayerRight = Map.collide(atPoint: rightTilePos, tileType: collideTiles, direction: .down)
        let fSolidTileUnderPlayer = fSolidTileUnderPlayerLeft || fSolidTileUnderPlayerRight

        let fSolidOnTopUnderPlayerLeft = Map.collide(atPoint: leftTilePos, tileType: [.solid_on_top], direction: .down)
        let fSolidOnTopUnderPlayerRight = Map.collide(atPoint: rightTilePos, tileType: [.solid_on_top], direction: .down)
        let fSolidOnTopUnderPlayer = fSolidOnTopUnderPlayerLeft || fSolidOnTopUnderPlayerRight

        if fSolidTileUnderPlayerLeft || fSolidOnTopUnderPlayerLeft {
            if AppState.shared.printCollisions {
                print(" | d: \(IntPoint(x: txl, y: ty))")
            }
            NotificationCenter.default.post(name: Constants.kNotificationCollide,
                                            object: self,
                                            userInfo: [Constants.kCollideYLeftPosition: CGPoint(x: txl * TILESIZE, y: ty * TILESIZE)])
        }

        if fSolidTileUnderPlayerRight || fSolidOnTopUnderPlayerRight {
            if AppState.shared.printCollisions {
                print(" | d: \(IntPoint(x: txr, y: ty))")
            }
            NotificationCenter.default.post(name: Constants.kNotificationCollide,
                                            object: self,
                                            userInfo: [Constants.kCollideYRightPosition: CGPoint(x: txr * TILESIZE, y: ty * TILESIZE)])
        }

        let inAir: Bool
        if (fSolidOnTopUnderPlayer || fGapSupport) && oldPosition.y + CGFloat(PH) <= CGFloat(ty << 5) {

            // on ground
            // Deal with player down jumping through solid on top tiles

            // we were above the tile in the previous frame
            position.y = CGFloat((ty << 5) - PH) - COLLISION_GIVE
            inAir = false

        } else if fSolidTileUnderPlayer {
            // on ground
            position.y = CGFloat((ty << 5) - PH) - COLLISION_GIVE
            inAir = false
        } else {
            // falling (in air)
            inAir = true
        }

        return (position, !inAir, inAir, ty)
    }



}
