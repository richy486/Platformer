//
//  CGHelpers.swift
//
//  Created by Richard Adem on 6/21/16.
//  Copyright © 2016 Richard Adem. All rights reserved.
//

// Lerp and Clamp from Daniel Clelland https://github.com/dclelland/Lerp

import CoreGraphics

// MARK: Lerpable protocol
public protocol Lerpable {
    func lerp(min: Self, max: Self) -> Self
    func ilerp(min: Self, max: Self) -> Self
}

// MARK: Clampable protocol

public protocol Clampable {
    func clamp(min: Self, max: Self) -> Self
}

// MARK: - CGFloat
func round(_ value: CGFloat, tollerence: CGFloat) -> CGFloat {
    if abs(value).truncatingRemainder(dividingBy: 1.0) < tollerence || abs(value).truncatingRemainder(dividingBy: 1.0) > 1.0 - tollerence {
        return round(value)
    }
    return value
}

extension CGFloat {
    public static var zero: CGFloat = CGFloat(0)
}

extension CGFloat {
    func format(_ f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}

extension CGFloat: Lerpable {
    
    /// Linear interpolation
    public func lerp(min: CGFloat, max: CGFloat) -> CGFloat {
        return min + (self * (max - min))
    }
    
    /// Inverse linear interpolation
    public func ilerp(min: CGFloat, max: CGFloat) -> CGFloat {
        return (self - min) / (max - min)
    }
    
}

extension CGFloat: Clampable {
    
    /// Clamp
    public func clamp(min: CGFloat, max: CGFloat) -> CGFloat {
        return Swift.min(Swift.max(self, Swift.min(min, max)), Swift.max(min, max))
    }
    
}

// MARK: - CGPoint
extension CGPoint {
    func distance(to: CGPoint) -> CGFloat {
        let dx = pow(to.x - self.x, 2)
        let dy = pow(to.y - self.y, 2)
        return sqrt(dx + dy)
    }
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}
func - (left: CGPoint, right: CGPoint) -> CGPoint {
    
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}
func * (left: CGPoint, right: CGPoint) -> CGPoint {
    
    return CGPoint(x: left.x * right.x, y: left.y * right.y)
}
func / (left: CGPoint, right: CGPoint) -> CGPoint {
    
    return CGPoint(x: left.x / right.x, y: left.y / right.y)
}

func % (left: CGPoint, right: CGPoint) -> CGPoint {
    
    return CGPoint(x: left.x.truncatingRemainder(dividingBy: right.x), y: left.y.truncatingRemainder(dividingBy: right.y))
}

func += (left: inout CGPoint, right: CGPoint) {
    left = left + right
}
func -= (left: inout CGPoint, right: CGPoint) {
    left = left - right
}
func *= (left: inout CGPoint, right: CGPoint) {
    left = left * right
}
func /= (left: inout CGPoint, right: CGPoint) {
    left = left / right
}

func * (left: CGPoint, right: CGFloat) -> CGPoint {
    
    return CGPoint(x: left.x * right, y: left.y * right)
}
func / (left: CGPoint, right: CGFloat) -> CGPoint {
    
    return CGPoint(x: left.x / right, y: left.y / right)
}
func + (left: CGPoint, right: CGFloat) -> CGPoint {
    
    return CGPoint(x: left.x + right, y: left.y + right)
}
func - (left: CGPoint, right: CGFloat) -> CGPoint {
    
    return CGPoint(x: left.x - right, y: left.y - right)
}

func floor(_ point: CGPoint) -> CGPoint {
    return CGPoint(x: floor(point.x), y: floor(point.y))
}

func round(_ value: CGPoint, tollerence: CGFloat) -> CGPoint {
    return CGPoint(x: round(value.x, tollerence: tollerence),
                   y: round(value.y, tollerence: tollerence))
}

func abs(_ value: CGPoint) -> CGPoint {
    return CGPoint(x: abs(value.x), y: abs(value.y))
}

extension CGPoint {
    func format(_ f: String) -> String {
        return String(format: "(%\(f)f, %\(f)f)", self.x, self.y)
    }
    
