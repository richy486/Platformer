//
//  Player.swift
//  Platformer
//
//  Created by Richard Adem on 29/9/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import Foundation

class Player {
    
    var startingPlayerPosition = CGPoint.zero
    
    private var _i = IntPoint.zero
    private(set) var i: IntPoint { //x, y coordinate (top left of the player rectangle)
        set {
            _f = newValue.cgPoint
            _i = newValue
        }
        get {
            return _i
        }
    }
    private var _f = CGPoint.zero
    private(set) var f: CGPoint {
        set {
            _f = newValue
            _i = newValue.intPoint
        }
        get {
            return _f
        }
    }
    
    private(set) var vel: CGPoint = CGPoint.zero //velocity on x, y axis
    private var fOld: CGPoint = CGPoint.zero
    private var oldvel: CGPoint = CGPoint.zero
    
    private(set) var lastGroundPosition: Int = Int.max
//    private var slope_prevtile = IntPoint.zero
    private(set) var slopesBelow: (left: TileTypeFlag?, right: TileTypeFlag?) = (nil, nil)
    
    
    private var lockjump = false
    private(set) var inAir = false
    private(set) var lastSlopeTilePoint: IntPoint?
    
//    private enum Direction: Int {
////        case notIn = -1     // -1 ... we didn't move from slope to slope
////        case exitDown = 0   //  0 ... we left a slope after moving down
////        case exitUp = 1     //  1 ... we left a slope after moving up
//        case stationary
//
//        case up
//        case down
//        case left
//        case right
//
//        case upLeft
//        case upRight
//        case downLeft
//        case doenRight
//    }
    
    func restart() {
        lockjump = false
        inAir = true//false
        lastSlopeTilePoint = nil
        
        f = startingPlayerPosition
        fOld = f
        
        vel = CGPoint.zero
        oldvel = CGPoint.zero
    }
    
    func update(keysDown: [KeyCode: Bool]) {
        
        // Lets add gravity here
        if inAir {
            vel.y = cap(fallingVelocity: vel.y + AppState.shared.GRAVITATION)
        }
        
        var movementDirectionX = CGFloat(0.0)
        if keysDown[.left] == keysDown[.right] {
            // Both left and right down or both left and right up
            movementDirectionX = 0.0
        } else if keysDown[.left] == true {
            movementDirectionX = -1.0
        } else if keysDown[.right] == true {
            movementDirectionX = 1.0
        }
        
        //jump pressed?
        if keysDown[.a] == true {
            // Jump!
            
            if !lockjump {
                if !inAir {
                    if tryFallingThroughPlatform(inDirectionX: movementDirectionX) {
                        
                    } else {
                        lastSlopeTilePoint = nil
                        
                        // This functions was called through tryFallingThroughPlatform in SMW
                        jump(inDirectionX: movementDirectionX, jumpModifier: 1.0)
                    }
                }
            }
        } else {
            enableFreeFall()
        }
        
        if movementDirectionX != 0.0 {
            accelerateX(movementDirectionX)
        } else {
            decreaseVelocity()
        }
        
        fOld = f
        
        collision_detection_map()
    }
    
    // MARK: Movement
    
    // void CPlayer::accelerate(float direction)
    func accelerateX(_ direction: CGFloat) {
        
        var accelVel = CGPoint(x: AppState.shared.VELMOVINGADD, y: 0)
        #if PUSHUPSLOPE
            if let lastSlopeTilePoint = lastSlopeTilePoint {
                let tile = Map.tile(point: lastSlopeTilePoint)
                let sDirection = slopeDirection(forVelocity: CGPoint(x: AppState.shared.VELMOVINGADD * direction, y: 0),
                                                andTile: tile)
                accelVel = accelVel.rotated(radians: sDirection.radians)
                vel += accelVel
            } else {
                accelVel.x *= direction
                vel += accelVel
            }
        #else
            accelVel.x *= direction
            vel += accelVel
        #endif
        
        let maxVel: CGFloat
        if keysDown[.shift] == true {
            maxVel = AppState.shared.VELTURBOMOVING
        } else {
            maxVel = AppState.shared.VELMOVING
        }
        if abs(vel.x) > maxVel {
            vel.x = maxVel * direction
        }
    }
    
