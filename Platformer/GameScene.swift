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
    
    private var lastUpdateTimeInterval: CFTimeInterval = 0
    
    private var player = Player()
    private var playerNode: SKShapeNode!

    private var blockNodes: [IntPoint: SKNode] = [:]
    
    private let localCamera = SKCameraNode()
    private var localCameraTarget = CGPoint.zero
    private var localCameraMode = CameraMode.center
    private var showDebugUI = true
    
    private var startingCameraPosition = CGPoint.zero
    
    private let selectedBlockNode: SKShapeNode = {
        let node = SKShapeNode(rect: CGRect(x: 0, y: 0, width: TILESIZE, height: TILESIZE))
        node.fillColor = .clear
        node.strokeColor = .blue
        node.position = CGPoint(x: 0, y: 0)
        node.isHidden = true
        node.zPosition = Constants.Layer.debug.rawValue
        return node
    }()
    
    private let collideXBlockNode: SKShapeNode = {
        let node = SKShapeNode(rect: CGRect(x: 0, y: 0, width: TILESIZE, height: TILESIZE))
        node.fillColor = .clear
        node.strokeColor = .orange
        node.position = CGPoint(x: 0, y: 0)
        node.isHidden = true
        node.zPosition = Constants.Layer.debug.rawValue
        return node
    }()
    
    private let collideYLeftBlockNode: SKShapeNode = {
        let node = SKShapeNode(rect: CGRect(x: 0, y: 0, width: TILESIZE, height: TILESIZE))
        node.fillColor = .clear
        node.strokeColor = .blue
        node.position = CGPoint(x: 0, y: 0)
        node.isHidden = true
        node.zPosition = Constants.Layer.debug.rawValue
        return node
    }()
    
    private let collideYRightBlockNode: SKShapeNode = {
        let node = SKShapeNode(rect: CGRect(x: 0, y: 0, width: TILESIZE, height: TILESIZE))
        node.fillColor = .clear
        node.strokeColor = .red
        node.position = CGPoint(x: 0, y: 0)
        node.isHidden = true
        node.zPosition = Constants.Layer.debug.rawValue
        return node
    }()
    
    // Camera Guides
    
    private lazy var cameraMoveBox: SKShapeNode = {
        let height = Int(self.size.height / CGFloat(TILESIZE) - 3) * TILESIZE
        let node = SKShapeNode(rect: CGRect(x: 0, y: 0, width: TILESIZE*2, height: height))
        node.fillColor = .clear
        node.strokeColor = .orange
        node.position = CGPoint(x: 0, y: 0)
        node.zPosition = Constants.Layer.debug.rawValue
        return node
    }()
    
    private lazy var forwardFocusBox: SKShapeNode = {
        let height = Int(self.size.height / CGFloat(TILESIZE) - 1) * TILESIZE
        let node = SKShapeNode(rect: CGRect(x: 0, y: 0, width: TILESIZE*6, height: height))
        node.fillColor = .clear
        node.strokeColor = .blue
        node.position = CGPoint(x: 0, y: 0)
        node.zPosition = Constants.Layer.debug.rawValue
        return node
    }()
    
    private lazy var cameraCenter: SKShapeNode = {
        let node = SKShapeNode(circleOfRadius: 10)
        node.fillColor = .clear
        node.strokeColor = .green
        node.position = CGPoint(x: 0, y: 0)
        node.zPosition = Constants.Layer.debug.rawValue
        return node
    }()
    
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        player.startingPlayerPosition = CGPoint(x: size.width/2 - CGFloat(PW)/2,
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
        
        playerNode = SKShapeNode(rect: CGRect(x: 0, y: 0, width: PW, height: PH))
        playerNode.fillColor = .red
        playerNode.position = player.f
        playerNode.name = "player"
        playerNode.zPosition = Constants.Layer.active.rawValue
        addChild(playerNode)
        
        restart()
        
        addChild(selectedBlockNode)
        addChild(collideXBlockNode)
        addChild(collideYLeftBlockNode)
        addChild(collideYRightBlockNode)
        
        addChild(cameraMoveBox)
        addChild(forwardFocusBox)
        addChild(cameraCenter)
        
        
        Map.listenForMapChanges { [weak self] (point, tileType) in
            
            // Replace the block graphic
            let replaceBlock = {
                if let currentBlockNode = self?.blockNodes[point] {
                    currentBlockNode.removeFromParent()
                }
                
                guard let blockNode = BlockFactory.blockNode(forTileType: tileType) else {
                    return
                }
                
                blockNode.position = CGPoint(x: point.x * TILESIZE, y: point.y * TILESIZE)
                self?.addChild(blockNode)
                self?.blockNodes[point] = blockNode
            }
            
            // If there is no current block then just add the graphic
            guard let currentBLockNode = self?.blockNodes[point] else {
                replaceBlock()
                return
            }
            
            // Check the tile type and do an appropriate graphic effect before
            // replacing the graphic
            if tileType.contains(.powerup) {
                let moveUp = SKAction.moveBy(x: 0.0,
                                             y: -10.0,
                                             duration: 0.1)
                let moveDown = SKAction.moveBy(x: 0.0,
                                               y: 10.0,
                                               duration: 0.1)
                let runBlock = SKAction.run(replaceBlock)
                
                let sequence = SKAction.sequence([moveUp, moveDown, runBlock])
                currentBLockNode.run(sequence)
            } else {
                replaceBlock()
            }
            
        }
        NotificationCenter.default.addObserver(forName: Constants.kNotificationCollide,
                                               object: player,
                                               queue: OperationQueue.main) { notification in
                                                
                                                func update(debugBlock: SKNode, withPosition position: CGPoint) {
                                                    debugBlock.isHidden = self.showDebugUI ? false : true
                                                    if position != debugBlock.position {
                                                        debugBlock.position = position
                                                    }
                                                }
                                                
                                                if let collidePositionX = notification.userInfo?[Constants.kCollideXPosition] as? CGPoint{
                                                    update(debugBlock: self.collideXBlockNode, withPosition: collidePositionX)
                                                }
                                                if let collidePositionYLeft = notification.userInfo?[Constants.kCollideYLeftPosition] as? CGPoint{
                                                    update(debugBlock: self.collideYLeftBlockNode, withPosition: collidePositionYLeft)
                                                }
                                                if let collidePositionYRight = notification.userInfo?[Constants.kCollideYRightPosition] as? CGPoint{
                                                    update(debugBlock: self.collideYRightBlockNode, withPosition: collidePositionYRight)
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
            setupBlocks()
            restart()
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
        
        player.update(keysDown: keysDown)

        let movementDirectionX = player.f.x - playerNode.position.x
        playerNode.position = player.f
        
        gameSceneDelegate?.playerVelocityUpdated(velocity: player.vel, offset: 0)
        
        // Camera
        if AppState.shared.cameraTracking {
            
            // Camera X
            
            // Update to the corrent mode
            switch localCameraMode {
            case .center:
                
                if player.f.x - localCamera.position.x > CGFloat(3*TILESIZE) {
                    print("switch to lock left of player")
                    localCameraMode = .lockLeftOfPlayer
                } else if player.f.x - localCamera.position.x < -CGFloat(3*TILESIZE) {
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
                localCameraTarget.x = player.f.x + CGFloat(PW)/2 + CGFloat(TILESIZE)
            case .lockRightOfPlayer:
                localCameraTarget.x = player.f.x + CGFloat(PW)/2 - CGFloat(TILESIZE)
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
            if player.lastGroundPosition >= 0 && player.lastGroundPosition < AppState.shared.blocks.count {
                localCameraTarget.y = CGFloat((player.lastGroundPosition + AppState.shared.BLOCKSOFFCENTER) * TILESIZE)
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
        
        if keysDown[.shift] == true {
            playerNode.fillColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        } else {
            playerNode.fillColor = #colorLiteral(red: 0.7054507506, green: 0.07813194169, blue: 0, alpha: 1)
        }
        
        if player.inair {
            playerNode.strokeColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        } else {
            playerNode.strokeColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        
        
        lastUpdateTimeInterval = currentTime
    }
    
    private func restart() {
        player.restart()
        
        localCameraTarget = startingCameraPosition
        localCamera.position = localCameraTarget
        localCameraMode = .center
    }
    
    private func setupBlocks() {
        blockNodes.forEach { (arg0) in
            let (_, node) = arg0
            node.removeFromParent()
        }
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
}
