//
//  ViewController.swift
//  Platformer
//
//  Created by Richard Adem on 23/8/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit
import PlatformerSystem
import JavaScriptCore

var basicTileTypes: [TileTypeFlag] = [
  .nonsolid,
  .solid,
  .solid_on_top,
  [.breakable, .solid],
  [.powerup, .solid],
  .slope_left,            // ◿
  .slope_right,           // ◺
  .pickAxe,               // ⛏️
  .door,                  // 🚪
  .pickup,                // 🎁
  .piggy,                 // 🐷
  .player_start,          // 🚩
  .jsItem,                // 💎
]

// View Controller is origin bottom left
class ViewController: NSViewController {
  
  @IBOutlet var skView: SKView!
  
  @IBOutlet weak var debugView: NSView!
  
  @IBOutlet weak var speedSliderView: SliderView!
  @IBOutlet weak var turboSpeedSliderView: SliderView!
  @IBOutlet weak var accelSliderView: SliderView!
  @IBOutlet weak var velJumpSliderView: SliderView!
  @IBOutlet weak var velTurboJumpView: SliderView!
  @IBOutlet weak var velStopJumpSliderView: SliderView!
  @IBOutlet weak var gravSliderView: SliderView!
  @IBOutlet weak var cameraSpeedSlider: SliderView!
  
  @IBOutlet weak var leftLabel: NSTextField!
  @IBOutlet weak var rightLabel: NSTextField!
  @IBOutlet weak var jumpLabel: NSTextField!
  @IBOutlet weak var runLabel: NSTextField!
  
  @IBOutlet weak var leftOfLabel: NSTextField!
  @IBOutlet weak var centerLabel: NSTextField!
  @IBOutlet weak var rightOfLabel: NSTextField!
  @IBOutlet weak var inAirLabel: NSTextField!
  @IBOutlet weak var onSlopeLabel: NSTextField!
  
  @IBOutlet weak var velocityLabel: NSTextField!
  @IBOutlet weak var positionLabel: NSTextField!
  @IBOutlet weak var cameraTrackingCheckbox: NSButton!
  @IBOutlet weak var printCollisionsCheckbox: NSButton!
  @IBOutlet weak var showBlockCoordsCheckbox: NSButton!
  
  @IBOutlet weak var tileCollectionView: UnselectorCollectionView!
  @IBOutlet weak var rotateCircle: NSImageView!
  
  @IBOutlet weak var jsTextField: NSTextField!
  @IBOutlet weak var jsRunButton: NSButton!
  
  weak var gameScene: SKScene!
  weak var player: Player?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tileCollectionView.register(TileItem.self, forItemWithIdentifier: .tileItem)
    
    guard let view = self.skView else {
      fatalError("Could not load Sprite Kit view")
    }
    // Load the SKScene from 'GameScene.sks'
    guard let scene = SKScene(fileNamed: "GameScene") as? GameScene  else {
      fatalError("Could not load Game Scene")
    }
    
    // Set the scale mode to scale to fit the window
    scene.scaleMode = .aspectFill
    scene.gameSceneDelegate = self
    
    // Present the scene
    view.presentScene(scene)
    view.ignoresSiblingOrder = true
    view.showsFPS = true
    view.showsNodeCount = true
    gameScene = scene
    tileCollectionView.gameScene = scene
    
    speedSliderView.appStateKeyPath = \AppState.VELMOVING
    turboSpeedSliderView.appStateKeyPath = \AppState.VELTURBOMOVING
    accelSliderView.appStateKeyPath = \AppState.VELMOVINGADD
    velJumpSliderView.appStateKeyPath = \AppState.VELJUMP
    velTurboJumpView.appStateKeyPath = \AppState.VELTURBOJUMP
    velStopJumpSliderView.appStateKeyPath = \AppState.VELSTOPJUMP
    gravSliderView.appStateKeyPath = \AppState.GRAVITATION
    cameraSpeedSlider.appStateKeyPath = \AppState.cameraMoveSpeed
    
