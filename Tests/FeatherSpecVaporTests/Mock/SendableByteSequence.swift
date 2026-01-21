//
//  SendableByteSequence.swift
//  feather-vapor-spec
//
//  Created by Binary Birds on 2026. 01. 21..

import Foundation

/// A sendable byte sequence used for unknown-length body tests.
///
/// This avoids `AnySequence` which is not `Sendable`.
struct SendableByteSequence: Sequence, Sendable {
    let bytes: [UInt8]

    struct Iterator: IteratorProtocol {
        var index: Int = 0
        let bytes: [UInt8]

        /// Returns the next byte in the sequence, or `nil` when exhausted.
        mutating func next() -> UInt8? {
            guard index < bytes.count else {
                return nil
            }
            let byte = bytes[index]
            index += 1
            return byte
        }
    }

    /// Creates an iterator over the stored bytes.
    func makeIterator() -> Iterator {
        Iterator(bytes: bytes)
    }
}
