//
//  GameScene.swift
//  Platformer
//
//  Created by Richard Adem on 23/8/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import SpriteKit

enum KeyCode: Int, CaseIterable {
    case left = 123
    case right = 124
    case down = 125
    case up = 126
    case z = 6
    case a = 0
    case r = 15
    
    // Modifiers
    case capsLock = 1000
    case shift = 1001
    case control = 1002
    case option = 1003
    case command = 1004
    case numericPad = 1005
    case help = 1006
    case function = 1007
    
    // Debug
    case i = 34
    case j = 38
    case k = 40
    case l = 37
    
    case s = 1
    case tab = 48
    
}

enum CameraMode {
    case center
    case lockLeftOfPlayer
    case lockRightOfPlayer
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

let VELMOVINGFRICTION = CGFloat(0.2)
let PH = Int(25)      //Player height
let PW = Int(22)      //Player width
let HALFPH = Int(12)
let HALFPW = Int(11)
let TILESIZE = Int(32)
let COLLISION_GIVE = CGFloat(0.2) // Move back by this amount when colliding
let BOUNCESTRENGTH = CGFloat(0.5)
let MAXVELY = CGFloat(20.0)

var keysDown: [KeyCode: Bool] = {
    var keys: [KeyCode: Bool] = [:]
    KeyCode.allCases.forEach { keyCode in
        keys[keyCode] = false
    }
    return keys
}()

func setModifierKeysDown(_ modifierFlags: NSEvent.ModifierFlags) {
    
    keysDown[.capsLock] = modifierFlags.contains(.capsLock)
    keysDown[.shift] = modifierFlags.contains(.shift)
    keysDown[.control] = modifierFlags.contains(.control)
    keysDown[.option] = modifierFlags.contains(.option)
    keysDown[.command] = modifierFlags.contains(.command)
    keysDown[.numericPad] = modifierFlags.contains(.numericPad)
    keysDown[.help] = modifierFlags.contains(.help)
    keysDown[.function] = modifierFlags.contains(.function)

}

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

protocol GameSceneDelegate {
    func keysUpdated(keysDown: [KeyCode: Bool], oldKeysDown: [KeyCode: Bool])
    func cameraModeUpdated(cameraMode: CameraMode)
    func playerVelocityUpdated(velocity: CGPoint)
}

class GameScene: SKScene {
    
    var gameSceneDelegate: GameSceneDelegate? = nil
    var lastUpdateTimeInterval: CFTimeInterval = 0
    
    private var player: SKShapeNode!
    private var vel: CGPoint = CGPoint.zero //velocity on x, y axis
    private var fOld: CGPoint = CGPoint.zero
    private var oldvel: CGPoint = CGPoint.zero
    
    private var blockNodes: [SKNode] = []
    
    private let localCamera = SKCameraNode()
    private var localCameraTarget = CGPoint.zero
    private var localCameraMode = CameraMode.center
    
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

//    var iHorizontalPlatformCollision = Int(0)
//    var iVerticalPlatformCollision = Int(0)
//    var iPlatformCollisionPlayerId = Int(0)
    
    var lockjump = false
    var inair = false
    
    var fallthroughTile = false // bool fallthrough;
    
    var startingPlayerPosition = CGPoint.zero
    var startingCameraPosition = CGPoint.zero
    
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
    
    let cameraMoveBox: SKShapeNode = {
        let node = SKShapeNode(rect: CGRect(x: 0, y: 0, width: TILESIZE*2, height: TILESIZE*30))
        node.fillColor = .clear
        node.strokeColor = .orange
        node.position = CGPoint(x: 0, y: 0)
        return node
    }()
    
    let forwardFocusBox: SKShapeNode = {
        let node = SKShapeNode(rect: CGRect(x: 0, y: 0, width: TILESIZE*6, height: TILESIZE*30))
        node.fillColor = .clear
        node.strokeColor = .blue
        node.position = CGPoint(x: 0, y: 0)
        return node
    }()
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        startingPlayerPosition = CGPoint(x: size.width/2 - CGFloat(PW)/2, y: size.height - CGFloat(2 * TILESIZE))
        startingCameraPosition = CGPoint(x: size.width/2, y: size.height/2)
        
        AppState.load()
        
        localCameraTarget = startingCameraPosition
        localCamera.yScale = -1
        localCamera.position = localCameraTarget
        
        addChild(localCamera)
        self.camera = localCamera
        
        
        setupBlocks()
        
        f = startingPlayerPosition
        player = SKShapeNode(rect: CGRect(x: 0, y: 0, width: PW, height: PH))
        player.fillColor = .red
        player.position = f
        player.name = "player"
        addChild(player)
        
        fOld = f
        
