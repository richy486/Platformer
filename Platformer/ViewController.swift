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

class ViewController: NSViewController {

    @IBOutlet var skView: SKView!
    
    // origin bottom left
    let speedLabel: NSTextField = {
        let view = NSTextField(frame: NSRect(x: 10, y: 520, width: 300, height: 50))
        view.stringValue = "Speed"
        view.textColor = NSColor.white
        view.isEditable = false
        return view
    }()
    let speedSlider: NSSlider = {
        let view = NSSlider(frame: NSRect(x: 10, y: 510, width: 300, height: 50))
        view.minValue = 0
        view.maxValue = 100
        view.doubleValue = Double(AppState.shared.VELMOVING)
        return view
    }()
    
    let accelLabel: NSTextField = {
        let view = NSTextField(frame: NSRect(x: 10, y: 470, width: 300, height: 50))
        view.stringValue = "Acceleration"
        view.textColor = NSColor.white
        view.isEditable = false
        return view
    }()
    let accelSlider: NSSlider = {
        let view = NSSlider(frame: NSRect(x: 10, y: 460, width: 300, height: 50))
        view.minValue = 0
        view.maxValue = 100
        view.doubleValue = Double(AppState.shared.VELMOVINGADD)
        view.trackFillColor = NSColor.green
        return view
    }()
    
    // VELJUMP
    let velJumpLabel: NSTextField = {
        let view = NSTextField(frame: NSRect(x: 10, y: 420, width: 300, height: 50))
        view.stringValue = "Velocity Jump"
        view.textColor = NSColor.white
        view.isEditable = false
        return view
    }()
    let velJumpSlider: NSSlider = {
        let view = NSSlider(frame: NSRect(x: 10, y: 410, width: 300, height: 50))
        view.minValue = 0
        view.maxValue = 100
        view.doubleValue = Double(AppState.shared.VELJUMP)
        view.trackFillColor = NSColor.green
        return view
    }()
    
    // VELSTOPJUMP
    let velStopJumpLabel: NSTextField = {
        let view = NSTextField(frame: NSRect(x: 10, y: 370, width: 300, height: 50))
        view.stringValue = "Velocity Stop Jump"
        view.textColor = NSColor.white
        view.isEditable = false
        return view
    }()
    let velStopJumpSlider: NSSlider = {
        let view = NSSlider(frame: NSRect(x: 10, y: 360, width: 300, height: 50))
        view.minValue = 0
        view.maxValue = 100
        view.doubleValue = Double(AppState.shared.VELSTOPJUMP)
        view.trackFillColor = NSColor.green
        return view
    }()
    
    // GRAVITATION
    let gravLabel: NSTextField = {
        let view = NSTextField(frame: NSRect(x: 10, y: 320, width: 300, height: 50))
        view.stringValue = "Gravitation"
        view.textColor = NSColor.white
        view.isEditable = false
        return view
    }()
    let gravSlider: NSSlider = {
        let view = NSSlider(frame: NSRect(x: 10, y: 310, width: 300, height: 50))
        view.minValue = 0
        view.maxValue = 5
        view.doubleValue = Double(AppState.shared.GRAVITATION)
        view.trackFillColor = NSColor.green
        return view
    }()
    
    let controlsView: NSView = {
        let view = NSView(frame: NSRect(x: 500, y: 500, width: 200, height: 200))
        view.layer?.borderColor = NSColor.lightGray.cgColor
        view.layer?.borderWidth = 1
        return view
    }()
    
    @IBOutlet weak var leftLabel: NSTextField!
    @IBOutlet weak var rightLabel: NSTextField!
    @IBOutlet weak var jumpLabel: NSTextField!
    @IBOutlet weak var runLabel: NSTextField!
    
    var modeSwitchControl: NSSegmentedControl!
    
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
        
        
        
        view.addSubview(speedLabel)
        view.addSubview(speedSlider)
        speedSlider.target = self
        speedSlider.action = #selector(updateSpeed)
        
        view.addSubview(accelLabel)
        view.addSubview(accelSlider)
        accelSlider.target = self
        accelSlider.action = #selector(updateAccel)
        
        view.addSubview(velJumpLabel)
        view.addSubview(velJumpSlider)
        velJumpSlider.target = self
        velJumpSlider.action = #selector(updateVelJump)
        
        view.addSubview(velStopJumpLabel)
        view.addSubview(velStopJumpSlider)
        velStopJumpSlider.target = self
        velStopJumpSlider.action = #selector(updateVelStopJump)
        
        view.addSubview(gravLabel)
        view.addSubview(gravSlider)
        gravSlider.target = self
        gravSlider.action = #selector(updateGrav)
        
        let modeSwitchControl = NSSegmentedControl(labels: EditMode.allCases.map { $0.name },
                                      trackingMode: .selectOne,
                                      target: self,
                                      action: #selector(updateMode))
        modeSwitchControl.frame = CGRect(x: view.frame.width/2 - 100, y: view.frame.height - 60, width: 200, height: 50)
        modeSwitchControl.selectedSegment = AppState.shared.editMode.rawValue
        view.addSubview(modeSwitchControl)
        self.modeSwitchControl = modeSwitchControl
        
        updateSliders()
    }
    
    @objc func updateSpeed(sender: NSSlider) {
        let speed = CGFloat(sender.doubleValue)
        print("new speed: \(speed)")
        AppState.shared.VELMOVING = speed
    }
    @objc func updateAccel(sender: NSSlider) {
        let accel = CGFloat(sender.doubleValue)
        print("new accel: \(accel)")
        AppState.shared.VELMOVINGADD = accel
    }
    @objc func updateVelJump(sender: NSSlider) {
        let val = CGFloat(sender.doubleValue)
        print("new velocity jump: \(val)")
        AppState.shared.VELJUMP = val
    }
    @objc func updateVelStopJump(sender: NSSlider) {
        let val = CGFloat(sender.doubleValue)
        print("new velocity stop jump: \(val)")
        AppState.shared.VELSTOPJUMP = val
    }
    @objc func updateGrav(sender: NSSlider) {
        let val = CGFloat(sender.doubleValue)
        print("new gravitation: \(val)")
        AppState.shared.GRAVITATION = val
    }
    @objc func updateMode(sender: NSSegmentedControl) {
        guard let mode = EditMode(rawValue: sender.selectedSegment) else {
            return
        }
        
        AppState.shared.editMode = mode
    }
    
    private func updateSliders() {
        speedSlider.doubleValue = Double(AppState.shared.VELMOVING)
        accelSlider.doubleValue = Double(AppState.shared.VELMOVINGADD)
        velJumpSlider.doubleValue = Double(AppState.shared.VELJUMP)
        velStopJumpSlider.doubleValue = Double(AppState.shared.VELSTOPJUMP)
        gravSlider.doubleValue = Double(AppState.shared.GRAVITATION)
        modeSwitchControl.selectedSegment = AppState.shared.editMode.rawValue
    }
}

extension ViewController: GameSceneDelegate {
    func keysUpdated(keysDown: [KeyCode : Bool]) {
        leftLabel.backgroundColor = keysDown[.left] == true ? .red : .lightGray
        rightLabel.backgroundColor = keysDown[.right] == true ? .red : .lightGray
        jumpLabel.backgroundColor = keysDown[.a] == true ? .red : .lightGray
        runLabel.backgroundColor = keysDown[.shift] == true ? .red : .lightGray
   }
}
