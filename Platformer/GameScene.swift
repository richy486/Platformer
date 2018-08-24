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

var keysDown: [KeyCode: Bool] = [
    .left: false,
    .right: false
]


struct TileTypeFlag: OptionSet {
    
    let rawValue: Int
    
    static let nonsolid = TileTypeFlag(rawValue: 1 << 0)
    static let solid = TileTypeFlag(rawValue: 1 << 1)
    static let solid_on_top = TileTypeFlag(rawValue: 1 << 2)
}

let S = TileTypeFlag.solid.rawValue

let blocks = [
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
    [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
    [0,0,S,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S,0,0,0,0,0,0,S],
    [0,0,S,0,0,0,S,0,0,0,0,0,0,0,0,0,S,S,0,0,0,0,0,0,S],
    [S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S],
    [S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S]
]

func map(x: Int, y: Int) -> Int {
    
    let offset = blocks.count - 1
    let offsetY = offset - y
    
    guard offsetY >= 0 && offsetY < blocks.count else {
        return 0
    }
    let xBlocks = blocks[offsetY]
    guard x >= 0 && x < xBlocks.count else {
        return 0
    }
    
    return xBlocks[x]
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
    
//    var keyCode: KeyCode? = nil
    
    override func didMove(to view: SKView) {
        
        for (y, xBlocks) in blocks.reversed().enumerated() {
            for (x, blockVal) in xBlocks.enumerated() {
                if blockVal > 0 {
                    let blockNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: TILESIZE, height: -TILESIZE))
                    blockNode.fillColor = .yellow
                    blockNode.strokeColor = .white
                    blockNode.position = CGPoint(x: x * TILESIZE, y: y * TILESIZE)
                    addChild(blockNode)
                    
                    
                }
            }
        }
        
        player = SKShapeNode(rect: CGRect(x: 0, y: 0, width: PW, height: -PH))
        player.fillColor = .red
        player.position = CGPoint(x: 10 * TILESIZE, y: 2 * TILESIZE)
        player.name = "player"
        addChild(player)
        
        fOld = player.position
        
        // Blocks
        
        
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
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        if keysDown[.left] == keysDown[.right] {
            decreaseVelocity()
        } else if keysDown[.left] == true {
            accelerate(-1.0)
        } else if keysDown[.right] == true {
            accelerate(1.0)
        }
        fOld = player.position
        collision_detection_map()
    }
    
    func accelerate(_ direction: CGFloat) {
        vel.x += AppState.shared.VELMOVINGADD * direction
        let maxVel = AppState.shared.VELMOVING
        
        if abs(vel.x) > maxVel {
            vel.x = maxVel * direction
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
    }
    
    func collision_detection_map() {
        player.position.x += vel.x //setXf(fx + velx)
        fPrecalculatedY = player.position.y + vel.y
        
        //        let fPlatformVelX = CGFloat(0)
        //        let fPlatformVelY = CGFloat(0)
        let fTempY = player.position.y
        
        // TODO: Moving platform movement
        
        player.position.y = fTempY
        
        //  x axis (--)
        if player.position.y + CGFloat(PH) >= 0.0 {
            if vel.x > 0.01 {
                mapcolldet_moveHorizontally(3);
            } else if vel.x < -0.01 {
                mapcolldet_moveHorizontally(1);
            }
        }
        
        //  then y axis (|)
        
        
        
    }
    
    func mapcolldet_moveHorizontally(_ direction: Int) {
        // left 1
        // right 3
        //        let counter_direction = direction == 1 ? 3 : 1
        
        
        //Could be optimized with bit shift >> 5
        let ty = Int(player.position.y) / TILESIZE
        let ty2 = (Int(player.position.y) + PH) / TILESIZE
        var tx = -1
        
        //        var isMoveKeyDown = false
        //        if direction == 1 {
        //            isMoveKeyDown = keyCode == .left
        //        } else {
        //            isMoveKeyDown = keyCode == .right
        //        }
        
        if direction == 1 {
            //moving left
            tx = Int(player.position.x) / TILESIZE;
        } else {
            //moving right
            tx = (Int(player.position.x) + PW) / TILESIZE;
        }
        
        let toptile = map(x: tx, y: ty)
        let bottomtile = map(x: tx, y: ty2)
        
//        print("mapcolldet_moveHorizontally: \(tx), \(ty) -> \(toptile)")
        
        //collide with solid, ice, and death and all sides death
        if TileTypeFlag(rawValue: toptile).contains(.solid) || TileTypeFlag(rawValue: bottomtile).contains(.solid) {
            
            
            if direction == 1 {
                // move to the edge of the tile
                //                setXf( (float) ((tx << 5) + TILESIZE) + 0.2f);
                player.position.x = CGFloat((tx << 5) + TILESIZE) + 0.2
            } else {
                // move to the edge of the tile (tile on the right -> mind the player width)
                //                setXf((float)((tx << 5) - PW) - 0.2f);
                player.position.x = CGFloat((tx << 5) - PW) - 0.2
            }
            
            fOld.x = player.position.x
            
            if abs(vel.x) > 0.0 {
                vel.x = 0.0
            }
            
            if abs(oldvel.x) > 0.0 {
                oldvel.x = 0.0
            }
            
            //            flipsidesifneeded();
        }
    }
    
    
    
}
