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
    let speedSlider: NSSlider = {
        let view = NSSlider(frame: NSRect(x: 10, y: 400, width: 300, height: 50))
        view.minValue = 0
        view.maxValue = 100
        view.doubleValue = Double(AppState.shared.VELMOVING)
        return view
    }()
    
    let accelSlider: NSSlider = {
        let view = NSSlider(frame: NSRect(x: 10, y: 350, width: 300, height: 50))
        view.minValue = 0
        view.maxValue = 100
        view.doubleValue = Double(AppState.shared.VELMOVINGADD)
        view.trackFillColor = NSColor.green
        return view
    }()
    
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
        
        
        self.view.addSubview(speedSlider)
        speedSlider.target = self
        speedSlider.action = #selector(updateSpeed)
        
        self.view.addSubview(accelSlider)
        accelSlider.target = self
        accelSlider.action = #selector(updateAccel)
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
}

