//
//  Level+Loading.swift
//  Platformer
//
//  Created by Richard Adem on 09/02/2025.
//  Copyright © 2025 Richard Adem. All rights reserved.
//

import Foundation
import PlatformerSystem

extension Level {

  init?(withFilename filename: String) {

    let jsonString: String
    let fileURL = URL(fileURLWithPath: "\(filename).json")
    print("loading from: \(fileURL)")
    do {
      jsonString = try String(contentsOf: fileURL, encoding: .utf8)
    } catch {
      print("Error loading: \(error)")
      return nil
    }

    guard let jsonData = jsonString.data(using: .utf8) else {
      print("Error string to data")
      return nil
    }

    let jsonDecoder = JSONDecoder()
    let level: Level
    do {
      level = try jsonDecoder.decode(Level.self, from: jsonData)
    } catch {
      print("Error decoding: \(error)")
      return nil
    }

    self = level
    print("Loaded!")
  }
}
extension Level: Codable {
  private enum CodingKeys: String, CodingKey {
    case name
    case blocks
  }
  public init(from decoder: any Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let name = try values.decode(String.self, forKey: .name)
    let blocks = try values.decode([[Int]].self, forKey: .blocks)
    self.init(name: name, blocks: blocks)
  }
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(name, forKey: .name)
    try container.encode(blocks, forKey: .blocks)
  }

  public func save() {

    var mutableSelf = self

    // Reset any run time changes
    for (y, xBlocks) in mutableSelf.blocks.enumerated() {
      for (x, blockVal) in xBlocks.enumerated() {

        let tileType = TileTypeFlag(rawValue: blockVal)

        if tileType.intersection(.used) == .used {

          // Remove used
          var updatedTile = tileType.symmetricDifference(.used)

          // Re add solid if breakable
          if tileType.contains(.breakable) {
            updatedTile = updatedTile.union(.solid)
          }

          mutableSelf.blocks[y][x] = updatedTile.rawValue
        }
      }
    }

    let jsonEncoder = JSONEncoder()
    let jsonData: Data
    do {
      jsonData = try jsonEncoder.encode(mutableSelf)
    } catch {
      print("Error encoding: \(error)")
      return
    }
    guard let jsonString = String(data: jsonData, encoding: .utf8) else {
      print("Error json stat to string")
      return
    }

    let fileURL = URL(fileURLWithPath: "\(mutableSelf.name).json")
    do {
      try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
    } catch {
      print("Error writing: \(error)")
      return
    }
    print("Saved! \(fileURL.absoluteString)")
  }

}
