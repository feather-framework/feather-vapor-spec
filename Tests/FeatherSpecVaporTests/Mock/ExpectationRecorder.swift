//
//  ExpectationRecorder.swift
//  feather-vapor-spec
//
//  Created by Binary Birds on 2026. 01. 21..

/// Records expectation ordering for assertions.
///
/// This actor provides a simple, thread-safe log of expectation callbacks.
actor ExpectationRecorder {
    private var entries: [String] = []

    /// Appends a new entry to the recorder.
    func record(_ entry: String) {
        entries.append(entry)
    }

    /// Returns the recorded entries in insertion order.
    func snapshot() -> [String] {
        entries
    }
}