    // for testing
    //    func accelerateY(_ direction: CGFloat) {
    //        vel.y += AppState.shared.VELMOVINGADD * direction
    //        let maxVel: CGFloat = AppState.shared.VELMOVING
    //
    //        if abs(vel.y) > maxVel {
    //            vel.y = maxVel * direction
    //        }
    //    }
    
    func decreaseVelocity() {
        if vel.x > 0.0 {
            vel.x -= VELMOVINGFRICTION
            
            if vel.x < 0.0 {
                vel.x = 0.0
            }
        } else if vel.x < 0.0 {
            vel.x += VELMOVINGFRICTION
            
            if vel.x > 0.0 {
                vel.x = 0.0
            }
        }
    }
    
    func jump(inDirectionX movementDirectionX: CGFloat, jumpModifier: CGFloat) {
        lockjump = true
        
        if abs(vel.x) > AppState.shared.VELMOVING && movementDirectionX != 0 && keysDown[.shift] == true {
            vel.y = -AppState.shared.VELTURBOJUMP * jumpModifier
        } else {
            vel.y = -AppState.shared.VELJUMP * jumpModifier
        }
        
        
        inAir = true;
    }
    
    func enableFreeFall() {
        
        lockjump = false //the jump key is not pressed: the player may jump again if he is on the ground
        if vel.y < -AppState.shared.VELSTOPJUMP {
            vel.y = -AppState.shared.VELSTOPJUMP
        }
    }
    
    func tryFallingThroughPlatform(inDirectionX movementDirectionX: CGFloat) -> Bool {
        
        // TODO: fall through code
        let fallThrough = false
        return fallThrough
    }
    
    // This only works for 45º slopes
    private var slopeMoveDirection: Direction {
        var direction: Direction = .stationary
        if let lastSlopeTile = lastSlopeTilePoint {
            if Map.tile(point: lastSlopeTile).intersection(.slope_right).rawValue != 0 {
                direction = vel.x > 0
                    ? .downRight
                    : .upRight
                
            } else if Map.tile(point: lastSlopeTile).contains(.slope_left) {
                direction = vel.x < 0
                    ? .downLeft
                    : .upLeft
            }
        }
        return direction
    }
    
