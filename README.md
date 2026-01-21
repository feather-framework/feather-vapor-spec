# Feather Vapor Spec

Vapor runtime integration for Feather Spec, providing a test runner and executor for Vapor applications.

![Release: 1.0.0-beta.1](https://img.shields.io/badge/Release-1%2E0%2E0--beta%2E1-F05138)

## Features

- Vapor-backed `SpecRunner` and `SpecExecutor`
- Designed for modern Swift concurrency
- Works with XCTVapor test clients
- Unit tests and code coverage

## Requirements

![Swift 6.1+](https://img.shields.io/badge/Swift-6%2E1%2B-F05138)
![Platforms: macOS, iOS, tvOS, watchOS, visionOS](https://img.shields.io/badge/Platforms-macOS_%7C_iOS_%7C_tvOS_%7C_watchOS_%7C_visionOS-F05138)

- Swift 6.1+
- Platforms:
    - macOS 15+
    - iOS 18+
    - tvOS 18+
    - watchOS 11+
    - visionOS 2+

## Installation

Use Swift Package Manager; add the dependency to your `Package.swift` file:

```swift
.package(url: "https://github.com/feather-framework/feather-vapor-spec", exact: "1.0.0-beta.1"),
```

Then add `FeatherSpecVapor` to your target dependencies:

```swift
.product(name: "FeatherSpecVapor", package: "feather-vapor-spec"),
```

## Usage

![DocC API documentation](https://img.shields.io/badge/DocC-API_documentation-F05138)

API documentation is available at the following [link](https://feather-framework.github.io/feather-vapor-spec/). Refer to the Tests directory for working examples.

> [!WARNING]
> This repository is a work in progress, things can break until it reaches v1.0.0.

## Related projects

- [Feather Spec](https://github.com/feather-framework/feather-spec)
- [Feather Hummingbird Spec](https://github.com/feather-framework/feather-hummingbird-spec)

## Development

- Build: `swift build`
- Test:
    - local: `make test`
    - using Docker: `make docker-test`
- Format: `make format`
- Check: `make check`

## Contributing

[Pull requests](https://github.com/feather-framework/feather-vapor-spec/pulls) are welcome. Please keep changes focused and include tests for new logic.
