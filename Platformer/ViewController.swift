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
    
    @IBOutlet weak var speedSliderView: SliderView!
    @IBOutlet weak var turboSpeedSliderView: SliderView!
    @IBOutlet weak var accelSliderView: SliderView!
    @IBOutlet weak var velJumpSliderView: SliderView!
    @IBOutlet weak var velTurboJumpView: SliderView!
    @IBOutlet weak var velStopJumpSliderView: SliderView!
    @IBOutlet weak var gravSliderView: SliderView!
    
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
        
        speedSliderView.appStateKeyPath = \AppState.VELMOVING
        turboSpeedSliderView.appStateKeyPath = \AppState.VELTURBOMOVING
        accelSliderView.appStateKeyPath = \AppState.VELMOVINGADD
        velJumpSliderView.appStateKeyPath = \AppState.VELJUMP
        velTurboJumpView.appStateKeyPath = \AppState.VELTURBOJUMP
        velStopJumpSliderView.appStateKeyPath = \AppState.VELSTOPJUMP
        gravSliderView.appStateKeyPath = \AppState.GRAVITATION
        
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
    
    @objc func updateMode(sender: NSSegmentedControl) {
        guard let mode = EditMode(rawValue: sender.selectedSegment) else {
            return
        }
        
        AppState.shared.editMode = mode
    }
    
    private func updateSliders() {
        speedSliderView.slider.doubleValue = Double(AppState.shared.VELMOVING)
        turboSpeedSliderView.slider.doubleValue = Double(AppState.shared.VELTURBOMOVING)
        accelSliderView.slider.doubleValue = Double(AppState.shared.VELMOVINGADD)
        velJumpSliderView.slider.doubleValue = Double(AppState.shared.VELJUMP)
        velTurboJumpView.slider.doubleValue = Double(AppState.shared.VELTURBOJUMP)
        velStopJumpSliderView.slider.doubleValue = Double(AppState.shared.VELSTOPJUMP)
        gravSliderView.slider.doubleValue = Double(AppState.shared.GRAVITATION)
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