    func offsetX(x: CGFloat) -> CGPoint {
        return CGPoint(x: self.x + x, y: self.y)
    }
    
    func offsetY(y: CGFloat) -> CGPoint {
        return CGPoint(x: self.x, y: self.y + y)
    }
}

extension CGPoint: Lerpable {
    
    /// Linear interpolation
    public func lerp(min: CGPoint, max: CGPoint) -> CGPoint {
        let x = self.x.lerp(min: min.x, max: max.x)
        let y = self.y.lerp(min: min.y, max: max.y)
        return CGPoint(x: x, y: y)
    }
    
    /// Inverse linear interpolation
    public func ilerp(min: CGPoint, max: CGPoint) -> CGPoint {
        let x = self.x.ilerp(min: min.x, max: max.x)
        let y = self.y.ilerp(min: min.y, max: max.y)
        return CGPoint(x: x, y: y)
    }
    
}

extension CGPoint: Clampable {
    
    /// Clamp
    public func clamp(min: CGPoint, max: CGPoint) -> CGPoint {
        let x = self.x.clamp(min: min.x, max: max.x)
        let y = self.y.clamp(min: min.y, max: max.y)
        return CGPoint(x: x, y: y)
    }
    
}

// MARK: - CGSize
func + (left: CGSize, right: CGSize) -> CGSize {
    
    return CGSize(width: left.width + right.width, height: left.height + right.height)
}
func - (left: CGSize, right: CGSize) -> CGSize {
    
    return CGSize(width: left.width - right.width, height: left.height - right.height)
}
func * (left: CGSize, right: CGSize) -> CGSize {
    
    return CGSize(width: left.width * right.width, height: left.height * right.height)
}
func / (left: CGSize, right: CGSize) -> CGSize {
    
    return CGSize(width: left.width / right.width, height: left.height / right.height)
}

func * (left: CGSize, right: CGFloat) -> CGSize {
    
    return CGSize(width: left.width * right, height: left.height * right)
}
func / (left: CGSize, right: CGFloat) -> CGSize {
    
    return CGSize(width: left.width / right, height: left.height / right)
}

// MARK: - CGSize v CGPoint
func sizeToPoint(_ size: CGSize) -> CGPoint {
    return CGPoint(x: size.width, y: size.height)
}

func * (left: CGPoint, right: CGSize) -> CGPoint {
    
    return CGPoint(x: left.x * right.width, y: left.y * right.height)
}
func / (left: CGPoint, right: CGSize) -> CGPoint {
    
    return CGPoint(x: left.x / right.width, y: left.y / right.height)
}
func + (left: CGPoint, right: CGSize) -> CGPoint {
    
    return CGPoint(x: left.x + right.width, y: left.y + right.height)
}
func - (left: CGPoint, right: CGSize) -> CGPoint {
    
    return CGPoint(x: left.x - right.width, y: left.y - right.height)
}

extension CGSize: Lerpable {
    
    /// Linear interpolation
    public func lerp(min: CGSize, max: CGSize) -> CGSize {
        let width = self.width.lerp(min: min.width, max: max.width)
        let height = self.height.lerp(min: min.height, max: max.height)
        return CGSize(width: width, height: height)
    }
    
    /// Inverse linear interpolation
    public func ilerp(min: CGSize, max: CGSize) -> CGSize {
        let width = self.width.ilerp(min: min.width, max: max.width)
        let height = self.height.ilerp(min: min.height, max: max.height)
        return CGSize(width: width, height: height)
    }
    
}

extension CGSize: Clampable {
    
    /// Clamp
    public func clamp(min: CGSize, max: CGSize) -> CGSize {
        let width = self.width.clamp(min: min.width, max: max.width)
        let height = self.height.clamp(min: min.height, max: max.height)
        return CGSize(width: width, height: height)
    }
    
}
