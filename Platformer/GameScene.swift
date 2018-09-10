//
//  GameScene.swift
//  Platformer
//
//  Created by Richard Adem on 23/8/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import SpriteKit

enum KeyCode: Int {
    case left = 123
    case right = 124
    case down = 125
    case up = 126
    case z = 6
    case a = 0
}

public struct IntPoint {
    public var x: Int
    public var y: Int
    public init() {
        x = 0
        y = 0
    }
    public init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    public static var zero: IntPoint {
        get {
            return IntPoint()
        }
    }
    
    var cgPoint: CGPoint {
        return CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
}

extension CGPoint {
    var intPoint: IntPoint {
        return IntPoint(x: Int(x), y: Int(y))
    }
}

//let VELMOVINGADD = CGFloat(0.5)
//let VELMOVING = CGFloat(4.0)
let VELMOVINGFRICTION = CGFloat(0.2)
let PH = Int(25)      //Player height
let PW = Int(22)      //Player width
let HALFPH = Int(12)
let HALFPW = Int(11)
let TILESIZE = Int(32)
let COLLISION_GIVE = CGFloat(0.2) // Move back by this amount when colliding
//let VELSTOPJUMP = CGFloat(5.0)
//let VELJUMP = CGFloat(9.0)    //velocity for jumping
let BOUNCESTRENGTH = CGFloat(0.5)
//let GRAVITATION = CGFloat(0.40)
let MAXVELY = CGFloat(20.0)


var keysDown: [KeyCode: Bool] = [
    .left: false,
    .right: false,
    .z: false,
    .a: false,
    .up: false,
    .down: false
]


struct TileTypeFlag: OptionSet {
    
    let rawValue: Int
    
    static let nonsolid = TileTypeFlag(rawValue: 1 << 0)
    static let solid = TileTypeFlag(rawValue: 1 << 1)
    static let solid_on_top = TileTypeFlag(rawValue: 1 << 2)
}

let S = TileTypeFlag.solid.rawValue
let T = TileTypeFlag.solid_on_top.rawValue

let blocks = [
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
    [0,0,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,0,0,0,0,0,0,0,S],
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S,0,0,0,0,0,S],
    [0,0,S,0,0,0,S,S,S,0,S,0,S,0,S,S,S,S,0,S,0,S,0,S,0,S,0,0,0,0,0,S],
    [0,0,S,S,0,0,0,0,0,S,S,S,S,0,S,0,0,0,S,0,S,T,T,S,0,S,0,0,0,0,0,S],
    [0,0,0,S,S,S,0,S,0,0,0,0,0,S,0,0,0,0,0,0,0,0,0,0,T,0,0,0,0,0,0,S],
    [0,0,0,0,0,0,S,0,0,S,S,S,S,0,0,0,0,0,0,T,T,0,T,0,T,0,T,0,T,0,T,S],
    [0,0,0,0,0,0,0,0,S,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
    [0,0,0,0,S,S,S,S,0,0,0,0,0,0,0,0,0,0,0,T,T,0,0,0,0,0,0,0,S,0,S,S],
    [0,0,S,0,0,0,0,0,0,0,0,0,0,0,S,S,S,0,T,T,T,0,0,0,0,0,0,0,0,0,0,0],
    [0,0,S,0,0,0,0,0,0,0,0,0,0,0,0,0,S,0,0,0,0,0,0,0,0,0,0,0,S,S,S,0],
    [S,S,S,S,S,S,0,0,0,0,0,0,0,0,0,0,S,0,0,0,0,0,0,0,0,0,0,0,T,T,0,0],
    [S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S]
]

func map(x: Int, y: Int) -> Int {
    
//    let offset = blocks.count - 1
//    let offsetY = offset - y
    
    guard y >= 0 && y < blocks.count else {
        return -1
    }
    let xBlocks = blocks[y]
    guard x >= 0 && x < xBlocks.count else {
        return -1
    }
    
    return xBlocks[x]
}

func posToTilePos(_ position: CGPoint) -> (x: Int, y: Int) {
    let x = Int(position.x + 0.5) / TILESIZE
    let y = (Int(position.y + 0.5) / TILESIZE) //+ 1
    
    return (x, y)
}

func posToTile(_ position: CGPoint) -> Int {
//    let x = Int(position.x + 0.5) / TILESIZE
//    let y = Int(position.y + 0.5) / TILESIZE
    
    let tilePos = posToTilePos(position)
    
    return map(x: tilePos.x, y: tilePos.y)
}

class GameScene: SKScene {
    
