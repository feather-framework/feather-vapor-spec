//
//  Mock.swift
//  feather-vapor-spec
//
//  Created by Binary Birds on 2026. 01. 21..

import OpenAPIRuntime
import Vapor

/// A test model used to exercise Vapor request/response flows.
struct Mock: Codable {
    /// The mock title used in assertions.
    let title: String
}

/// Enables Vapor content encoding/decoding for `Mock`.
extension Mock: Content {}

/// Test-only helpers for building request bodies.
extension Mock {

    /// Encodes the mock as a JSON `HTTPBody`.
    ///
    /// - Returns an empty body if encoding fails.
    var httpBody: HTTPBody {
        let encoder = JSONEncoder()
        var buffer = ByteBuffer()
        try? encoder.encode(self, into: &buffer)
        return HTTPBody(.init(buffer: buffer))
    }
}
