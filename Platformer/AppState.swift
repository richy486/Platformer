//
//  AppState.swift
//  Platformer
//
//  Created by Richard Adem on 23/8/18.
//  Copyright © 2018 Richard Adem. All rights reserved.
//

import Foundation

enum EditMode: Int, CaseIterable, Codable {
    case none
    case paint
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
    
    var editMode: EditMode = .none
    
    var cameraMoveSpeed = CGFloat(500)
    
    var cameraTracking = true
    
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
        let jsonEncoder = JSONEncoder()
        let jsonData: Data
        do {
            jsonData = try jsonEncoder.encode(AppState.shared)
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
