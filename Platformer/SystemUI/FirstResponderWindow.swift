//
//  NSWindow+FirstResponder.swift
//  Platformer
//
//  Created by Richard Adem on 22/9/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import AppKit

class FirstResponderWindow: NSWindow {
  override func makeFirstResponder(_ responder: NSResponder?) -> Bool {
    print("responder: \(String(describing: responder))")
    
    return super.makeFirstResponder(responder)
  }
  
  
}
