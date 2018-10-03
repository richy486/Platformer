//
//  AppState.swift
//  Platformer
//
//  Created by Richard Adem on 23/8/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import Foundation

enum EditMode: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case none, paint, erase
    }
    
    init(from decoder: Decoder) throws {
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
    
    func encode(to encoder: Encoder) throws {
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
    
    case none
    case paint(tileType: TileTypeFlag)
    case erase
    
    var name: String {
        switch self {
        case .none: return "None"
        case .paint: return "Paint"
        case .erase: return "Erase"
        }
    }
}

struct AppState : Codable {
    static var shared = AppState()
    
    var VELMOVINGADD = CGFloat(0.5)
    var VELMOVING = CGFloat(4.0)        //velocity (speed) for moving left, right
    var VELTURBOMOVING = CGFloat(5.5)
    
    var VELJUMP = CGFloat(9.0)          //velocity for jumping
    var VELSTOPJUMP = CGFloat(5.0)
    var VELTURBOJUMP = CGFloat(10.2)    //velocity for turbo jumping
    var GRAVITATION = CGFloat(0.40)
    
    var BLOCKSOFFCENTER = Int(-8)
    
    var editMode: EditMode = .none {
        didSet {
            switch editMode {
            case .none:
                print("edit mode 🔳")
            case .paint(let tileType):
                print("edit mode 🖌 \(tileType)")
            case .erase:
                print("edit mode 🗑")
            }
        }
    }
    
    var cameraMoveSpeed = CGFloat(500)
    
    var cameraTracking = true
    var printCollisions = false
    
    // Stairs
    // new velocity jump: 14.901377688172044
    // new gravitation: 0.9783070116487457
    // turbo jump 17.75
    
    var blocks = [
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
        [0,0,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
        [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
        [0,0,S,0,0,0,S,S,S,0,S,0,S,0,S,S,S,S,0,S,0,S,0,S,0,S,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
        [0,0,S,S,0,0,0,0,0,S,S,S,S,0,S,0,0,0,S,0,S,T,T,S,0,S,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
        [0,0,0,S,S,S,0,S,0,0,0,0,0,S,0,0,0,0,0,0,0,0,0,0,T,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
        [0,0,0,0,0,0,S,0,0,S,S,S,S,0,0,0,0,0,0,T,T,0,T,0,T,0,T,0,T,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,T,S],
        [0,0,0,0,0,0,0,0,S,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S],
        [0,0,0,0,S,S,S,S,0,0,0,0,0,0,0,0,0,0,0,T,T,0,0,0,0,0,0,0,S,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,S,S],
        [0,0,S,0,0,0,0,0,0,0,0,0,0,0,S,S,S,0,T,T,T,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [0,0,S,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [S,S,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
        [S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S,S]
    ]
    
    static func save() {
        
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
        print("Saved!")
    }
    
    static func load() {
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
