//
//  Endpoint.swift
//  
//
//  Created by Eric Ziegler on 7/23/22.
//

import Foundation

/// A representation of a data model combined with components needed to build a URL request.
/// The DecodableDataModel can be any type that conforms to Decodable.
public struct Endpoint<DecodableDataModel: Decodable> {

    // MARK: - Properties
    
    /// The endpoint to be appended to the base url. (e.g. /api/patient/siteList)
    public var path: String
    /// The type of HTTP request.
    public var httpMethod: HTTPMethod
    /// Parameters to be included/encoded into the URL itself. Typically used for GET statements.
    public var urlParams: Parameters
    /// Parameters created and encoded as JSON for the HTTP body. Typically used in POST statements.
    public var bodyParams: Parameters?
    /// Additional HTTP headers that are NOT the Content-Type.
    public var httpHeaders: HTTPHeaders
    
    // MARK: Init
    
    /// Creates an Endpoint for the given path.
    /// - Parameters
    ///     - path: The endpoint to be appended to the base url. (e.g. /api/patient/siteList)
    public init(path: String, httpMethod: HTTPMethod = .get, urlParams: Parameters = Parameters(), bodyParams: Parameters? = nil, httpHeaders: HTTPHeaders = HTTPHeaders()) {
        self.path = path
        self.httpMethod = httpMethod
        self.urlParams = urlParams
        self.bodyParams = bodyParams
        self.httpHeaders = httpHeaders
    }
    
    // MARK: - Adding Params
    
    /// Adds a key/value URL parameter.
    /// - Parameters
    ///     - name: The key in the urlParams dictionary
    ///     - value: The value for the key in the urlParams dictionary
    public mutating func addURLParam(name: String, value: Any) {
        urlParams[name] = value
    }
    
    /// Adds a key/value HTTP body parameter.
    /// - Parameters
    ///     - name: The key in the bodyParams dictionary
    ///     - value: The value for the key in the bodyParams dictionary
    public mutating func addBodyParam(name: String, value: Any) {
        if bodyParams == nil {
            bodyParams = [String : Any]()
        }
        bodyParams![name] = value
    }
    
    /// Adds a key/velue HTTP header.
    /// - Parameters
    ///     - name: The key in the httpHeaders dictionary
    ///     - value: The value for the key in the httpHeaders dictionary
    public mutating func addHTTPHeader(name: String, value: String) {
        httpHeaders[name] = value
    }

}

