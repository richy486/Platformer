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
    case d = 2
    case tab = 48
    
}

enum CameraMode {
    case center
    case lockLeftOfPlayer
    case lockRightOfPlayer
}

enum Direction {
    case up
    case down
    case left
    case right
}


public struct IntPoint: Hashable {
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



protocol GameSceneDelegate {
    func keysUpdated(keysDown: [KeyCode: Bool], oldKeysDown: [KeyCode: Bool])
    func cameraModeUpdated(cameraMode: CameraMode)
    func playerVelocityUpdated(velocity: CGPoint, offset: CGFloat)
    func setDebugModeUI(_ debugUI: Bool)
}

class GameScene: SKScene {
    
    var gameSceneDelegate: GameSceneDelegate? = nil
    var lastUpdateTimeInterval: CFTimeInterval = 0
    
    private var player: SKShapeNode!
    private var vel: CGPoint = CGPoint.zero //velocity on x, y axis
    private var fOld: CGPoint = CGPoint.zero
    private var oldvel: CGPoint = CGPoint.zero
    
    private var lastGroundPosition: Int = Int.max
    
//    private var blockNodes: [SKNode] = []
    private var blockNodes: [IntPoint: SKNode] = [:]
    
    private let localCamera = SKCameraNode()
    private var localCameraTarget = CGPoint.zero
    private var localCameraMode = CameraMode.center
    private var showDebugUI = true
    
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
    
    let collideXBlockNode: SKShapeNode = {
        let node = SKShapeNode(rect: CGRect(x: 0, y: 0, width: TILESIZE, height: TILESIZE))
        node.fillColor = .clear
        node.strokeColor = .orange
        node.position = CGPoint(x: 0, y: 0)
        node.isHidden = true
        return node
    }()
    
    let collideYLeftBlockNode: SKShapeNode = {
        let node = SKShapeNode(rect: CGRect(x: 0, y: 0, width: TILESIZE, height: TILESIZE))
        node.fillColor = .clear
        node.strokeColor = .blue
        node.position = CGPoint(x: 0, y: 0)
        node.isHidden = true
        return node
    }()
    
    let collideYRightBlockNode: SKShapeNode = {
        let node = SKShapeNode(rect: CGRect(x: 0, y: 0, width: TILESIZE, height: TILESIZE))
        node.fillColor = .clear
        node.strokeColor = .red
        node.position = CGPoint(x: 0, y: 0)
        node.isHidden = true
        return node
    }()
    
    // Camera Guides
    
    lazy var cameraMoveBox: SKShapeNode = {
        let height = Int(self.size.height / CGFloat(TILESIZE) - 3) * TILESIZE
        let node = SKShapeNode(rect: CGRect(x: 0, y: 0, width: TILESIZE*2, height: height))
        node.fillColor = .clear
        node.strokeColor = .orange
        node.position = CGPoint(x: 0, y: 0)
        return node
    }()
    
    lazy var forwardFocusBox: SKShapeNode = {
        let height = Int(self.size.height / CGFloat(TILESIZE) - 1) * TILESIZE
        let node = SKShapeNode(rect: CGRect(x: 0, y: 0, width: TILESIZE*6, height: height))
        node.fillColor = .clear
        node.strokeColor = .blue
        node.position = CGPoint(x: 0, y: 0)
        return node
    }()
    
    lazy var cameraCenter: SKShapeNode = {
        let node = SKShapeNode(circleOfRadius: 10)
        node.fillColor = .clear
        node.strokeColor = .green
        node.position = CGPoint(x: 0, y: 0)
        return node
    }()
    
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        startingPlayerPosition = CGPoint(x: size.width/2 - CGFloat(PW)/2,
                                         y: size.height - CGFloat(2 * TILESIZE))
        startingCameraPosition = CGPoint(x: size.width/2,
                                         y: ((size.height / CGFloat(TILESIZE)) / 2) * CGFloat(TILESIZE))
        
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
        addChild(collideXBlockNode)
        addChild(collideYLeftBlockNode)
        addChild(collideYRightBlockNode)
        
        addChild(cameraMoveBox)
        addChild(forwardFocusBox)
        addChild(cameraCenter)
        
        Map.listenForMapChanges { [weak self] (point, tileType) in
            if let currentBlockNode = self?.blockNodes[point] {
                currentBlockNode.removeFromParent()
            }
            
            if let blockNode = BlockFactory.blockNode(forTileType: tileType) {
                
                blockNode.position = CGPoint(x: point.x * TILESIZE, y: point.y * TILESIZE)
                self?.addChild(blockNode)
                self?.blockNodes[point] = blockNode
            }
            
        }
        
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
        let tile = Map.posToTile(location)
        let tilePos = Map.posToTilePos(location)
        
