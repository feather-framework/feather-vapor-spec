//
//  VaporSpecRunner.swift
//  feather-vapor-spec
//
//  Created by Binary Birds on 2026. 01. 21..

import FeatherSpec
import Vapor
import XCTVapor

/// A `SpecRunner` implementation that runs specifications using Vapor.
///
/// This runner wraps a Vapor `Application` and uses `XCTVapor` to execute requests
/// against the in-memory or running server during tests.
public struct VaporSpecRunner: SpecRunner {

    /// The Vapor application used for testing.
    private let app: Application

    /// The method used for setting up the application during testing.
    ///
    /// Use `.inMemory` for fast tests or `.running` for full HTTP server behavior.
    private let method: Application.Method

    /// Initializes a new instance of `VaporSpecRunner`.
    ///
    /// - Parameters:
    ///   - app: The Vapor application to be used for testing.
    ///   - method: The setup method for the application during testing. Defaults to `.inMemory`.
    public init(
        app: Application,
        testingSetup method: Application.Method = .inMemory
    ) {
        self.app = app
        self.method = method
    }

    /// Runs a test with the provided block.
    ///
    /// This function uses the application to perform a test with the given setup method.
    /// It passes a `VaporSpecExecutor` to the block, which is used to execute HTTP requests within the test.
    ///
    /// - Parameter block: A closure that takes a `SpecExecutor` and performs asynchronous operations.
    ///
    /// - Important: A new server will be spawned for each request when using the `running` testing setup.
    ///
    /// - Throws: Rethrows an underlying error.
    public func test(
        block: @escaping (SpecExecutor) async throws -> Void
    ) async throws {
        // NOTE: A new server will be spawned for each request when using the `running` testing setup.
        try await block(VaporSpecExecutor(client: app.testable(method: method)))
    }
}