    private var player: SKShapeNode!
    var vel: CGPoint = CGPoint.zero //velocity on x, y axis
    var fOld: CGPoint = CGPoint.zero
    var oldvel: CGPoint = CGPoint.zero
    
    private var _i = IntPoint.zero
    var i: IntPoint { //x, y coordinate (top left of the player rectangle)
        set {
            _f = newValue.cgPoint
            _i = newValue
        }
        get {
            return _i
        }
    }
    private var _f = CGPoint.zero
    var f: CGPoint {
        set {
            _f = newValue
            _i = newValue.intPoint
        }
        get {
            return _f
        }
    }
//    var fPrecalculatedY = CGFloat(0)
    var iHorizontalPlatformCollision = Int(0)
    var iVerticalPlatformCollision = Int(0)
    var iPlatformCollisionPlayerId = Int(0)
    
    var lockjump = false
    var inair = false
    
    var fallthroughTile = false // bool fallthrough;
    
    let selectedBlockNode: SKShapeNode = {
        let node = SKShapeNode(rect: CGRect(x: 0, y: 0, width: TILESIZE, height: TILESIZE))
        node.fillColor = .clear
        node.strokeColor = .blue
        node.position = CGPoint(x: 0, y: 0)
        node.isHidden = true
        return node
    }()
    
    let collideBlockNode: SKShapeNode = {
        let node = SKShapeNode(rect: CGRect(x: 0, y: 0, width: TILESIZE, height: TILESIZE))
        node.fillColor = .clear
        node.strokeColor = .orange
        node.position = CGPoint(x: 0, y: 0)
        node.isHidden = true
        return node
    }()
    
//    var keyCode: KeyCode? = nil
    
    // Because we want the origin at top-left we add this `masterNode` and use that instead of the scene.
    // https://stackoverflow.com/a/38733108/667834
    var masterNode:SKSpriteNode! = nil
    override func addChild(_ node: SKNode)
    {
        if masterNode == nil
        {
            masterNode = SKSpriteNode()
            masterNode.position    = CGPoint(x:0, y:size.height)
            masterNode.anchorPoint = CGPoint.zero
            masterNode.yScale      = -1
            super.addChild(masterNode)
        }
        masterNode.addChild(node)
    }
    
