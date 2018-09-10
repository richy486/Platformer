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
    
//    let accelLabel: NSTextField = {
//        let view = NSTextField(frame: NSRect(x: 10, y: 470, width: 300, height: 50))
//        view.stringValue = "Acceleration"
//        view.textColor = NSColor.white
//        view.isEditable = false
//        return view
//    }()
//    let accelSlider: NSSlider = {
//        let view = NSSlider(frame: NSRect(x: 10, y: 450, width: 300, height: 50))
//        view.minValue = 0
//        view.maxValue = 100
//        view.doubleValue = Double(AppState.shared.VELMOVINGADD)
//        view.trackFillColor = NSColor.green
//        return view
//    }()
    override func viewDidLoad() {
        super.viewDidLoad()

        if let view = self.skView {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        
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
}

