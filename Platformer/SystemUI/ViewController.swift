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
    @IBOutlet weak var offsetLabel: NSTextField!
    @IBOutlet weak var cameraTrackingCheckbox: NSButton!
    @IBOutlet weak var printCollisionsCheckbox: NSButton!
    @IBOutlet weak var showBlockCoordsCheckbox: NSButton!
    
    @IBOutlet weak var tileCollectionView: UnselectorCollectionView!
    
    weak var gameScene: SKScene!
    
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
                tileCollectionView.setFrameSize(contentSize)
            }
        }
        
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
    
    private func updateUI() {
        cameraTrackingCheckbox.state = AppState.shared.cameraTracking ? .on : .off
        printCollisionsCheckbox.state = AppState.shared.printCollisions ? .on : .off
        showBlockCoordsCheckbox.state = AppState.shared.showBlockCoords ? .on : .off
        
        switch AppState.shared.editMode {
        case .paint(let tileType):
            guard let index = Map.basicTileTypes.firstIndex(of: tileType) else {
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
    func keysUpdated(keysDown: [KeyCode: Bool], oldKeysDown: [KeyCode: Bool]) {
        leftLabel.backgroundColor = keysDown[.left] == true ? .red : .lightGray
        rightLabel.backgroundColor = keysDown[.right] == true ? .red : .lightGray
        jumpLabel.backgroundColor = keysDown[.a] == true ? .red : .lightGray
        runLabel.backgroundColor = keysDown[.shift] == true ? .red : .lightGray
    }
    func cameraModeUpdated(cameraMode: CameraMode) {
        leftOfLabel.backgroundColor = cameraMode == .lockLeftOfPlayer ? .red : .lightGray
        centerLabel.backgroundColor = cameraMode == .center ? .red : .lightGray
        rightOfLabel.backgroundColor = cameraMode == .lockRightOfPlayer ? .red : .lightGray
    }
    
    func playerStateUpdated(player: Player) {
        velocityLabel.stringValue = String(format: "Velocity: %.02f", player.vel.x)
        offsetLabel.stringValue = String(format: "Offset: %.02f", 0.0)
        inAirLabel.backgroundColor = player.inAir ? .red : .lightGray
        onSlopeLabel.backgroundColor = player.lastSlopeTile != nil ? .red : .lightGray
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
        let tileType = Map.basicTileTypes[indexPath.item]
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
        let count = Map.basicTileTypes.count
        return count
    }
    
    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: .tileItem, for: indexPath)
        guard let tileItem = item as? TileItem else {return item}
        
        tileItem.setup(withTileType: Map.basicTileTypes[indexPath.item])
        
        return tileItem
    }
    
    
    
    
    
    
    
    
}