        restart()
        
        addChild(selectedBlockNode)
        addChild(collideBlockNode)
        
        
        addChild(cameraMoveBox)
        addChild(forwardFocusBox)
        
        
//        localCamera.position = player.position
        
        
    }
    
    @objc static override var supportsSecureCoding: Bool {
        // SKNode conforms to NSSecureCoding, so any subclass going
        // through the decoding process must support secure coding
        get {
            return true
        }
    }
    
    override func keyDown(with event: NSEvent) {
        
        let oldKeysDown = keysDown
        let oldHash = keysDown.hashValue
        
        if let keyCode = KeyCode(rawValue: Int(event.keyCode)) {
            keysDown[keyCode] = true
        } else {
            print("unused key code: \(event.keyCode)")
        }
        setModifierKeysDown(event.modifierFlags)
        
        if keysDown.hashValue != oldHash {
            gameSceneDelegate?.keysUpdated(keysDown: keysDown, oldKeysDown: oldKeysDown)
        }
    }
    
    override func keyUp(with event: NSEvent) {
        
        let oldKeysDown = keysDown
        let oldHash = keysDown.hashValue
        
        if let keyCode = KeyCode(rawValue: Int(event.keyCode)) {
            keysDown[keyCode] = false
        }
        setModifierKeysDown(event.modifierFlags)
        
        if keysDown.hashValue != oldHash {
            gameSceneDelegate?.keysUpdated(keysDown: keysDown, oldKeysDown: oldKeysDown)
        }
    }
    