    private func slopeDirection(forVelocity velocity: CGPoint, andTile tile: TileTypeFlag) -> Direction {
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
    
    // MARK: Collisions
    
    // Can change f in this function
    private func collision_detection_map() {
        
        if AppState.shared.printCollisions {
            print("--- frame ---")
        }
        
        let targetPlayerPostition = CGPoint(x: f.x + vel.x, y: f.y + vel.y)
        
        slopesBelow = Map.slopesBelow(position: targetPlayerPostition)
        
        let slopeResult = collision_slope(movePosition: f, velocity: vel, forTile: nil, force: lastSlopeTilePoint != nil)
        if slopeResult.collide {
            f.y = slopeResult.position.y
            inAir = false
            lastSlopeTilePoint = slopeResult.collideTile
//            #if UNKNOWN
            vel.y = CGFloat(1) // What is this for?
//            #endif
        }
//        else {
//            lastSlopeTilePoint = nil
//        }
        
        
//        #if SECOND_CHECK
        else if let lastSlopeTilePoint = lastSlopeTilePoint {
            let lastSlopeTile = Map.tile(point: lastSlopeTilePoint)
            var nextSlopeTilePoint = lastSlopeTilePoint
            let slopeDir = slopeDirection(forVelocity: vel, andTile: lastSlopeTile)

            // We know it's diagonal by now
            if slopeDir != .stationary {
                // If we left a slope and now are on another slope
//                nextSlopeTilePoint.x += vel.x > 0
//                    ? 1
//                    : -1
                
//
                var potentialPosition = f
                
                
//                if vel.x > 0 {
////                    potentialPosition.x = CGFloat(slopeResult.collideTile.x * TILESIZE - PH - 1)
//                    nextSlopeTilePoint.x += 1
//                } else if vel.x < 0 {
//                    nextSlopeTilePoint.x -= 1
//                }
                
                // y    potentialPosition
                // s    s
                // ts   slopeResult.collideTile
                
                var s = IntPoint(x: Int(f.x + CGFloat(PW)/2 + vel.x), y: 0)
                if slopeDir.contains(.up) {
                    potentialPosition.y = CGFloat(slopeResult.collideTile.y * TILESIZE - PH - 1)
                    s.y = Int(potentialPosition.y) + PH
//                    nextSlopeTilePoint.y -= 1
//                    nextSlopeTilePoint.y = Int(CGFloat(lastSlopeTilePoint.y*TILESIZE - PH - 1))/TILESIZE
                } else if slopeDir.contains(.down) {
                    potentialPosition.y = CGFloat((slopeResult.collideTile.y + 1) * TILESIZE - PH - 1)
                    s.y = Int(potentialPosition.y) + PH + TILESIZE
//                    nextSlopeTilePoint.y += 1
//                    nextSlopeTilePoint.y += Int(CGFloat((lastSlopeTilePoint.y+1)*TILESIZE - PH - 1))/TILESIZE
                }

                // Don't check if we are colliding with slode, since `lastSlopeTilePoint` is
                // not nil then we are on a slope and just update the the player position
                
                
                let collideTile = IntPoint(x: s.x / TILESIZE, y: s.y / TILESIZE)
                
                let t = Map.tile(point: collideTile)
                
                if t.contains(.slope_right) {
                    // ◺
                    let yGround = (collideTile.y+1) * TILESIZE       // y pixel coordinate of the ground of the tile
                    let inside = TILESIZE - (s.x%TILESIZE)  // minus how far sx is inside the tile (16 pixels in the exapmle)
                    
                    f.x += vel.x
                    // PH: minus the height (sx is located at the bottom of the player, but y is at the top)
                    // -1: we don't want to stick in a tile, this would cause complications in the next frame
                    f.y = CGFloat(yGround - inside - PH - 1)
                    
                    return
                } else if t.contains(.slope_left) {
                    // ◿
                    f.x += vel.x
                    f.y = CGFloat((collideTile.y+1)*TILESIZE - s.x%TILESIZE - PH - 1)
                    return
                }
                    
                    
//                if Map.tile(point: nextSlopeTilePoint).intersection([.slope_left, .slope_right]).rawValue != 0 {
//
//                    let secondResult = collision_slope(movePosition: f,
//                                                       velocity: vel,
//                                                       forTile: nextSlopeTilePoint,
//                                                       force: true)
//                    let secondResult = adjustToSlope(potentialPosition: potentialPosition)
//                    f.x += vel.x
//                    if secondResult.collide {
//                        f.x += vel.x
//                        f.y = secondResult.position.y
//
//                        inAir = false
//                        vel.y = 1
////                        self.lastSlopeTilePoint = secondResult.collideTile
//                        return
//                    }
//                }
                
            }
            self.lastSlopeTilePoint = nil
        }
//        #endif

        
        
        
        
        
        
        // X axis ⇄ Horizontal
        
        if vel.x > 0.01 {
            // Moving right
            
            let size = CGSize(width: PW, height: slopesBelow.right == nil ? PH : PH_SLOPE)
            
            var collide = false
            while f.x < targetPlayerPostition.x - COLLISION_GIVE && !collide {
                f.x = min(f.x + CGFloat(TILESIZE), targetPlayerPostition.x)
                let result = mapcolldet_moveHorizontal(movePosition: f, horizontallyInDirection: 3, size: size)
                f = result.position
                collide = result.collide
            }
            
        } else if vel.x < -0.01 {
            // Moving left
            
            let size = CGSize(width: PW, height: slopesBelow.left == nil ? PH : PH_SLOPE)
            
            var collide = false
            while f.x > targetPlayerPostition.x + COLLISION_GIVE && !collide {
                f.x = max(f.x - CGFloat(TILESIZE), targetPlayerPostition.x)
                let result = mapcolldet_moveHorizontal(movePosition: f, horizontallyInDirection: 1, size: size)
                f = result.position
                collide = result.collide
            }
        }
        
        // Y axis ⇅ Vertical if not on a slope
        if !slopeResult.collide {
            let iPlayerL = i.x / TILESIZE
            let iPlayerC = (i.x + HALFPW) / TILESIZE
            let iPlayerR = (i.x + PW) / TILESIZE
            
            let txl = slopesBelow.left == nil ? iPlayerL : iPlayerC
            let txc = iPlayerC
            let txr = slopesBelow.right == nil ? iPlayerR : iPlayerC
            
            var alignedBlockX = 0
            var unAlignedBlockX = 0
            var unAlignedBlockFX = CGFloat(0)
            
            let overlaptxl = (txl << 5) + TILESIZE + 1
            
            if i.x + HALFPW < overlaptxl {
                alignedBlockX = txl
                unAlignedBlockX = txr
                unAlignedBlockFX = CGFloat((txr << 5) - PW) - COLLISION_GIVE
            } else {
                alignedBlockX = txr
                unAlignedBlockX = txl
                unAlignedBlockFX = CGFloat((txl << 5) + TILESIZE) + COLLISION_GIVE
            }
            
            if vel.y < -0.01 {
                
                //moving up
                var collide = false
                var potentialPosition = f
                while f.y > targetPlayerPostition.y + COLLISION_GIVE && !collide {
                    f.y = max(f.y - CGFloat(TILESIZE), targetPlayerPostition.y)
                    let result = mapcolldet_moveUpward(movePosition: f,
                        txl: txl,
                        txc: txc,
                        txr: txr,
                        alignedBlockX: alignedBlockX,
                        unAlignedBlockX: unAlignedBlockX,
                        unAlignedBlockFX: unAlignedBlockFX)
                    collide = result.collide
                    potentialPosition = result.position
                }
                if collide && vel.y < 0.0 {
                    print("bounce")
                    vel.y = -vel.y * BOUNCESTRENGTH
                }
                f = potentialPosition
            } else {
                //moving down / on ground
                var collide = false
                var potentialPosition = self.f
                var inAir = self.inAir
                var groundPosition: Int = lastGroundPosition
                while f.y < targetPlayerPostition.y - COLLISION_GIVE && !collide {
                    f.y = min(f.y + CGFloat(TILESIZE), targetPlayerPostition.y)
                    let result = mapcolldet_moveDownward(movePosition: f,
                                                         txl: txl,
                                                         txc: txc,
                                                         txr: txr,
                                                         alignedBlockX: alignedBlockX,
                                                         unAlignedBlockX: unAlignedBlockX,
                                                         unAlignedBlockFX: unAlignedBlockFX)
                    collide = result.collide
                    potentialPosition = result.position
                    inAir = result.inAir
                    groundPosition = result.groundPosition
                }
                self.f = potentialPosition
                self.inAir = inAir
                
                if collide && abs(lastGroundPosition - groundPosition) > 1 {
                    lastGroundPosition = groundPosition
                }
            }
        }
    
        // Reset gravity if on the ground
        #if UNKNOWN
        if !inAir {
            vel.y = AppState.shared.GRAVITATION
        }
        #endif
    }
    
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
            
            if position.y + vel.y >= resultingPosition.y || force{
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
            if position.y + vel.y >= resultingPosition.y  || force {
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
    func mapcolldet_moveHorizontal(movePosition position: CGPoint, horizontallyInDirection direction: Int, size: CGSize) -> (position: CGPoint, collide: Bool) {
        // left 1
        // right 3
        var position = position
        
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
            
            if abs(vel.x) > 0.0 {
                print("collide x")
                vel.x = 0.0
            }
            if abs(oldvel.x) > 0.0 {
                oldvel.x = 0.0
            }
        }
        return (position, collide)
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
        
        inAir = true
        
        return (position: position, collide: false)
    }
    
    // Shouldn't change f in this function, TODO: put into protocol extension
    func mapcolldet_moveDownward(movePosition position: CGPoint,
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
        let fGapSupport = (vel.x >= AppState.shared.VELTURBOMOVING || vel.x <= -AppState.shared.VELTURBOMOVING)
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
        if (fSolidOnTopUnderPlayer || fGapSupport) && fOld.y + CGFloat(PH) <= CGFloat(ty << 5) {
            
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
    
    
    
    // ObjectBase.h
    private func cap(fallingVelocity velY: CGFloat) -> CGFloat {
        if velY > MAXVELY {
            return MAXVELY
        }
        return velY
    }
}