        print("location: \(location) tile: \(tile) - (\(tilePos.x), \(tilePos.y))")
        
        selectedBlockNode.isHidden = false
        selectedBlockNode.position = CGPoint(x: tilePos.x * TILESIZE, y: tilePos.y * TILESIZE)
        
        switch AppState.shared.editMode {
        case .paint(let tileType):
            print("type type: \(tileType)")
            Map.setMap(x: tilePos.x, y: tilePos.y, tileType: tileType)
        case .erase:
            Map.setMap(x: tilePos.x, y: tilePos.y, tileType: .nonsolid)
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
        if keysDown[.d] == true {
            keysDown[.d] = false
            AppState.load()
            
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
        
        if keysDown[.tab] == true {
            keysDown[.tab] = false
            showDebugUI.toggle()
            gameSceneDelegate?.setDebugModeUI(showDebugUI)
            
            cameraMoveBox.isHidden = !showDebugUI
            forwardFocusBox.isHidden = !showDebugUI
            cameraCenter.isHidden = !showDebugUI
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
        
        gameSceneDelegate?.playerVelocityUpdated(velocity: vel, offset: 0)
        
        // Camera
        if AppState.shared.cameraTracking {
            
            // Camera X
            
            // Update to the corrent mode
            switch localCameraMode {
            case .center:
                
                if f.x - localCamera.position.x > CGFloat(3*TILESIZE) {
                    print("switch to lock left of player")
                    localCameraMode = .lockLeftOfPlayer
                } else if f.x - localCamera.position.x < -CGFloat(3*TILESIZE) {
                    print("switch to lock right of player")
                    localCameraMode = .lockRightOfPlayer
                }
            case .lockLeftOfPlayer:
                // direction right -> center
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
            }
            
            if localCameraMode == .lockLeftOfPlayer || localCameraMode == .lockRightOfPlayer {
                
                let distance = abs(localCamera.position.x - localCameraTarget.x)
                let percent = (AppState.shared.cameraMoveSpeed / distance) * CGFloat(delta)
                let posX = percent
                    .clamp(min: 0, max: 1)
                    .lerp(min: localCamera.position.x, max: localCameraTarget.x)
                localCamera.position.x = posX

            }
            
            // Camera Y
            if lastGroundPosition >= 0 && lastGroundPosition < AppState.shared.blocks.count {
                localCameraTarget.y = CGFloat((lastGroundPosition + AppState.shared.BLOCKSOFFCENTER) * TILESIZE)
                let distance = abs(localCamera.position.y - localCameraTarget.y)
                let percent = (AppState.shared.cameraMoveSpeed / distance) * CGFloat(delta)
                let posY = percent
                    .clamp(min: 0, max: 1)
                    .lerp(min: localCamera.position.y, max: localCameraTarget.y)
                localCamera.position.y = posY
            }
            
            
            
        }
        //                []        *
        
        
        
        cameraMoveBox.position = CGPoint(x: localCamera.position.x - cameraMoveBox.frame.width/2,
                                         y: localCamera.position.y - cameraMoveBox.frame.height/2)
        forwardFocusBox.position = CGPoint(x: localCamera.position.x - forwardFocusBox.frame.width/2,
                                           y: localCamera.position.y - forwardFocusBox.frame.height/2)
        cameraCenter.position = CGPoint(x: localCamera.position.x,
                                        y: localCamera.position.y)
        
        
        lastUpdateTimeInterval = currentTime
    }
    
    private func restart() {
        lockjump = false
        inair = false
        
        f = startingPlayerPosition
        fOld = f
        
        vel = CGPoint.zero
        oldvel = CGPoint.zero
        
        localCameraTarget = startingCameraPosition
        localCamera.position = localCameraTarget
        localCameraMode = .center
    }
    
    private func setupBlocks() {
//        blockNodes.forEach { (_, node) in
//            node.removeFromParent()
//        }
        blockNodes.forEach { (arg0) in
            let (_, node) = arg0
            node.removeFromParent()
        }
//        blockNodes.removeAll()
        blockNodes.removeAll()
        
        // Blocks
        for (y, xBlocks) in AppState.shared.blocks.enumerated() {
            for (x, blockVal) in xBlocks.enumerated() {
                
                let tileType = TileTypeFlag(rawValue: blockVal)
                if let blockNode = BlockFactory.blockNode(forTileType: tileType) {
                    blockNode.position = CGPoint(x: x * TILESIZE, y: y * TILESIZE)
                    addChild(blockNode)
                    blockNodes[IntPoint(x: x, y: y)] = blockNode
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
            var inAir = inair
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
            f = potentialPosition
            inair = inAir
            
            if collide && abs(lastGroundPosition - groundPosition) > 1 {
                lastGroundPosition = groundPosition
            }
        }
        
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
        
        let topTilePoint = IntPoint(x: tx, y: ty)
        let bottomTilePoint = IntPoint(x: tx, y: ty2)
        
        // Top tile
        var collide = false
        if Map.collide(atPoint: topTilePoint, tileType: [.solid, .breakable, .powerup], direction: direction == 1 ? .left : .right) {
            collide = true
            collideXBlockNode.isHidden = showDebugUI ? false : true
            let collideBlockPosition = CGPoint(x: tx * TILESIZE, y: ty * TILESIZE)
            if collideBlockPosition != collideXBlockNode.position {
                collideXBlockNode.position = collideBlockPosition
            }
        } else if Map.collide(atPoint: bottomTilePoint, tileType: [.solid, .breakable, .powerup], direction: direction == 1 ? .left : .right) {
            collide = true
            collideXBlockNode.isHidden = showDebugUI ? false : true
            let collideBlockPosition = CGPoint(x: tx * TILESIZE, y: ty2 * TILESIZE)
            if collideBlockPosition != collideXBlockNode.position {
                collideXBlockNode.position = collideBlockPosition
            }
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
        let ty = Int(position.y) / TILESIZE
        
        //Player hit a solid
//        let alignedTileType = Map.map(x: alignedBlockX, y: ty)
//        if TileTypeFlag(rawValue: alignedTileType).contains(.solid) {
        
        // TODO: use this function everywhere
        if Map.collide(atPoint: IntPoint(x: alignedBlockX, y: ty), tileType: [.solid, .breakable, .powerup], direction: .up) {
            print("collided top")
            position.y = CGFloat((ty << 5) + TILESIZE) + COLLISION_GIVE
            
            return (position: position, collide: true)
        }
        
        //Player squeezed around the block
//        let unalignedTileType = Map.map(x: unAlignedBlockX, y: ty)
//        if TileTypeFlag(rawValue: unalignedTileType).contains(.solid) {
        if Map.collide(atPoint: IntPoint(x: unAlignedBlockX, y: ty), tileType: [.solid, .breakable, .powerup], direction: .up, noTrigger: true) {
            print("squeezed")
            position.x = unAlignedBlockFX
        }
        
        inair = true
        
        return (position: position, collide: false)
    }
    
    func mapcolldet_moveDownward(movePosition position: CGPoint,
                                 txl: Int,
                                 txc: Int,
                                 txr: Int,
                                 alignedBlockX: Int,
                                 unAlignedBlockX: Int,
                                 unAlignedBlockFX: CGFloat) -> (position: CGPoint, collide: Bool, inAir: Bool, groundPosition: Int) {
        
        var position = position
        
        let ty = (Int(position.y) + PH) / TILESIZE
        
        // TODO: support running over gaps
        let fGapSupport = false // VELTURBOMOVING
        
        let collideTiles: TileTypeFlag = [.solid, .breakable, .powerup]
        let leftTilePos = IntPoint(x: txl, y: ty)
        let rightTilePos = IntPoint(x: txr, y: ty)
        
        let fSolidTileUnderPlayerLeft = Map.collide(atPoint: leftTilePos, tileType: collideTiles, direction: .down)
        let fSolidTileUnderPlayerRight = Map.collide(atPoint: rightTilePos, tileType: collideTiles, direction: .down)
        let fSolidTileUnderPlayer = fSolidTileUnderPlayerLeft || fSolidTileUnderPlayerRight

        let fSolidOnTopUnderPlayerLeft = Map.collide(atPoint: leftTilePos, tileType: [.solid_on_top], direction: .down)
        let fSolidOnTopUnderPlayerRight = Map.collide(atPoint: rightTilePos, tileType: [.solid_on_top], direction: .down)
        let fSolidOnTopUnderPlayer = fSolidOnTopUnderPlayerLeft || fSolidOnTopUnderPlayerRight
        
        if fSolidTileUnderPlayerLeft || fSolidOnTopUnderPlayerLeft {
            collideYLeftBlockNode.isHidden = showDebugUI ? false : true
            collideYLeftBlockNode.position = CGPoint(x: txl * TILESIZE, y: ty * TILESIZE)
        } else {
            collideYLeftBlockNode.isHidden = true
        }
        
        if fSolidTileUnderPlayerRight || fSolidOnTopUnderPlayerRight {
            collideYRightBlockNode.isHidden = showDebugUI ? false : true
            collideYRightBlockNode.position = CGPoint(x: txr * TILESIZE, y: ty * TILESIZE)
        } else {
            collideYRightBlockNode.isHidden = true
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
    private func cap(fallingVelocity vel: CGFloat) -> CGFloat {
        if vel > MAXVELY {
            return MAXVELY
        }
        return vel
    }
    
    
}