    override func mouseDown(with event: NSEvent) {

        let location = event.location(in: self)
        let tile = posToTile(location)
        let tilePos = posToTilePos(location)
        
        print("location: \(location) tile: \(tile) - (\(tilePos.x), \(tilePos.y))")
        
        selectedBlockNode.isHidden = false
        selectedBlockNode.position = CGPoint(x: tilePos.x * TILESIZE, y: tilePos.y * TILESIZE)
        
        switch AppState.shared.editMode {
        case .paint:
            setMap(x: tilePos.x, y: tilePos.y, tileType: .solid)
            setupBlocks()
        case .erase:
            setMap(x: tilePos.x, y: tilePos.y, tileType: .nonsolid)
            setupBlocks()
        default:
            break
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        if lastUpdateTimeInterval == 0 {
            lastUpdateTimeInterval = currentTime
        }
        let delta = currentTime - lastUpdateTimeInterval
        
        // Debug
        let cameraMoveAmount = CGFloat(10)
        if keysDown[.j] == true {
            localCamera.position.x -= cameraMoveAmount
            print("camera position: \(localCamera.position)")
        } else if keysDown[.l] == true {
            localCamera.position.x += cameraMoveAmount
            print("camera position: \(localCamera.position)")
        }
        if keysDown[.k] == true {
            localCamera.position.y += cameraMoveAmount
            print("camera position: \(localCamera.position)")
        } else if keysDown[.i] == true {
            localCamera.position.y -= cameraMoveAmount
            print("camera position: \(localCamera.position)")
        }
        
        
        if keysDown[.s] == true {
            keysDown[.s] = false
            
            
            AppState.save()

        }
        
        
        // Called before each frame is rendered
        
        var movementDirectionX = CGFloat(0.0)
        if keysDown[.left] == keysDown[.right] {
            // Both left and right down or both left and right up
            movementDirectionX = 0.0
        } else if keysDown[.left] == true {
            movementDirectionX = -1.0
        } else if keysDown[.right] == true {
            movementDirectionX = 1.0
        } else if keysDown[.z] == true {
            movementDirectionX = 1.0
            keysDown[.z] = false
        }
        
        if keysDown[.r] == true {
            keysDown[.r] = false
            restart()
            
        }
        
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
        player.position = f
        
        // Camera
        // Update to the corrent mode
        switch localCameraMode {
        case .center:
//            print("offset: \(f.x - localCamera.position.x)")
            
            if f.x - localCamera.position.x > CGFloat(3*TILESIZE) {
                print("switch to lock left of player")
                localCameraMode = .lockLeftOfPlayer
            } else if f.x - localCamera.position.x < -CGFloat(3*TILESIZE) {
                print("switch to lock right of player")
                localCameraMode = .lockRightOfPlayer
            }
        case .lockLeftOfPlayer:
//            direction right -> center
            if movementDirectionX < 0.0 {
                localCameraMode = .center
            }
        case .lockRightOfPlayer:
            if movementDirectionX > 0.0 {
                localCameraMode = .center
            }
        }
        gameSceneDelegate?.cameraModeUpdated(cameraMode: localCameraMode)
        
        // Update the camera depending on the mode
        switch localCameraMode {
        case .center:
            break
        case .lockLeftOfPlayer:
            localCameraTarget.x = f.x + CGFloat(PW)/2 + CGFloat(TILESIZE)
        case .lockRightOfPlayer:
            localCameraTarget.x = f.x + CGFloat(PW)/2 - CGFloat(TILESIZE)
//        case .lockLeftOfPlayer, .lockRightOfPlayer:
//            localCameraTarget.x = f.x + CGFloat(PW)/2
        }
        
        
        if abs(localCamera.position.x - localCameraTarget.x) < 1.0 {
            localCamera.position.x = localCameraTarget.x
        } else {
//            let difference = localCameraTarget.x - localCamera.position.x
//
//            localCamera.position.x += localCameraTarget.x - localCamera.position.x > 0
//                ? min(difference, AppState.shared.cameraMoveSpeed)
//                : max(difference, -AppState.shared.cameraMoveSpeed)
            
            
            let percent = (CGFloat(delta) * AppState.shared.cameraMoveSpeed)
                .clamp(min: 0, max: 1)
             let updatedPos = CGPoint(x: percent, y: percent)
                .lerp(min: localCamera.position, max: localCameraTarget)
            localCamera.position = updatedPos
        }
        
        
        
        //                []        *
        
        cameraMoveBox.position = CGPoint(x: localCamera.position.x - cameraMoveBox.frame.width/2,
                                         y: localCamera.position.y - cameraMoveBox.frame.height/2)
        forwardFocusBox.position = CGPoint(x: localCamera.position.x - forwardFocusBox.frame.width/2,
                                           y: localCamera.position.y - forwardFocusBox.frame.height/2)
        
        gameSceneDelegate?.playerVelocityUpdated(velocity: vel)
        lastUpdateTimeInterval = currentTime
    }
    
    private func restart() {
        lockjump = false
        inair = false
        fallthroughTile = false
        
        f = startingPlayerPosition
        fOld = f
        
        vel = CGPoint.zero
        oldvel = CGPoint.zero
        
        localCameraTarget = startingCameraPosition
        localCamera.position = localCameraTarget
        localCameraMode = .center
    }
    
    private func setupBlocks() {
        blockNodes.forEach { node in
            node.removeFromParent()
        }
        blockNodes.removeAll()
        
        // Blocks
        for (y, xBlocks) in AppState.shared.blocks.enumerated() {
            for (x, blockVal) in xBlocks.enumerated() {
                
                switch blockVal {
                case S:
                    let blockNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: TILESIZE, height: TILESIZE))
                    blockNode.fillColor = .yellow
                    blockNode.strokeColor = .white
                    blockNode.position = CGPoint(x: x * TILESIZE, y: y * TILESIZE)
                    addChild(blockNode)
                    blockNodes.append(blockNode)
                case T:
                    let blockNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: TILESIZE, height: 5))
                    blockNode.fillColor = .yellow
                    blockNode.strokeColor = .white
                    blockNode.position = CGPoint(x: x * TILESIZE, y: y * TILESIZE)
                    addChild(blockNode)
                    blockNodes.append(blockNode)
                default:
                    continue
                }
            }
        }
    }
    
    // void CPlayer::accelerate(float direction)
    func accelerateX(_ direction: CGFloat) {
        
        
        vel.x += AppState.shared.VELMOVINGADD * direction
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
        
//        vel.y = -AppState.shared.VELJUMP * jumpModifier;
        
        if abs(vel.x) > AppState.shared.VELMOVING && movementDirectionX != 0 && keysDown[.shift] == true {
            vel.y = -AppState.shared.VELTURBOJUMP * jumpModifier
        } else {
            vel.y = -AppState.shared.VELJUMP * jumpModifier
        }
        
        
        inair = true;
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

        // Lets add gravity here
        vel.y = cap(fallingVelocity: vel.y + AppState.shared.GRAVITATION)
        let targetPlayerPostition = CGPoint(x: f.x + vel.x, y: f.y + vel.y)

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
                }
                
            } else if vel.x < -0.01 {
                // Moving left
                var collide = false
                while f.x > targetPlayerPostition.x + COLLISION_GIVE && !collide {
                    f.x = max(f.x - CGFloat(TILESIZE), targetPlayerPostition.x)
                    let result = mapcolldet_move(movePosition: f, horizontallyInDirection: 1)
                    f = result.position
                    collide = result.collide
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
            var potentialPosition = f
            while f.y > targetPlayerPostition.y + COLLISION_GIVE && !collide {
                f.y = max(f.y - CGFloat(TILESIZE), targetPlayerPostition.y)
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
            }
            if collide && vel.y < 0.0 {
                print("bounce")
                vel.y = -vel.y * BOUNCESTRENGTH
            }
            f = potentialPosition
        } else {
            //moving down / on ground
            var collide = false
            var potentialPosition = f
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
            }
            f = potentialPosition
        }
        fallthroughTile = false
        
        // Reset gravity if on the ground
        if !inair {
            vel.y = AppState.shared.GRAVITATION
        }
    }
    
    func mapcolldet_move(movePosition position: CGPoint, horizontallyInDirection direction: Int) -> (position: CGPoint, collide: Bool) {
        // left 1
        // right 3
        var position = position
        
        //Could be optimized with bit shift >> 5
        let ty = Int(position.y) / TILESIZE
        let ty2 = (Int(position.y) + PH) / TILESIZE
        var tx = -1
        
        if direction == 1 {
            //moving left
            tx = Int(position.x) / TILESIZE;
        } else {
            //moving right
            tx = (Int(position.x) + PW) / TILESIZE;
        }
        
        
        
        let toptile = map(x: tx, y: ty)
        let bottomtile = map(x: tx, y: ty2)
        
        //collide with solid
        var collide = false
        if TileTypeFlag(rawValue: toptile).contains(.solid) || TileTypeFlag(rawValue: bottomtile).contains(.solid) {
            
            collide = true
            // Debug
            if TileTypeFlag(rawValue: toptile).contains(.solid) {
                collideBlockNode.isHidden = false
                let collideBlockPosition = CGPoint(x: tx * TILESIZE, y: ty * TILESIZE)
                if collideBlockPosition != collideBlockNode.position {
                    collideBlockNode.position = collideBlockPosition
                }
            } else if TileTypeFlag(rawValue: bottomtile).contains(.solid) {
                collideBlockNode.isHidden = false
                let collideBlockPosition = CGPoint(x: tx * TILESIZE, y: ty2 * TILESIZE)
                if collideBlockPosition != collideBlockNode.position {
                    collideBlockNode.position = collideBlockPosition
                }
            }
            
            
            if direction == 1 {
                // move to the edge of the tile
                position.x = CGFloat((tx << 5) + TILESIZE) + COLLISION_GIVE
            } else {
                // move to the edge of the tile (tile on the right -> mind the player width)
                position.x = CGFloat((tx << 5) - PW) - COLLISION_GIVE
            }
            if abs(vel.x) > 0.0 {
                vel.x = 0.0
            }
            if abs(oldvel.x) > 0.0 {
                oldvel.x = 0.0
            }
        }
        return (position, collide)
    }
    
    
    func mapcolldet_moveUpward(movePosition position: CGPoint,
                               txl: Int,
                               txc: Int,
                               txr: Int,
                               alignedBlockX: Int,
                               unAlignedBlockX: Int,
                               unAlignedBlockFX: CGFloat) -> (position: CGPoint, collide: Bool) {
        var position = position
        
        // moving up
        fallthroughTile = false
        
        let ty = Int(position.y) / TILESIZE
        
        //Player hit a solid
        let alignedTileType = map(x: alignedBlockX, y: ty)
        
        if TileTypeFlag(rawValue: alignedTileType).contains(.solid) {
            print("collided top")
            position.y = CGFloat((ty << 5) + TILESIZE) + COLLISION_GIVE
            
            return (position, true)
        }
        
        //Player squeezed around the block
        let unalignedTileType = map(x: unAlignedBlockX, y: ty)
        if TileTypeFlag(rawValue: unalignedTileType).contains(.solid) {
            print("squeezed")
            position.x = unAlignedBlockFX
        }
        
        inair = true
        
        return (position, false)
    }
    
    func mapcolldet_moveDownward(movePosition position: CGPoint,
                                 txl: Int,
                                 txc: Int,
                                 txr: Int,
                                 alignedBlockX: Int,
                                 unAlignedBlockX: Int,
                                 unAlignedBlockFX: CGFloat) -> (position: CGPoint, collide: Bool) {
        
        var position = position
        
        let ty = (Int(position.y) + PH) / TILESIZE
        
        let lefttile = map(x: txl, y: ty)
        let righttile = map(x: txr, y: ty)
        
        let fGapSupport = false // VELTURBOMOVING
        
        let fSolidTileUnderPlayer = TileTypeFlag(rawValue: lefttile).contains(.solid) ||
                                    TileTypeFlag(rawValue: righttile).contains(.solid)

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
                
                inair = false
            }
            
            return (position, !inair)
        }
        
        if fSolidTileUnderPlayer {
            // on ground
            
            position.y = CGFloat((ty << 5) - PH) - COLLISION_GIVE
            inair = false
        } else {
            // falling (in air)
            inair = true
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
