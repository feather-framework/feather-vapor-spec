//
//  HTTPBody+Collect.swift
//  feather-vapor-spec
//
//  Created by Binary Birds on 2026. 01. 21..

import OpenAPIRuntime
import Vapor

/// Vapor-specific collection helpers for `HTTPBody`.
extension HTTPBody {

    /// Collects the body data asynchronously and returns it as a `ByteBuffer`.
    ///
    /// This function handles two cases for the length of the data:
    /// 1. If the length is known, it collects up to the specified number of bytes.
    /// 2. If the length is unknown, it collects data chunks until the sequence is exhausted.
    ///
    /// - Returns: A `ByteBuffer` containing the collected data.
    ///
    /// - Throws: Rethrows an underlying error.
    func collect() async throws -> ByteBuffer {
        var buffer = ByteBuffer()
        switch length {
        case .known(let value):
            try await collect(upTo: Int(value), into: &buffer)
        case .unknown:
            for try await chunk in self {
                buffer.writeBytes(chunk)
            }
        }
        return buffer
    }
}
