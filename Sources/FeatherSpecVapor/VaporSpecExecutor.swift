//
//  VaporSpecExecutor.swift
//  feather-vapor-spec
//
//  Created by Binary Birds on 2026. 01. 21..

import FeatherSpec
import HTTPTypes
import OpenAPIRuntime
import XCTVapor

/// A `SpecExecutor` implementation that executes HTTP requests using Vapor.
///
/// This executor uses `XCTApplicationTester` to execute requests and adapts Vapor responses
/// into `HTTPResponse` and `HTTPBody` for expectation evaluation.
struct VaporSpecExecutor: SpecExecutor {

    /// The client responsible for executing HTTP requests.
    ///
    /// This is provided by `XCTVapor` for test execution.
    let client: XCTApplicationTester

    /// Executes an HTTP request with the provided request and body.
    ///
    /// This function collects the body data, constructs the request URI, and uses the client to execute the request.
    /// It transforms the client response into an `HTTPResponse` and `HTTPBody`.
    ///
    /// - Parameters:
    ///   - req: The HTTP request to be executed.
    ///   - body: The body of the HTTP request.
    ///
    /// - Returns: A tuple containing the HTTP response and the response body.
    ///
    /// - Throws: Rethrows an underlying error.
    public func execute(
        req: HTTPRequest,
        body: HTTPBody
    ) async throws -> (
        response: HTTPResponse,
        body: HTTPBody
    ) {
        let method = HTTPMethod(rawValue: req.method.rawValue)
        let uri = {
            var uri = req.path ?? ""
            if !uri.hasPrefix("/") {
                uri = "/" + uri
            }
            return uri
        }()
        let headers = HTTPHeaders(req.headerFields.toHTTPHeaders())
        let buffer = try await body.collect()

        var result: (response: HTTPResponse, body: HTTPBody)?

        try await client.test(
            method,
            uri,
            headers: headers,
            body: buffer
        ) { res async throws in
            let response = HTTPResponse(
                status: .init(
                    code: Int(res.status.code),
                    reasonPhrase: res.status.reasonPhrase
                ),
                headerFields: .init(res.headers.toHTTPFields())
            )
            let body = HTTPBody(.init(buffer: res.body))
            result = (response: response, body: body)
        }

        guard let result else {
            throw Spec.Failure.status(.internalServerError)
        }
        return result
    }
}
