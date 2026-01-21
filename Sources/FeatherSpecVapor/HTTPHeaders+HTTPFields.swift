//
//  HTTPHeaders+HTTPFields.swift
//  feather-vapor-spec
//
//  Created by Binary Birds on 2026. 01. 21..

import HTTPTypes
import Vapor

/// Helpers for converting between Vapor and HTTPTypes headers.
extension HTTPHeaders {

    /// Converts `HTTPHeaders` to `HTTPFields`.
    ///
    /// This function iterates over the headers and converts each one into an `HTTPField`.
    /// Invalid header names are force-unwrapped and must be valid per `HTTPField.Name`.
    ///
    /// - Returns: An `HTTPFields` collection containing all the HTTP headers.
    func toHTTPFields() -> HTTPFields {
        var fields = HTTPFields()
        for index in self.indices {
            fields.append(
                HTTPField(
                    name: HTTPField.Name(self[index].name)!,
                    value: self[index].value
                )
            )
        }
        return fields
    }
}