    if #available(OSX 10.13, *) {
      if let contentSize = tileCollectionView.collectionViewLayout?.collectionViewContentSize {
        var size: NSSize = contentSize
        size.height = size.width * CGFloat(basicTileTypes.count * 2)
        tileCollectionView.setFrameSize(size)
      }
    }
    
    //        velocitySlider.minValue = -Double.pi
    //        velocitySlider.maxValue = Double.pi
    
  
    
    updateUI()
  }
  
  override func viewDidLayout() {
    super.viewDidLayout()
    self.view.window?.makeFirstResponder(gameScene.view)
  }
  
  @IBAction func cameraTrackingChanged(_ checkBox: NSButton) {
    AppState.shared.cameraTracking = checkBox.state == .on
  }
  @IBAction func printCollisionsChanged(_ checkBox: NSButton) {
    AppState.shared.printCollisions = checkBox.state == .on
  }
  @IBAction func showBlockCoordsChanged(_ checkBox: NSButton) {
    AppState.shared.showBlockCoords = checkBox.state == .on
    if let gameScene = gameScene as? GameScene {
      gameScene.setupBlocks()
    }
  }
  @IBAction func jsRunScript(_ sender: Any) {
    
    let context = JSContext()
    
    if let player = player {
    
      let jump: @convention(block) () -> Void = {
//        let player = (self.gameScene as! GameScene).gameManager.player
        player.vel.y = -AppState.shared.VELTURBOJUMP
      }
      context?.setObject(unsafeBitCast(jump, to: AnyObject.self), forKeyedSubscript: "jump" as NSCopying & NSObjectProtocol)
      
      let right: @convention(block) () -> Void = {
//        let player = (self.gameScene as! GameScene).gameManager.player
        player.vel.x += AppState.shared.VELMOVINGADD * 10
      }
      context?.setObject(unsafeBitCast(right, to: AnyObject.self), forKeyedSubscript: "right" as NSCopying & NSObjectProtocol)
      
      let left: @convention(block) () -> Void = {
//        let player = (self.gameScene as! GameScene).gameManager.player
        player.vel.x += -AppState.shared.VELMOVINGADD * 10
      }
      context?.setObject(unsafeBitCast(left, to: AnyObject.self), forKeyedSubscript: "left" as NSCopying & NSObjectProtocol)
    }

    context?.evaluateScript(jsTextField.stringValue)
  }
  
  private func updateUI() {
    cameraTrackingCheckbox.state = AppState.shared.cameraTracking ? .on : .off
    printCollisionsCheckbox.state = AppState.shared.printCollisions ? .on : .off
    showBlockCoordsCheckbox.state = AppState.shared.showBlockCoords ? .on : .off
    
    switch AppState.shared.editMode {
    case .paint(let tileType):
      guard let index = basicTileTypes.firstIndex(of: tileType) else {
        fallthrough
      }
      let indexPath = IndexPath(item: index, section: 0)
      tileCollectionView.selectItems(at: [indexPath], scrollPosition: .top)
      collectionView(tileCollectionView, didSelectItemsAt: [indexPath])
      
    default:
      tileCollectionView.selectItems(at: [], scrollPosition: .top)
      
    }
  }
}

extension ViewController: GameSceneDelegate {
  func controlsUpdated(controls: Controls) {
    leftLabel.backgroundColor = controls.player.left ? .red : .lightGray
    rightLabel.backgroundColor = controls.player.right ? .red : .lightGray
    jumpLabel.backgroundColor = controls.player.jump ? .red : .lightGray
    runLabel.backgroundColor = controls.player.turbo ? .red : .lightGray
  }
  func cameraModeUpdated(cameraMode: CameraMode) {
    leftOfLabel.backgroundColor = cameraMode == .lockLeftOfPlayer ? .red : .lightGray
    centerLabel.backgroundColor = cameraMode == .center ? .red : .lightGray
    rightOfLabel.backgroundColor = cameraMode == .lockRightOfPlayer ? .red : .lightGray
  }
  
  func playerStateUpdated(player: Player) {
    self.player = player
    
    let velRad = player.vel.radians
    let velNorm = player.vel.normalized
    let normalRad = velNorm.radians
    
    let dirStr = player.direction.contains(.left) ? "<-" : "->"
    
    velocityLabel.stringValue = String(format: "Velocity: %.02f,%.02f  \(dirStr)   , norm: %.02f,%.02f (%.02fn %.02f) ",
      player.vel.x, player.vel.y,
      velNorm.x, velNorm.y,
      normalRad, velRad)
    positionLabel.stringValue = String(format: "%.02f,%.02f (%ld,%ld)",
                                       player.f.x,
                                       player.f.y,
                                       player.i.x/TILESIZE,
                                       player.i.y/TILESIZE)
    inAirLabel.backgroundColor = player.inAir ? .red : .lightGray
    onSlopeLabel.backgroundColor = player.lastSlopeTilePoint != nil ? .red : .lightGray
    
    var transform = CGAffineTransform.identity
    transform = transform.scaledBy(x: 1, y: -1)
    transform = transform.translatedBy(x: 16, y: 16)
    transform = transform.rotated(by: normalRad.isNaN ? CGFloat.zero : normalRad)
    transform = transform.translatedBy(x: -16, y: -16)
    
    rotateCircle.layer?.setAffineTransform(transform)
  }
  func setDebugModeUI(_ debugUI: Bool) {
    debugView.isHidden = !debugUI
  }
}

extension ViewController: NSCollectionViewDelegate {
  func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
    print("selected: \(indexPaths)")
    guard let indexPath = indexPaths.first else {
      return
    }
    let tileType = basicTileTypes[indexPath.item]
    AppState.shared.editMode = .paint(tileType: tileType)
  }
  func collectionView(_ collectionView: NSCollectionView, didDeselectItemsAt indexPaths: Set<IndexPath>) {
    print("deselected: \(indexPaths)")
    AppState.shared.editMode = .none
  }
  
  func collectionView(_ collectionView: NSCollectionView, shouldSelectItemsAt indexPaths: Set<IndexPath>) -> Set<IndexPath> {
    print("should")
    return indexPaths
  }
  func collectionView(_ collectionView: NSCollectionView, shouldDeselectItemsAt indexPaths: Set<IndexPath>) -> Set<IndexPath> {
    print("should deselect")
    return indexPaths
  }
  
  func collectionView(_ collectionView: NSCollectionView, willDisplay item: NSCollectionViewItem, forRepresentedObjectAt indexPath: IndexPath) {
    item.isSelected = collectionView.selectionIndexPaths.contains(indexPath)
  }
}
extension ViewController: NSCollectionViewDataSource {
  func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
    let count = basicTileTypes.count
    return count
  }
  
  func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
    let item = collectionView.makeItem(withIdentifier: .tileItem, for: indexPath)
    guard let tileItem = item as? TileItem else {return item}
    
    tileItem.setup(withTileType: basicTileTypes[indexPath.item])
    
    return tileItem
  }
}
