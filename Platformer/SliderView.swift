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
            slider.action = #selector(sliderChanged)
            slider.isContinuous = true
        }
    }
    @IBOutlet var titleLabel: NSTextField!
    
    var value: CGFloat = 0 {
        didSet {
            slider.doubleValue = Double(value)
            
            update()
        }
    }
    
    var appStateKeyPath: WritableKeyPath<AppState, CGFloat>? = nil {
        didSet {
            if let appStateKeyPath = appStateKeyPath {
                value = AppState.shared[keyPath: appStateKeyPath]
            } else {
                value = 0.5
            }
            
            update()
        }
    }
    
    var titleString: String? = nil
//
//    override init(frame frameRect: NSRect) {
//        super.init(frame: frameRect)
//        commonInit()
//    }
//
//    required init?(coder decoder: NSCoder) {
//        super.init(coder: decoder)
//        commonInit()
//    }
    
//    private func commonInit() {
//        titleString
//    }
    
    
    
    @objc private func sliderChanged(_ sender: NSSlider) {
        
        
        let val = CGFloat(sender.doubleValue)
        self.value = val
        
        update()
    }
    
    private func update() {
        guard let appStateKeyPath = appStateKeyPath else {
            return
        }
        
        print("new \(titleLabel.stringValue): \(value)")
        AppState.shared[keyPath: appStateKeyPath] = value
        
        if titleLabel.stringValue.count > 0 {
            if titleString == nil {
               titleString = titleLabel.stringValue
            }
            
            titleLabel.stringValue = "\(titleString!): \(value)"
        }
//        titleLabel.stringValue =
    }
    
    
}
