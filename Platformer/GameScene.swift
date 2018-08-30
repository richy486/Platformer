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
}

//let VELMOVINGADD = CGFloat(0.5)
//let VELMOVING = CGFloat(4.0)
let VELMOVINGFRICTION = CGFloat(0.2)
let PH = Int(25)      //Player height
let PW = Int(22)      //Player width
let TILESIZE = Int(32)
let COLLISION_GIVE = CGFloat(0.2) // Move back by this amount when colliding

var keysDown: [KeyCode: Bool] = [
    .left: false,
    .right: false,
    .z: false,
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
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
    [0,0,S,0,0,0,0,0,0,0,0,0,0,0,0,0,S,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    [0,0,S,0,0,0,0,0,0,0,0,0,0,0,0,0,S,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    [S,S,S,S,S,S,0,0,0,0,0,0,0,0,0,0,S,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
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
    
    var i = IntPoint.zero //x, y coordinate (top left of the player rectangle)
    var f = CGPoint.zero
    var fPrecalculatedY = CGFloat(0)
    var iHorizontalPlatformCollision = Int(0)
    var iVerticalPlatformCollision = Int(0)
    var iPlatformCollisionPlayerId = Int(0)
    
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
                if blockVal > 0 {
                    let blockNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: TILESIZE, height: TILESIZE))
                    blockNode.fillColor = .yellow
                    blockNode.strokeColor = .white
                    blockNode.position = CGPoint(x: x * TILESIZE, y: y * TILESIZE)
                    addChild(blockNode)
                    
                    
                }
            }
        }
        
        player = SKShapeNode(rect: CGRect(x: 0, y: 0, width: PW, height: PH))
        player.fillColor = .red
        player.position = CGPoint(x: 10 * TILESIZE, y: (blocks.count - 2) * TILESIZE)
        player.name = "player"
        addChild(player)
        
        fOld = player.position
        
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
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        if keysDown.values.dropFirst().allSatisfy({ $0 == keysDown.values.first }) {
            decreaseVelocity()
        } else if keysDown[.left] == true {
            accelerateX(-1.0)
        } else if keysDown[.right] == true {
            accelerateX(1.0)
        } else if keysDown[.z] == true {
            accelerateX(1.0)
            keysDown[.z] = false
        } else if keysDown[.up] == true {
            accelerateY(-1.0)
        } else if keysDown[.down] == true {
            accelerateY(1.0)
        }
        fOld = player.position
        collision_detection_map()
        
        // Replace this with jump code
        player.position.y += vel.y
    }
    
    func accelerateX(_ direction: CGFloat) {
        vel.x += AppState.shared.VELMOVINGADD * direction
        let maxVel = AppState.shared.VELMOVING
        
        if abs(vel.x) > maxVel {
            vel.x = maxVel * direction
        }
    }
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
        
        
        if vel.y > 0.0 {
            vel.y -= VELMOVINGFRICTION
            
            if vel.y < 0.0 {
                vel.y = 0.0
            }
        } else if vel.y < 0.0 {
            vel.y += VELMOVINGFRICTION
            
            if vel.y > 0.0 {
                vel.y = 0.0
            }
        }
    }
    
    func collision_detection_map() {
//        player.position.x += vel.x //setXf(fx + velx)
        
        let targetPlayerPostition = CGPoint(x: player.position.x + vel.x, y: player.position.y)
        
        
//        fPrecalculatedY = player.position.y + vel.y
        
//        //        let fPlatformVelX = CGFloat(0)
//        //        let fPlatformVelY = CGFloat(0)
//        let fTempY = player.position.y
//
//        // TODO: Moving platform movement
//
//        player.position.y = fTempY
        
        
        
        //  x axis (--)
        
        if player.position.y + CGFloat(PH) >= 0.0 {
            if vel.x > 0.01 {
                // Moving right
                
                var collide = false
                while player.position.x < targetPlayerPostition.x - COLLISION_GIVE && !collide {
                    player.position.x = min(player.position.x + CGFloat(TILESIZE), targetPlayerPostition.x)
                    let result = mapcolldet_move(movePosition: player.position, horizontallyInDirection: 3)
                    player.position = result.position
                    collide = result.collide
//                    let newPosition = mapcolldet_move(movePosition: player.position, horizontallyInDirection: 3)
//                    if newPosition != player.position {
//                        collide = true
//                    }
//                    player.position = newPosition
                }
                
            } else if vel.x < -0.01 {
                // Moving left
                var collide = false
                while player.position.x > targetPlayerPostition.x + COLLISION_GIVE && !collide {
                    player.position.x = max(player.position.x - CGFloat(TILESIZE), targetPlayerPostition.x)
                    let result = mapcolldet_move(movePosition: player.position, horizontallyInDirection: 1)
                    player.position = result.position
                    collide = result.collide
//                    if newPosition != player.position {
//                        collide = true
//                    }
//                    player.position = newPosition
                }
            }
        }
        
        //  then y axis (|)
        
        
        
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
                    print("collide topTile: \(toptile) - (\(tx), \(ty))")
                }
            } else if TileTypeFlag(rawValue: bottomtile).contains(.solid) {
                collideBlockNode.isHidden = false
                let collideBlockPosition = CGPoint(x: tx * TILESIZE, y: ty2 * TILESIZE)
                if collideBlockPosition != collideBlockNode.position {
                    collideBlockNode.position = collideBlockPosition
                    print("collide bottomTile: \(bottomtile) - (\(tx), \(ty2))")
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
    
    
    
}
