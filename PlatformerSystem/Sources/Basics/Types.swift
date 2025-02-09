//
//  Types.swift
//  Platformer
//
//  Created by Richard Adem on 04/01/2025.
//

public typealias TimeInterval = Double

public struct UUID: Hashable /*: CustomStringConvertible*/ {
    // The UUID is typically represented as a 128-bit value (16 bytes)
    private var bytes: [UInt8]

    // Initializer that generates a random UUID (UUID version 4)
    init() {
        self.bytes = [UInt8](repeating: 0, count: 16)
        for i in 0..<16 {
            self.bytes[i] = UInt8.random(in: 0...255)
        }

        // Set the version to 4 (UUID version 4)
        self.bytes[6] &= 0x0F  // Clear the high nibble
        self.bytes[6] |= 0x40  // Set the version bits to 0100

        // Set the variant to 10xx
        self.bytes[8] &= 0x3F  // Clear the high nibble
        self.bytes[8] |= 0x80  // Set the variant bits to 10xx
    }

    // Initializer that accepts a specific byte array
    init(bytes: [UInt8]) {
        guard bytes.count == 16 else {
            fatalError("UUID must be initialized with 16 bytes.")
        }
        self.bytes = bytes
    }

    // Method to compare two UUIDs
    public static func ==(lhs: UUID, rhs: UUID) -> Bool {
        return lhs.bytes == rhs.bytes
    }

    // Method to get the raw byte array of the UUID
    var rawBytes: [UInt8] {
        return self.bytes
    }
}
