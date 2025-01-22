//
//  EditMode+Codable.swift
//  Platformer
//
//  Created by Richard Adem on 22/01/2025.
//  Copyright © 2025 Richard Adem. All rights reserved.
//

import Foundation
import PlatformerSystem

extension EditMode: Codable {
  private enum CodingKeys: String, CodingKey {
    case none, paint, erase
  }

  public init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)

    if values.contains(.paint) {
      let value: TileTypeFlag
      value = TileTypeFlag(rawValue: try values.decode(Int.self, forKey: .paint))

      self = .paint(tileType: value)
    } else if values.contains(.none) {
      self = .none
    } else if values.contains(.erase) {
      self = .erase
    } else {
      print("Error decoding EditMode: \(decoder)")
      self = .none
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    switch self {
    case .paint(let value):
      try container.encode(value.rawValue, forKey: CodingKeys.paint)
    case .none:
      try container.encode(true, forKey: CodingKeys.none)
    case .erase:
      try container.encode(true, forKey: CodingKeys.erase)
    }
  }
}
