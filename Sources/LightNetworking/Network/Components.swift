//
//  Components.swift
//  
//
//  Created by Eric Ziegler on 7/23/22.
//

import Foundation

/// Typealias for a [String : String] dictionary.
public typealias HTTPHeaders = [String : String]

/// Common additional HTTP header keys
public enum HTTPHeaderKey {
    /// Accept Encoding HTTP header key: "Accept-Encoding"
    public static let acceptEncoding = "Accept-Encoding"
    /// Content Type HTTP header key: "Content-Type"
    public static let contentType = "Content-Type"

}

/// Typealias for a [String : Any] dictionary.
public typealias Parameters = [String : Any]

/// HTTP request type used to define the httpMethod in a URLRequest.
public enum HTTPMethod: String {
    /// Used for HTTP GET requests
    case get = "GET"
    /// Used for HTTP POST requests
    case post = "POST"
}

///// API-specific errors used to specify network failures.
public enum APIError: LocalizedError {
    /// Failed to encode either paramters, headers, or body data
    case encodingFailed
    /// No response found
    case noResponse
    /// Bad HTTP status code
    case badStatusCode(Int)
    /// Missing or invalid URL
    case invalidURL
    /// Unknown API error
    case unknown

    /// A text description of the error
    public var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode"
        case .noResponse:
            return "No response"
        case .badStatusCode(let statusCode):
            return "Bad status code: \(statusCode)"
        case .invalidURL:
            return "Invalid URL"
        case .unknown:
            return "Unknown API error"
        }
    }
}
