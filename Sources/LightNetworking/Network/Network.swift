//
//  Network.swift
//  
//
//  Created by Eric Ziegler on 7/23/22.
//

import Foundation

/// Used to make URL requests, handle URL responses, return decoded data models, and/or throw errors.
public struct Network {
    
    // MARK: - Properties
    
    private let networkLogger: NetworkLogger
    private let urlSession: URLSession
    private let baseURL: String
    
    // MARK: - Init
    
    public init(baseURL: String, logLevel: NetworkLogLevel = .off) {
        networkLogger = NetworkLogger(logLevel: logLevel)
        urlSession = URLSession(configuration: .ephemeral)
        self.baseURL = baseURL
    }
    
    // MARK: - Perform Request
    
    /// Asynchronous, throwable entry point for all Network requests.
    /// 
    /// - Parameters:
    /// - endpoint: The endpoint that is used to build the HTTP request, configured with a placeholder decodable data model
    ///
    /// - Returns: Optional data (usually JSON)
    ///
    /// - Throws: An API Error
    @discardableResult public func request(endpoint: Endpoint, timeoutInterval: Double = 20.0) async throws -> Data? {
        // build request
        let request = try buildRequest(from: endpoint, timeoutInterval: timeoutInterval)
        // debug log the request
        networkLogger.log(request: request)
        // send request
        let (data, response) = try await urlSession.data(for: request)
        // debug log the response
        networkLogger.log(response: response, data: data)
        // validate the HTTP status code and the existence of data
        try validateResponse(response, data: data)
        // return the raw data
        return data
    }
    
    // MARK: - Build Request
    
    private func buildRequest(from endpoint: Endpoint, timeoutInterval: Double) throws -> URLRequest {
        // create the request
        guard let url = URL(string: baseURL) else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url.appendingPathComponent(endpoint.path),
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: timeoutInterval)
        // set the http method
        request.httpMethod = endpoint.httpMethod.rawValue
        
        // set up url parameters
        try addURLParameters(urlRequest: &request, params: endpoint.urlParams)
        // set up post body
        try addPostBody(urlRequest: &request, with: endpoint.bodyParams)
        // add additional http headers
        addHTTPHeaders(urlRequest: &request, httpHeaders: endpoint.httpHeaders)
        
        return request
    }
    
    private func addHTTPHeaders(urlRequest: inout URLRequest, httpHeaders: HTTPHeaders) {
        for (key, value) in httpHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
    }
    
    private func addURLParameters(urlRequest: inout URLRequest, params: Parameters?) throws {
        guard let url = urlRequest.url else {
            throw APIError.invalidURL
        }
        
        guard let params = params else {
            return
        }
        
        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false), !params.isEmpty {
            urlComponents.queryItems = [URLQueryItem]()
            
            for (key, value) in params {
                let queryItem = URLQueryItem(name: key, value: "\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))
                urlComponents.queryItems?.append(queryItem)
            }
            urlRequest.url = urlComponents.url
        }
        
        if urlRequest.value(forHTTPHeaderField: HTTPHeaderKey.contentType) == nil {
            urlRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: HTTPHeaderKey.contentType)
        }
    }
    
    private func addPostBody(urlRequest: inout URLRequest, with params: Parameters?) throws {
        guard let params = params else {
            return
        }
        
        do {
            let json = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            urlRequest.httpBody = json
            
            if urlRequest.value(forHTTPHeaderField: HTTPHeaderKey.contentType) == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: HTTPHeaderKey.contentType)
            }
        }catch {
            throw APIError.encodingFailed
        }
    }
    
    // MARK: - Response Handling
    
    private func validateResponse(_ response: URLResponse?, data: Data?) throws {
        guard let response = response as? HTTPURLResponse else {
            throw APIError.noResponse
        }
        
        guard (200..<400).contains(response.statusCode) else {
            throw APIError.badStatusCode(response.statusCode)
        }
        
        guard let _ = data else {
            throw APIError.unknown
        }
    }
    
    @discardableResult private func parseJSON<DecodableDataModel>(jsonData: Data) throws -> DecodableDataModel where DecodableDataModel: Decodable {
        return try JSONDecoder().decode(DecodableDataModel.self, from: jsonData)
    }
    
}
