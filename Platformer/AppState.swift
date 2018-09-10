//
//  AppState.swift
//  Platformer
//
//  Created by Richard Adem on 23/8/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import Foundation

class AppState {
    static var shared = AppState()
    
    var VELMOVINGADD = CGFloat(0.5)
    var VELMOVING = CGFloat(4.0)
    
    var VELJUMP = CGFloat(9.0)
    var VELSTOPJUMP = CGFloat(5.0)
    var GRAVITATION = CGFloat(0.40)
}
