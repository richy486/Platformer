//
//  GlobalConstants.swift
//  Platformer
//
//  Created by Richard Adem on 05/01/2025.
//

enum GlobalConstants {
  // Static property 'tileSize' is not concurrency-safe because non-'Sendable' type 'Size' may have shared mutable state
  nonisolated(unsafe) static let tileSize = Size(width: 16, height: 16)
}