    override func didMove(to view: SKView) {
        
        // Blocks
        for (y, xBlocks) in blocks.enumerated() {
            for (x, blockVal) in xBlocks.enumerated() {
                
//                guard let blockType = TileTypeFlag(rawValue: blockVal) else {
//                    continue
//                }
                
                switch blockVal {
                case S:
                    let blockNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: TILESIZE, height: TILESIZE))
                    blockNode.fillColor = .yellow
                    blockNode.strokeColor = .white
                    blockNode.position = CGPoint(x: x * TILESIZE, y: y * TILESIZE)
                    addChild(blockNode)
                case T:
                    let blockNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: TILESIZE, height: 5))
                    blockNode.fillColor = .yellow
                    blockNode.strokeColor = .white
                    blockNode.position = CGPoint(x: x * TILESIZE, y: y * TILESIZE)
                    addChild(blockNode)
                default:
                    continue
                }
            }
        }
        
        f = CGPoint(x: 10 * TILESIZE, y: (blocks.count - 2) * TILESIZE)
        player = SKShapeNode(rect: CGRect(x: 0, y: 0, width: PW, height: PH))
        player.fillColor = .red
        player.position = f
        player.name = "player"
        addChild(player)
        
        fOld = f
        
        addChild(selectedBlockNode)
        addChild(collideBlockNode)
        
        
    }
    
    @objc static override var supportsSecureCoding: Bool {
        // SKNode conforms to NSSecureCoding, so any subclass going
        // through the decoding process must support secure coding
        get {
            return true
        }
    }
    
    override func keyDown(with event: NSEvent) {
        if let keyCode = KeyCode(rawValue: Int(event.keyCode)) {
            keysDown[keyCode] = true
        } else {
            print("unused key code: \(event.keyCode)")
        }
    }
    
    override func keyUp(with event: NSEvent) {
        if let keyCode = KeyCode(rawValue: Int(event.keyCode)) {
            keysDown[keyCode] = false
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: masterNode)
        let tile = posToTile(location)
        let tilePos = posToTilePos(location)
        
        print("location: \(location) tile: \(tile) - (\(tilePos.x), \(tilePos.y))")
        
        selectedBlockNode.isHidden = false
        selectedBlockNode.position = CGPoint(x: tilePos.x * TILESIZE, y: tilePos.y * TILESIZE)
        
    }
    
    // void CPlayer::move()
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        var movementDirectionX = CGFloat(0.0)
//        if keysDown.values.dropFirst().allSatisfy({ $0 == keysDown.values.first }) {
        if keysDown[.left] == keysDown[.right] {
            // Both left and right down or both left and right up
            movementDirectionX = 0.0
        } else if keysDown[.left] == true {
//            accelerateX(-1.0)
            movementDirectionX = -1.0
        } else if keysDown[.right] == true {
//            accelerateX(1.0)
            movementDirectionX = 1.0
        } else if keysDown[.z] == true {
//            accelerateX(1.0)
            movementDirectionX = 1.0
            keysDown[.z] = false
        }
