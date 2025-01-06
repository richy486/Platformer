//
//  Point+Playdate.swift
//  Platformer
//
//  Created by Richard Adem on 06/01/2025.
//
import PlaydateKit

extension Point {
  var playDatePoint: PlaydateKit.Point {
    PlaydateKit.Point(x: Float(x), y: Float(y))
  }
}
