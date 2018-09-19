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
    
    @IBOutlet weak var velocityLabel: NSTextField!
    @IBOutlet weak var offsetLabel: NSTextField!
    @IBOutlet weak var cameraTrackingCheckbox: NSButton!
    
    @IBOutlet weak var modeSwitchControl: NSSegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        
        speedSliderView.appStateKeyPath = \AppState.VELMOVING
        turboSpeedSliderView.appStateKeyPath = \AppState.VELTURBOMOVING
        accelSliderView.appStateKeyPath = \AppState.VELMOVINGADD
        velJumpSliderView.appStateKeyPath = \AppState.VELJUMP
        velTurboJumpView.appStateKeyPath = \AppState.VELTURBOJUMP
        velStopJumpSliderView.appStateKeyPath = \AppState.VELSTOPJUMP
        gravSliderView.appStateKeyPath = \AppState.GRAVITATION
        cameraSpeedSlider.appStateKeyPath = \AppState.cameraMoveSpeed
        
        modeSwitchControl.segmentCount = EditMode.allCases.count
        EditMode.allCases.enumerated().forEach { (index, editMode) in
            self.modeSwitchControl.setLabel(editMode.name, forSegment: index)
        }
        modeSwitchControl.target = self
        modeSwitchControl.action = #selector(updateMode)
        modeSwitchControl.selectedSegment = AppState.shared.editMode.rawValue
        
        updateSliders()
    }
    
    @objc func updateMode(sender: NSSegmentedControl) {
        guard let mode = EditMode(rawValue: sender.selectedSegment) else {
            return
        }
        
        AppState.shared.editMode = mode
    }
    @IBAction func cameraTrackingChanged(_ checkBox: NSButton) {
        AppState.shared.cameraTracking = checkBox.state == .on
    }
    
    private func updateSliders() {
//        speedSliderView.value = AppState.shared.VELMOVING
//        turboSpeedSliderView.value = AppState.shared.VELTURBOMOVING
//        accelSliderView.value = AppState.shared.VELMOVINGADD
//        velJumpSliderView.value = AppState.shared.VELJUMP
//        velTurboJumpView.value = AppState.shared.VELTURBOJUMP
//        velStopJumpSliderView.value = AppState.shared.VELSTOPJUMP
//        gravSliderView.value = AppState.shared.GRAVITATION
        
        modeSwitchControl.selectedSegment = AppState.shared.editMode.rawValue
        cameraTrackingCheckbox.state = AppState.shared.cameraTracking ? .on : .off
    }
}

extension ViewController: GameSceneDelegate {
    func keysUpdated(keysDown: [KeyCode: Bool], oldKeysDown: [KeyCode: Bool]) {
        leftLabel.backgroundColor = keysDown[.left] == true ? .red : .lightGray
        rightLabel.backgroundColor = keysDown[.right] == true ? .red : .lightGray
        jumpLabel.backgroundColor = keysDown[.a] == true ? .red : .lightGray
        runLabel.backgroundColor = keysDown[.shift] == true ? .red : .lightGray
        
//        if keysDown[.tab] == false && oldKeysDown[.tab] == true {
//            debugView.isHidden.toggle()
//        }
    }
    func cameraModeUpdated(cameraMode: CameraMode) {
        leftOfLabel.backgroundColor = cameraMode == .lockLeftOfPlayer ? .red : .lightGray
        centerLabel.backgroundColor = cameraMode == .center ? .red : .lightGray
        rightOfLabel.backgroundColor = cameraMode == .lockRightOfPlayer ? .red : .lightGray
    }
    
    func playerVelocityUpdated(velocity: CGPoint, offset: CGFloat) {
        velocityLabel.stringValue = String(format: "Velocity: %.02f", velocity.x)
        offsetLabel.stringValue = String(format: "Offset: %.02f", offset)
    }
    func setDebugModeUI(_ debugUI: Bool) {
        debugView.isHidden = !debugUI
    }
}
