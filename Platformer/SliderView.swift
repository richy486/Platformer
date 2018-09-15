//
//  SliderView.swift
//  Platformer
//
//  Created by Richard Adem on 14/9/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import Cocoa

class SliderView: NSView {

    @IBOutlet var slider: NSSlider! {
        didSet {
            slider.target = self
            slider.action = #selector(update)
        }
    }
    @IBOutlet var titleLabel: NSTextField!
    
    var appStateKeyPath: WritableKeyPath<AppState, CGFloat>? = nil
    
    @objc private func update(_ sender: NSSlider) {
        guard let appStateKeyPath = appStateKeyPath else {
            return
        }
        
        let val = CGFloat(sender.doubleValue)
        print("new \(titleLabel.stringValue): \(val)")
        AppState.shared[keyPath: appStateKeyPath] = val
    }
        
}
