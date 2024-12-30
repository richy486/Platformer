//
//  ActorJS.swift
//  Platformer macOS
//
//  Created by Richard Adem on 22/12/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import Foundation
import JavaScriptCore
import CoreGraphics
//import UIKit
import Foundation


//public struct CGInt {
//
//
//  public var x: Int
//
//  public var y: Int
//
//  public init() {
//    self.x = 0
//    self.y = 0
//  }
//
//  public init(x: Int, y: Int) {
//    self.x = x
//    self.y = y
//  }
//}

@objc protocol ActorJSExports : JSExport {
 
  var f: CGPoint { get set }
  var vel: CGPoint { get set }
  var fOld: CGPoint { get set }
//  var size: CGInt { get set }
  var width: Int { get set }
  var height: Int { get set }
  
  static func createWith(f: CGPoint, vel: CGPoint, fOld: CGPoint, width: Int, height: Int) -> ActorJS
}

@objc class ActorJS : NSObject, ActorJSExports {
  dynamic var f: CGPoint
  dynamic var vel: CGPoint
  dynamic var fOld: CGPoint
//  dynamic var size: CGInt
  dynamic var width: Int
  dynamic var height: Int
  
  init(f: CGPoint, vel: CGPoint, fOld: CGPoint, width: Int, height: Int) {
    self.f = f
    self.vel = vel
    self.fOld = fOld
//    self.size = size
    self.width = width
    self.height = height
  }
  
  class func createWith(f: CGPoint, vel: CGPoint, fOld: CGPoint, width: Int, height: Int) -> ActorJS {
    return ActorJS(f: f, vel: vel, fOld: fOld, width: width, height: height)
  }
}