//        else if keysDown[.up] == true {
//            accelerateY(-1.0)
//        } else if keysDown[.down] == true {
//            accelerateY(1.0)
//        }
        
        
        //jump pressed?
        if keysDown[.a] == true {
            // Jump!

            if !lockjump {
                if !inair {
                    if tryFallingThroughPlatform(inDirectionX: movementDirectionX) {

                    } else {
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
        
//        // Replace this with jump code
//        player.position.y += vel.y
        
        player.position = f
    }
    
    // void CPlayer::accelerate(float direction)
    func accelerateX(_ direction: CGFloat) {
        vel.x += AppState.shared.VELMOVINGADD * direction
        let maxVel = AppState.shared.VELMOVING
        
        if abs(vel.x) > maxVel {
            vel.x = maxVel * direction
        }
    }
    
    // for testing
    func accelerateY(_ direction: CGFloat) {
        vel.y += AppState.shared.VELMOVINGADD * direction
        let maxVel = AppState.shared.VELMOVING
        
        if abs(vel.y) > maxVel {
            vel.y = maxVel * direction
        }
    }
    
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
        
        
//        if vel.y > 0.0 {
//            vel.y -= VELMOVINGFRICTION
//
//            if vel.y < 0.0 {
//                vel.y = 0.0
//            }
//        } else if vel.y < 0.0 {
//            vel.y += VELMOVINGFRICTION
//
//            if vel.y > 0.0 {
//                vel.y = 0.0
//            }
//        }
    }
    
//    void CPlayer::Jump(short iMove, float jumpModifier, bool fKuriboBounce)
    func jump(inDirectionX movementDirectionX: CGFloat, jumpModifier: CGFloat) {
        lockjump = true
        
        vel.y = -AppState.shared.VELJUMP * jumpModifier;
        inair = true;
        
//        //Need to help the player off the platform otherwise it will collide with them again
//        platform = nil
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
    
    func collision_detection_map() {
//        player.position.x += vel.x //setXf(fx + velx)
        
        vel.y = cap(fallingVelocity: vel.y + AppState.shared.GRAVITATION)
        
        let targetPlayerPostition = CGPoint(x: f.x + vel.x, y: f.y + vel.y)
        
        
//        fPrecalculatedY = player.position.y + vel.y
        
//        //        let fPlatformVelX = CGFloat(0)
//        //        let fPlatformVelY = CGFloat(0)
//        let fTempY = player.position.y
//
//        // TODO: Moving platform movement
//
//        player.position.y = fTempY
        
        
        
        //  x axis (--)
        
        if f.y + CGFloat(PH) >= 0.0 {
            if vel.x > 0.01 {
                // Moving right
                
                var collide = false
                while f.x < targetPlayerPostition.x - COLLISION_GIVE && !collide {
                    f.x = min(f.x + CGFloat(TILESIZE), targetPlayerPostition.x)
                    let result = mapcolldet_move(movePosition: f, horizontallyInDirection: 3)
                    f = result.position
                    collide = result.collide
//                    let newPosition = mapcolldet_move(movePosition: f, horizontallyInDirection: 3)
//                    if newPosition != f {
//                        collide = true
//                    }
//                    f = newPosition
                }
                
            } else if vel.x < -0.01 {
                // Moving left
                var collide = false
                while f.x > targetPlayerPostition.x + COLLISION_GIVE && !collide {
                    f.x = max(f.x - CGFloat(TILESIZE), targetPlayerPostition.x)
                    let result = mapcolldet_move(movePosition: f, horizontallyInDirection: 1)
                    f = result.position
                    collide = result.collide
//                    if newPosition != f {
//                        collide = true
//                    }
//                    f = newPosition
                }
            }
        }
        
        //  then y axis (|)
        let iPlayerL = i.x
        let iPlayerC = i.x + HALFPW
        let iPlayerR = i.x + PW
        
        let txl = iPlayerL / TILESIZE
        let txc = iPlayerC / TILESIZE
        let txr = iPlayerR / TILESIZE
        
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
//            var potentialVelocity = vel
            var potentialPosition = f
//            fPrecalculatedY = player.position.y + vel.y
            
//            var count = 0
            while f.y > targetPlayerPostition.y + COLLISION_GIVE && !collide {

                f.y = max(f.y - CGFloat(TILESIZE), targetPlayerPostition.y)
//            f.y = targetPlayerPostition.y
                let result = mapcolldet_moveUpward(movePosition: f,
//                                                   velocity: vel,
                                                   txl: txl,
                                                   txc: txc,
                                                   txr: txr,
                                                   alignedBlockX: alignedBlockX,
                                                   unAlignedBlockX: unAlignedBlockX,
                                                   unAlignedBlockFX: unAlignedBlockFX)
                collide = result.collide
                potentialPosition = result.position
//                potentialVelocity = result.velocity
                
//                count += 1
            }
            if collide && vel.y < 0.0 {
                print("bounce")
                vel.y = -vel.y * BOUNCESTRENGTH
            }
            f = potentialPosition
//            vel = potentialVelocity
//            if count > 0 {
//                print("up count: \(count)")
//            }
            
            
        } else {
            //moving down / on ground
            var collide = false
//            var potentialVelocity = vel
            var potentialPosition = f
            while f.y < targetPlayerPostition.y - COLLISION_GIVE && !collide {
                f.y = min(f.y + CGFloat(TILESIZE), targetPlayerPostition.y)
//            f.y = targetPlayerPostition.y
                let result = mapcolldet_moveDownward(movePosition: f,
//                                                     velocity: vel,
                                                     txl: txl,
                                                     txc: txc,
                                                     txr: txr,
                                                     alignedBlockX: alignedBlockX,
                                                     unAlignedBlockX: unAlignedBlockX,
                                                     unAlignedBlockFX: unAlignedBlockFX)
//                f = result.position
                collide = result.collide
                potentialPosition = result.position
//                potentialVelocity = result.velocity
            }
            f = potentialPosition
//            vel = potentialVelocity
//            if collide {
////                vel.y += GRAVITATION
//                vel.y = GRAVITATION
//            } else {
//                vel.y = cap(fallingVelocity: GRAVITATION + vel.y)
//
//            }
        }
        
        // if (!platform) {
        fallthroughTile = false
    }
    
    func mapcolldet_move(movePosition position: CGPoint, horizontallyInDirection direction: Int) -> (position: CGPoint, collide: Bool) {
        // left 1
        // right 3
        //        let counter_direction = direction == 1 ? 3 : 1
        var position = position
        
        //Could be optimized with bit shift >> 5
        let ty = Int(position.y) / TILESIZE
        let ty2 = (Int(position.y) + PH) / TILESIZE
        var tx = -1
        
        //        var isMoveKeyDown = false
        //        if direction == 1 {
        //            isMoveKeyDown = keyCode == .left
        //        } else {
        //            isMoveKeyDown = keyCode == .right
        //        }
        
        if direction == 1 {
            //moving left
            tx = Int(position.x) / TILESIZE;
        } else {
            //moving right
            tx = (Int(position.x) + PW) / TILESIZE;
        }
        
        
        
        let toptile = map(x: tx, y: ty)
        let bottomtile = map(x: tx, y: ty2)
        
//        print("mapcolldet_moveHorizontally: \(tx), \(ty) -> \(toptile)")
        
        //collide with solid, ice, and death and all sides death
        var collide = false
        if TileTypeFlag(rawValue: toptile).contains(.solid) || TileTypeFlag(rawValue: bottomtile).contains(.solid) {
            
            collide = true
            // Debug
            if TileTypeFlag(rawValue: toptile).contains(.solid) {
                collideBlockNode.isHidden = false
                let collideBlockPosition = CGPoint(x: tx * TILESIZE, y: ty * TILESIZE)
                if collideBlockPosition != collideBlockNode.position {
                    collideBlockNode.position = collideBlockPosition
//                    print("collide topTile: \(toptile) - (\(tx), \(ty))")
                }
            } else if TileTypeFlag(rawValue: bottomtile).contains(.solid) {
                collideBlockNode.isHidden = false
                let collideBlockPosition = CGPoint(x: tx * TILESIZE, y: ty2 * TILESIZE)
                if collideBlockPosition != collideBlockNode.position {
                    collideBlockNode.position = collideBlockPosition
//                    print("collide bottomTile: \(bottomtile) - (\(tx), \(ty2))")
                }
            }
            
            
            if direction == 1 {
                // move to the edge of the tile
                //                setXf( (float) ((tx << 5) + TILESIZE) + 0.2f);
                position.x = CGFloat((tx << 5) + TILESIZE) + COLLISION_GIVE
            } else {
                // move to the edge of the tile (tile on the right -> mind the player width)
                //                setXf((float)((tx << 5) - PW) - 0.2f);
                position.x = CGFloat((tx << 5) - PW) - COLLISION_GIVE
            }
            
            // Why save the old here? shouln't the one in update() be enough
            // fOld.x = position.x
            
            if abs(vel.x) > 0.0 {
                vel.x = 0.0
            }
            
            if abs(oldvel.x) > 0.0 {
                oldvel.x = 0.0
            }
            
            //            flipsidesifneeded();
        }
        return (position, collide)
    }
    
    
    func mapcolldet_moveUpward(movePosition position: CGPoint,
//                               velocity: CGPoint,
                               txl: Int,
                               txc: Int,
                               txr: Int,
                               alignedBlockX: Int,
                               unAlignedBlockX: Int,
                               unAlignedBlockFX: CGFloat) -> (position: CGPoint, collide: Bool) {
        var position = position
//        var velocity = velocity
        
        // moving up
        fallthroughTile = false
        
        // fPrecalculatedY is set in collision_detection_map
        let ty = Int(position.y) / TILESIZE
        
        //Player hit a solid
        let alignedTileType = map(x: alignedBlockX, y: ty)
        
        if TileTypeFlag(rawValue: alignedTileType).contains(.solid) {
            print("collided top")
            position.y = CGFloat((ty << 5) + TILESIZE) + COLLISION_GIVE
            // fOld.y = f.y - 1.0 // Not sure what this is for
            
//            if velocity.y < 0.0 {
//                velocity.y = -velocity.y * BOUNCESTRENGTH
//            }
            
            return (position, true)
        }
        
        //Player squeezed around the block
        let unalignedTileType = map(x: unAlignedBlockX, y: ty)
        if TileTypeFlag(rawValue: unalignedTileType).contains(.solid) {
            print("squeezed")
            position.x = unAlignedBlockFX
            // fOld.x = f.x // Not sure what this is for
            
//            position.y = fPrecalculatedY
//            velocity.y += GRAVITATION
        } else {
            print("fall?")
//            position.y = fPrecalculatedY
//            velocity.y += GRAVITATION
        }
        
        inair = true
        
        return (position, false)
    }
    
//    void CPlayer::mapcolldet_moveDownward(short txl, short txc, short txr,
//    short alignedBlockX, short unAlignedBlockX, float unAlignedBlockFX)
    
    func mapcolldet_moveDownward(movePosition position: CGPoint,
//                                 velocity: CGPoint,
                                 txl: Int,
                                 txc: Int,
                                 txr: Int,
                                 alignedBlockX: Int,
                                 unAlignedBlockX: Int,
                                 unAlignedBlockFX: CGFloat) -> (position: CGPoint, collide: Bool) {
        
        var position = position
//        var velocity = velocity
        
        let ty = (Int(position.y) + PH) / TILESIZE
        
        let lefttile = map(x: txl, y: ty)
        let righttile = map(x: txr, y: ty)
        
        let fGapSupport = false // VELTURBOMOVING
        
        let fSolidTileUnderPlayer = TileTypeFlag(rawValue: lefttile).contains(.solid) ||
                                    TileTypeFlag(rawValue: righttile).contains(.solid)
        
//        if (lefttile & tile_flag_solid_on_top || righttile & tile_flag_solid_on_top || fGapSupport) &&
//            fOldY + PH <= (ty << 5)
        if (TileTypeFlag(rawValue: lefttile).contains(.solid_on_top) ||
                TileTypeFlag(rawValue: righttile).contains(.solid_on_top) ||
                fGapSupport) &&
            fOld.y + CGFloat(PH) <= CGFloat(ty << 5) {
            
            // on ground
            // Deal with player down jumping through solid on top tiles
            
            if fallthroughTile && !fSolidTileUnderPlayer {
                position.y = CGFloat((ty << 5) - PH) + COLLISION_GIVE
                inair = true
                
            } else {
                // we were above the tile in the previous frame
                position.y = CGFloat((ty << 5) - PH) - COLLISION_GIVE
//                vel.y = GRAVITATION
                
                // if (!platform) {
                inair = false
            }
            
            // fOld.y = f.y - GRAVITATION // Do we need this?
            if iVerticalPlatformCollision == 0 {
                // Kill player
            }
            return (position, !inair)
        }
        
        if fSolidTileUnderPlayer {
            // on ground
            
            position.y = CGFloat((ty << 5) - PH) - COLLISION_GIVE
//            vel.y = GRAVITATION //1 so we test against the ground again int the next frame (0 would test against the ground in the next+1 frame)
            
            //if (!platform) {
            inair = false
        } else {
            // falling (in air)
//            position.y = fPrecalculatedY
//            vel.y = cap(fallingVelocity: GRAVITATION + vel.y)
            
            //if (!platform) {
            inair = true;
        }
        
        
         return (position, !inair)
    }
    
    // ObjectBase.h
    private func cap(fallingVelocity vel: CGFloat) -> CGFloat {
        if vel > MAXVELY {
            return MAXVELY
        }
        return vel
    }
}
