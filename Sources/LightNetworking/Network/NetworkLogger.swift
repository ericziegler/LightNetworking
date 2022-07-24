//
//  NetworkLogger.swift
//  
//
//  Created by Eric Ziegler on 7/23/22.
//

import Foundation

/// The level of logging for API calls.
public enum NetworkLogLevel: Int {
    case off
    case info
    case debug
}

/// Used to log network activity, specifically network requests and resposnes.
struct NetworkLogger {

    private var logLevel = NetworkLogLevel.debug
    
    public init(logLevel: NetworkLogLevel) {
        self.logLevel = logLevel
    }

    /// Logs a URL request with it's url, headers, and body.
    /// - Parameters:
    ///     - request: The URL request to log
    func log(request: URLRequest) {
        guard logLevel != .off else {
            return
        }
        if let method = request.httpMethod,
            let url = request.url {
            print(">>> BEGIN REQUEST <<<")
            print("\(method) '\(url.absoluteString)'")
            logHeaders(request)
            logBody(request)
            print(">>> END REQUEST <<<")

        }
    }

    /// Logs the response from a URL request, including the status code and JSON.
    /// - Parameters:
    ///     - response: The URL response to log
    ///     - data: The JSON data to log
    func log(response: URLResponse, data: Data) {
        guard logLevel != .off else {
            return
        }
        
        print(">>> BEGIN RESPONSE <<<")
        if let response = response as? HTTPURLResponse {
            logStatusCodeAndURL(response)
        }
        if logLevel == .debug {
            print(data.prettyPrintedJSONString ?? "")
        }
        print(">>> END RESPONSE <<<")
    }

    private func logHeaders(_ urlRequest: URLRequest) {
        if let allHTTPHeaderFields = urlRequest.allHTTPHeaderFields {
            for (key, value) in allHTTPHeaderFields {
                print("  \(key) : \(value)")
            }
        }
    }

    private func logBody(_ urlRequest: URLRequest) {
        if let body = urlRequest.httpBody,
            let str = String(data: body, encoding: .utf8) {
            print("  HttpBody : \(str)")
        }
    }

    private func logStatusCodeAndURL(_ urlResponse: HTTPURLResponse) {
        if let url = urlResponse.url {
            print("\(urlResponse.statusCode) '\(url.absoluteString)'")
        }
    }
    
}
