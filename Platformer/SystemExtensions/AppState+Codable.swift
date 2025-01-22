//
//  AppState+Codable.swift
//  Platformer
//
//  Created by Richard Adem on 22/01/2025.
//  Copyright © 2025 Richard Adem. All rights reserved.
//

import Foundation
import PlatformerSystem

extension AppState: Codable {
  private enum CodingKeys: String, CodingKey {
    case velMovingAdd
    case velMoving
    case velTurboMoving
    case velKick
    case velJump
    case velStopJump
    case velTurboJump
    case gravitation
    case blocksOffCenter
    case editMode
    case cameraMoveSpeed
    case cameraTracking
    case printCollisions
    case showBlockCoords
    case blocks
  }
  public func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(VELMOVINGADD, forKey: .velMovingAdd)
    try container.encode(VELMOVING, forKey: .velMoving)
    try container.encode(VELTURBOMOVING, forKey: .velTurboMoving)
    try container.encode(VELKICK, forKey: .velKick)
    try container.encode(VELJUMP, forKey: .velJump)
    try container.encode(VELSTOPJUMP, forKey: .velStopJump)
    try container.encode(VELTURBOJUMP, forKey: .velTurboJump)
    try container.encode(GRAVITATION, forKey: .gravitation)
    try container.encode(BLOCKSOFFCENTER, forKey: .blocksOffCenter)
    try container.encode(editMode, forKey: .editMode)
    try container.encode(cameraMoveSpeed, forKey: .cameraMoveSpeed)
    try container.encode(cameraTracking, forKey: .cameraTracking)
    try container.encode(printCollisions, forKey: .printCollisions)
    try container.encode(showBlockCoords, forKey: .showBlockCoords)
    try container.encode(blocks, forKey: .blocks)
  }

  public init(from decoder: Decoder) throws {
    self.init()
    let values = try decoder.container(keyedBy: CodingKeys.self)
    VELMOVINGADD = try values.decode(Double.self, forKey: .velMovingAdd)
    VELMOVING = try values.decode(Double.self, forKey: .velMoving)
    VELTURBOMOVING = try values.decode(Double.self, forKey: .velTurboMoving)
    VELKICK = try values.decode(Double.self, forKey: .velKick)
    VELJUMP = try values.decode(Double.self, forKey: .velJump)
    VELSTOPJUMP = try values.decode(Double.self, forKey: .velStopJump)
    VELTURBOJUMP = try values.decode(Double.self, forKey: .velTurboJump)
    GRAVITATION = try values.decode(Double.self, forKey: .gravitation)
    BLOCKSOFFCENTER = try values.decode(Int.self, forKey: .blocksOffCenter)
    editMode = try values.decode(EditMode.self, forKey: .editMode)
    cameraMoveSpeed = try values.decode(Double.self, forKey: .cameraMoveSpeed)
    cameraTracking = try values.decode(Bool.self, forKey: .cameraTracking)
    printCollisions = try values.decode(Bool.self, forKey: .printCollisions)
    showBlockCoords = try values.decode(Bool.self, forKey: .showBlockCoords)
    blocks = try values.decode([[Int]].self, forKey: .blocks)
  }

  public static func save() {

    var appState = AppState.shared

    // Reset any run time changes
    for (y, xBlocks) in appState.blocks.enumerated() {
      for (x, blockVal) in xBlocks.enumerated() {

        let tileType = TileTypeFlag(rawValue: blockVal)

        if tileType.intersection(.used) == .used {

          // Remove used
          var updatedTile = tileType.symmetricDifference(.used)

          // Re add solid if breakable
          if tileType.contains(.breakable) {
            updatedTile = updatedTile.union(.solid)
          }

          appState.blocks[y][x] = updatedTile.rawValue
        }
      }
    }



    let jsonEncoder = JSONEncoder()
    let jsonData: Data
    do {
      jsonData = try jsonEncoder.encode(appState)
    } catch {
      print("Error encoding: \(error)")
      return
    }
    guard let jsonString = String(data: jsonData, encoding: .utf8) else {
      print("Error json stat to string")
      return
    }

    let fileURL = URL(fileURLWithPath: "appState.json")
    do {
      try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
    } catch {
      print("Error writing: \(error)")
      return
    }
    print("Saved! \(fileURL.absoluteString)")
  }

  public static func load() {
    let jsonString: String
    let fileURL = URL(fileURLWithPath: "appState.json")
    print("loading from: \(fileURL)")
    do {
      jsonString = try String(contentsOf: fileURL, encoding: .utf8)
    } catch {
      print("Error loading: \(error)")
      return
    }

    guard let jsonData = jsonString.data(using: .utf8) else {
      print("Error string to data")
      return
    }

    let jsonDecoder = JSONDecoder()
    let appState: AppState
    do {
      appState = try jsonDecoder.decode(AppState.self, from: jsonData)
    } catch {
      print("Error decoding: \(error)")
      return
    }

    AppState.shared = appState
    print("Loaded!")
  }
}
