//
//  FeatherSpecVaporTests.swift
//  feather-vapor-spec
//
//  Created by Binary Birds on 2026. 01. 21..

import FeatherSpec
import FeatherSpecVapor
import HTTPTypes
import OpenAPIRuntime
import Testing
import Vapor

/// Test suite for the Vapor runtime integration.
@Suite
struct FeatherSpecVaporTests {

    /// Shared mock model used across tests.
    let mock = Mock(title: "task01")
    /// Shared JSON request body used across tests.
    let body = Mock(title: "task01").httpBody

    /// Creates a test app with a POST /mocks endpoint.
    func mocksApp() async throws -> Application {
        let app = try await Application.make(.testing)
        app.routes.post("mocks") { req async throws -> Mock in
            try req.content.decode(Mock.self)
        }
        return app
    }

    /// Creates a test app that echoes header order for POST /header-order.
    func headerOrderApp() async throws -> Application {
        let app = try await Application.make(.testing)
        app.routes.post("header-order") { req async throws -> [String] in
            req.headers["x-test"]
        }
        return app
    }

    @Test
    /// Verifies the mutating `Spec` API against Vapor.
    func testMutatingfuncSpec() async throws {
        let app = try await mocksApp()
        let runner = VaporSpecRunner(app: app)

        var spec = Spec()
        spec.setMethod(.post)
        spec.setPath("mocks")
        spec.setBody(mock.httpBody)
        spec.setHeader(.contentType, "application/json")
        spec.addExpectation(.ok)
        spec.addExpectation { response, body in
            let mock = try await body.decode(Mock.self, with: response)
            #expect(mock.title == self.mock.title)
        }

        try await runner.run(spec)
        try await app.asyncShutdown()
    }

    @Test
    /// Verifies the fluent `Spec` API against Vapor.
    func testBuilderFuncSpec() async throws {
        let app = try await mocksApp()
        let runner = VaporSpecRunner(app: app)

        let spec = Spec()
            .post("mocks")
            .header(.contentType, "application/json")
            .body(body)
            .expect(.ok)
            .expect { response, body in
                let mock = try await body.decode(Mock.self, with: response)
                #expect(mock.title == "task01")
            }

        try await runner.run(spec)
        try await app.asyncShutdown()
    }

    @Test
    /// Verifies the DSL builder API against Vapor.
    func testDslSpec() async throws {
        let app = try await mocksApp()
        let runner = VaporSpecRunner(app: app)

        let spec = SpecBuilder {
            Method(.post)
            Path("mocks")
            Header(.contentType, "application/json")
            Body(body)
            Expect(.ok)
            Expect { response, body in
                let mock = try await body.decode(Mock.self, with: response)
                #expect(mock.title == "task01")
            }
        }
        .build()

        try await runner.run(spec)
        try await app.asyncShutdown()
    }

    @Test
    /// Verifies missing path behavior yields a 404 response.
    func testNoPath() async throws {
        let app = try await Application.make(.testing)
        let runner = VaporSpecRunner(app: app)

        try await runner.run {
            Method(.get)
            Expect(.notFound)
        }
        try await app.asyncShutdown()
    }

    @Test
    /// Verifies unknown-length request bodies with single iteration.
    func testUnkownLength() async throws {
        let app = try await mocksApp()
        let runner = VaporSpecRunner(app: app)

        let sequence = SendableByteSequence(
            bytes: Array(#"{"title":"task01"}"#.utf8)
        )
        let body = HTTPBody(
            sequence,
            length: .unknown,
            iterationBehavior: .single
        )

        try await runner.run {
            Method(.post)
            Path("mocks")
            Header(.contentType, "application/json")
            Body(body)
            Expect(.ok)
            Expect { response, body in
                let mock = try await body.decode(Mock.self, with: response)
                #expect(mock.title == "task01")
            }
        }
        try await app.asyncShutdown()
    }

    @Test
    /// Verifies unknown-length request bodies with multiple iteration.
    func testUnknownLengthMultipleIteration() async throws {
        let app = try await mocksApp()
        let runner = VaporSpecRunner(app: app)

        let sequence = SendableByteSequence(
            bytes: Array(#"{"title":"task01"}"#.utf8)
        )
        let body = HTTPBody(
            sequence,
            length: .unknown,
            iterationBehavior: .multiple
        )

        try await runner.run {
            Method(.post)
            Path("mocks")
            Header(.contentType, "application/json")
            Body(body)
            Expect(.ok)
            Expect { response, body in
                let mock = try await body.decode(Mock.self, with: response)
                #expect(mock.title == "task01")
            }
        }
        try await app.asyncShutdown()
    }

    @Test
    /// Verifies status expectation failures are surfaced.
    func testStatusMismatchThrows() async throws {
        let app = try await mocksApp()
        let runner = VaporSpecRunner(app: app)

        do {
            try await runner.run {
                Method(.post)
                Path("mocks")
                Header(.contentType, "application/json")
                Body(body)
                Expect(.notFound)
            }
            #expect(Bool(false))
        }
        catch Spec.Failure.status(let status) {
            #expect(status == .ok)
        }
        catch {
            #expect(Bool(false))
        }

        try await app.asyncShutdown()
    }

    @Test
    /// Verifies header expectation failures are surfaced.
    func testHeaderExpectationFailure() async throws {
        let app = try await mocksApp()
        let runner = VaporSpecRunner(app: app)

        do {
            try await runner.run {
                Method(.post)
                Path("mocks")
                Header(.contentType, "application/json")
                Body(body)
                Expect(.authorization)
            }
            #expect(Bool(false))
        }
        catch Spec.Failure.header(let name) {
            #expect(name == .authorization)
        }
        catch {
            #expect(Bool(false))
        }

        try await app.asyncShutdown()
    }

    @Test
    /// Verifies expectation blocks execute in declared order.
    func testMultipleExpectationsOrder() async throws {
        let app = try await mocksApp()
        let runner = VaporSpecRunner(app: app)
        let recorder = ExpectationRecorder()

        try await runner.run {
            Method(.post)
            Path("mocks")
            Header(.contentType, "application/json")
            Body(body)
            Expect(.ok)

            Expect { _, _ in
                await recorder.record("first")
            }

            Expect { _, _ in
                await recorder.record("second")
            }
        }

        let entries = await recorder.snapshot()
        #expect(entries == ["first", "second"])

        try await app.asyncShutdown()
    }

    @Test
    /// Verifies multiple headers are preserved in order.
    func testHeaderOrdering() async throws {
        let app = try await headerOrderApp()
        let runner = VaporSpecRunner(app: app)
        guard let headerName = HTTPField.Name("x-test") else {
            #expect(Bool(false))
            try await app.asyncShutdown()
            return
        }

        try await runner.run {
            Method(.post)
            Path("header-order")
            Header(headerName, "one")
            Header(headerName, "two")
            Expect(.ok)
            Expect { response, body in
                let values = try await body.decode(
                    [String].self,
                    with: response
                )
                #expect(values == ["one", "two"])
            }
        }

        try await app.asyncShutdown()
    }
}
