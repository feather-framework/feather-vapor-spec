//
//  HTTPBody+Decode.swift
//  feather-vapor-spec
//
//  Created by Binary Birds on 2026. 01. 21..

import Foundation
import HTTPTypes
import OpenAPIRuntime

/// Test-only decoding helpers for `HTTPBody`.
extension HTTPBody {

    /// Decodes the body as JSON using the response content length.
    ///
    /// This assumes the response includes a valid `Content-Length` header.
    func decode<T>(
        _ type: T.Type,
        with response: HTTPResponse
    ) async throws -> T where T: Decodable {
        let length = Int(response.headerFields[.contentLength]!)!
        let data = try await Data(collecting: self, upTo: Int(length))
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
