//
//  GameScene.swift
//  Platformer
//
//  Created by Richard Adem on 23/8/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import SpriteKit
import PlatformerSystem

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
  
  case lessThan = 43
  case greaterThan = 47
  
}

protocol GameSceneDelegate {
  func controlsUpdated(controls: Controls)
  func cameraModeUpdated(cameraMode: CameraMode)
  func playerStateUpdated(player: Player)
  func setDebugModeUI(_ debugUI: Bool)
}

class GameScene: SKScene {
  
  var gameSceneDelegate: GameSceneDelegate? = nil
  
  private var lastUpdateTimeInterval: CFTimeInterval = 0
  
  private(set) var gameManager = GameManager()
  
  private var blockNodes: [IntPoint: SKNode] = [:]
  private var spriteNodes: [UUID: SKNode] = [:]
  
  private let localCamera = SKCameraNode()
  private var localCameraTarget = CGPoint.zero
  private var localCameraMode = CameraMode.center
  private var showDebugUI = true
  
  private var keysDown: [KeyCode: Bool] = {
    var keys: [KeyCode: Bool] = [:]
    KeyCode.allCases.forEach { keyCode in
      keys[keyCode] = false
    }
    return keys
  }()
  private var forcedKeysDown: [KeyCode : Bool] = [:]
  
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
    node.strokeColor = .green
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
    node.strokeColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.1)
    node.position = CGPoint(x: 0, y: 0)
    node.zPosition = Constants.Layer.debug.rawValue
    return node
  }()
  
  private lazy var forwardFocusBox: SKShapeNode = {
    let height = Int(self.size.height / CGFloat(TILESIZE) - 1) * TILESIZE
    let node = SKShapeNode(rect: CGRect(x: 0, y: 0, width: TILESIZE*6, height: height))
    node.fillColor = .clear
    node.strokeColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.1)
    node.position = CGPoint(x: 0, y: 0)
    node.zPosition = Constants.Layer.debug.rawValue
    return node
  }()
  
  private lazy var cameraCenter: SKShapeNode = {
    let node = SKShapeNode(circleOfRadius: 10)
    node.fillColor = .clear
    node.strokeColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.1)
    node.position = CGPoint(x: 0, y: 0)
    node.zPosition = Constants.Layer.debug.rawValue
    return node
  }()
  
  
  override func didMove(to view: SKView) {
    super.didMove(to: view)
    
    AppState.load()
    
    localCamera.yScale = -1
    addChild(localCamera)
    self.camera = localCamera
    
    gameManager.loadLevel()
    setupBlocks()
    resetCamera()
    
    addChild(selectedBlockNode)
    addChild(collideXBlockNode)
    addChild(collideYLeftBlockNode)
    addChild(collideYRightBlockNode)
    
    addChild(cameraMoveBox)
    addChild(forwardFocusBox)
    addChild(cameraCenter)
    
    
    NotificationCenter.default.addObserver(forName: Constants.kNotificationMapChange,
                                           object: nil,//gameManager.player,
    queue: OperationQueue.main) { notification in
      guard let point = notification.userInfo?[Constants.kMapChangePoint] as? IntPoint else {
        return
      }
      guard let tileType = notification.userInfo?[Constants.kMapChangeTileType] as? TileTypeFlag else {
        return
      }
      
      // Replace the block graphic
      let replaceBlock = {
        if let currentBlockNode = self.blockNodes[point] {
          currentBlockNode.removeFromParent()
        }
        
        guard let blockNode = BlockFactory.blockNode(forTileType: tileType) else {
          return
        }
        
        if AppState.shared.showBlockCoords {
          let coordNode = SKLabelNode(text: "\(point.x), \(point.y)")
          coordNode.fontColor = tileType.contains(.solid_on_top) ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
          coordNode.fontSize = 10
          coordNode.position = CGPoint(x: TILESIZE/2, y: TILESIZE/2 - TILESIZE)
          coordNode.zPosition = Constants.Layer.debug.rawValue
          blockNode.addChild(coordNode)
        }
        
        blockNode.position = CGPoint(x: point.x * TILESIZE, y: point.y * TILESIZE)
        self.addChild(blockNode)
        self.blockNodes[point] = blockNode
      }
      
      // If there is no current block then just add the graphic
      guard let currentBLockNode = self.blockNodes[point] else {
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
                                           object: nil,//gameManager.player,
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
    
    if let keyCode = KeyCode(rawValue: Int(event.keyCode)) {
      keysDown[keyCode] = true
    } else {
      print("unused key code: \(event.keyCode)")
    }
    setModifierKeysDown(event.modifierFlags)
  }
  
  override func keyUp(with event: NSEvent) {
    
    if let keyCode = KeyCode(rawValue: Int(event.keyCode)) {
      keysDown[keyCode] = false
    }
    setModifierKeysDown(event.modifierFlags)
  }
  
  override func mouseDown(with event: NSEvent) {
    
    var level = gameManager.levelManager.level
    let location = event.location(in: self)
    let tile = level.posToTile(location)
    let tilePos = level.posToTilePos(location)
    
    print("location: \(location) tile: \(tile) - (\(tilePos.x), \(tilePos.y))")
    
    selectedBlockNode.isHidden = false
    selectedBlockNode.position = CGPoint(x: tilePos.x * TILESIZE, y: tilePos.y * TILESIZE)
    
    switch AppState.shared.editMode {
    case .paint(let tileType):
      print("type type: \(tileType)")
      level.setMap(x: tilePos.x, y: tilePos.y, tileType: tileType)
    case .erase:
      level.setMap(x: tilePos.x, y: tilePos.y, tileType: .nonsolid)
    default:
      break
    }
    
    gameManager.levelManager.level = level
    
  }
  
  override func update(_ currentTime: TimeInterval) {
    
    // Before update
    if lastUpdateTimeInterval == 0 {
      lastUpdateTimeInterval = currentTime
    }
    
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
      gameManager.levelManager.level.save()
    }
    if keysDown[.d] == true {
      keysDown[.d] = false
      AppState.load()
      gameManager.loadLevel()
      setupBlocks()
      resetCamera()
    }
    
    if keysDown[.r] == true {
      keysDown[.r] = false
      setupBlocks()
      resetCamera()
    }
    
    if keysDown[.tab] == true {
      keysDown[.tab] = false
      showDebugUI.toggle()
      gameSceneDelegate?.setDebugModeUI(showDebugUI)
      
      cameraMoveBox.isHidden = !showDebugUI
      forwardFocusBox.isHidden = !showDebugUI
      cameraCenter.isHidden = !showDebugUI
    }
    
    if keysDown[.lessThan] == true {
      keysDown[.lessThan] = false
      if let _ = forcedKeysDown[.left] {
        forcedKeysDown.removeValue(forKey: .left)
        keysDown[.left] = false
      } else {
        forcedKeysDown[.left] = true
      }
    }
    if keysDown[.greaterThan] == true {
      keysDown[.greaterThan] = false
      if let _ = forcedKeysDown[.right] {
        forcedKeysDown.removeValue(forKey: .right)
        keysDown[.right] = false
      } else {
        forcedKeysDown[.right] = true
      }
    }
    for (key, value) in forcedKeysDown {
      keysDown[key] = value
    }
    
    // Update Game
    
    let controls = Controls(player: ControlCommands(left: keysDown[.left] == true,
                                                    right: keysDown[.right] == true,
                                                    jump: keysDown[.z] == true,
                                                    turbo: keysDown[.a] == true))
    
    gameManager.update(currentTime: currentTime, controls: controls)
    gameSceneDelegate?.controlsUpdated(controls: controls)
    
    // After update
    
    let allActorsAndKeys = gameManager.levelManager.allActorsAndSubActors()
    
    // Remove old actors
    let removedUUIDs = Set(spriteNodes.keys).subtracting(Set(allActorsAndKeys.keys))
    for removedUUID in removedUUIDs {
      guard let removedNode = spriteNodes.removeValue(forKey: removedUUID) else {
        continue
      }
      removedNode.removeFromParent()
    }
    
    for (uuid, actor) in allActorsAndKeys {
      // create new actors
      if spriteNodes[uuid] == nil {
        guard let node = SpriteFactory.spriteNode(forCollisionObject: actor) else {
          continue
        }
        spriteNodes[uuid] = node
        addChild(node)
      }
      
      // Update actors
      guard let node = spriteNodes[uuid] else {
        print("Couldn't update node for UUID: \(uuid)")
        continue
      }
      node.position = actor.f
      
      if let spriteNode = node as? SKSpriteNode {
        if actor.direction.contains(.right) {
          spriteNode.anchorPoint.x = 0
          spriteNode.xScale = 1
        } else {
          spriteNode.anchorPoint.x = 1
          spriteNode.xScale = -1
        }
      }
      //            node.xScale = actor.direction.contains(.right) ? 1 : -1
    }
    
    
    
    gameSceneDelegate?.playerStateUpdated(player: gameManager.player)
    
    // Camera
    localCamera.position = gameManager.levelManager.camera.position
    
    
    //                []        *
    cameraMoveBox.position = CGPoint(x: localCamera.position.x - cameraMoveBox.frame.width/2,
                                     y: localCamera.position.y - cameraMoveBox.frame.height/2)
    forwardFocusBox.position = CGPoint(x: localCamera.position.x - forwardFocusBox.frame.width/2,
                                       y: localCamera.position.y - forwardFocusBox.frame.height/2)
    cameraCenter.position = CGPoint(x: localCamera.position.x,
                                    y: localCamera.position.y)
    
    //        if keysDown[.shift] == true {
    //            playerNode.fillColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
    //        } else {
    //            playerNode.fillColor = #colorLiteral(red: 0.7054507506, green: 0.07813194169, blue: 0, alpha: 1)
    //        }
    //        
    //        if player.inAir {
    //            playerNode.strokeColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
    //        } else if player.lastSlopeTilePoint != nil {
    //            playerNode.strokeColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
    //        } else {
    //            playerNode.strokeColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    //        }        
    
    lastUpdateTimeInterval = currentTime
  }
  
  private func setModifierKeysDown(_ modifierFlags: NSEvent.ModifierFlags) {
    
    keysDown[.capsLock] = modifierFlags.contains(.capsLock)
    keysDown[.shift] = modifierFlags.contains(.shift)
    keysDown[.control] = modifierFlags.contains(.control)
    keysDown[.option] = modifierFlags.contains(.option)
    keysDown[.command] = modifierFlags.contains(.command)
    keysDown[.numericPad] = modifierFlags.contains(.numericPad)
    keysDown[.help] = modifierFlags.contains(.help)
    keysDown[.function] = modifierFlags.contains(.function)
    
  }
  
  private func resetCamera() {
    let player = gameManager.player
    
    localCameraTarget.x = player.f.x + CGFloat(player.size.width)/2
    localCameraTarget.y = player.f.y + CGFloat(player.size.height) + CGFloat(AppState.shared.BLOCKSOFFCENTER * TILESIZE)
    localCamera.position = localCameraTarget
  }
  
  func setupBlocks() {
    blockNodes.forEach { (arg0) in
      let (_, node) = arg0
      node.removeFromParent()
    }
    blockNodes.removeAll()
    
    // Blocks
    
    for (y, xBlocks) in gameManager.levelManager.level.blocks.enumerated() {
      for (x, blockVal) in xBlocks.enumerated() {
        
        let tileType = TileTypeFlag(rawValue: blockVal)
        if let blockNode = BlockFactory.blockNode(forTileType: tileType) {
          if AppState.shared.showBlockCoords {
            let coordNode = SKLabelNode(text: "\(x), \(y)")
            coordNode.fontColor = tileType.contains(.solid_on_top) ? #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) : #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            coordNode.fontSize = 10
            coordNode.position = CGPoint(x: TILESIZE/2, y: TILESIZE/2 - TILESIZE)
            coordNode.zPosition = Constants.Layer.debug.rawValue
            blockNode.addChild(coordNode)
          }
          blockNode.position = CGPoint(x: x * TILESIZE, y: y * TILESIZE)
          addChild(blockNode)
          blockNodes[IntPoint(x: x, y: y)] = blockNode
        }
      }
    }
  }
}
