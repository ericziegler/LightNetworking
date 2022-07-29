//
//  Network.swift
//  
//
//  Created by Eric Ziegler on 7/23/22.
//

import Foundation

/// Used to make URL requests, handle URL responses, return decoded data models, and/or throw errors.
public class Network: NSObject {
    
    // MARK: - Properties
    
    internal let networkLogger: NetworkLogger
    internal let urlSession: URLSession
    internal let baseURL: String
    public internal(set) var uploadProgress: UploadProgressBlock?
    
    // MARK: - Init
    
    public init(baseURL: String, logLevel: NetworkLogLevel = .off) {
        networkLogger = NetworkLogger(logLevel: logLevel)
        urlSession = URLSession(configuration: .ephemeral)
        self.baseURL = baseURL
    }
    
    // MARK: - Connectivity

    static func connectionStatus() -> Reachability.Connection {
        do {
            let reachability = try Reachability()
            return reachability.connection
        } catch {
            return .unavailable
        }
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
        // check that we have a network connection
        if Network.connectionStatus() == .unavailable {
            throw APIError.noNetwork
        }
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
    
    internal func buildRequest(from endpoint: Endpoint, timeoutInterval: Double, uploadInfo: UploadInfo? = nil) throws -> URLRequest {
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
        try addPostBody(urlRequest: &request, with: endpoint.bodyParams, uploadInfo: uploadInfo)
        // add additional http headers
        addHTTPHeaders(urlRequest: &request, httpHeaders: endpoint.httpHeaders, uploadInfo: uploadInfo)
        
        return request
    }
    
    private func addHTTPHeaders(urlRequest: inout URLRequest, httpHeaders: HTTPHeaders, uploadInfo: UploadInfo?) {
        for (key, value) in httpHeaders {
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }
        if let _ = uploadInfo {
            // set multiform header since we have data to upload
            let boundary = "Boundary=\(UUID().uuidString)"
            urlRequest.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: HTTPHeaderKey.contentType)
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
    
    private func addPostBody(urlRequest: inout URLRequest, with params: Parameters?, uploadInfo: UploadInfo?) throws {
        if let uploadInfo = uploadInfo, let uploadData = uploadInfo.data {
            // set up upload body from parameters and upload data
            var body = Data();
            let boundary = "Boundary=\(UUID().uuidString)"
            // add params
            if let params = params {
                for (key, value) in params {
                    body.appendString(string: "--\(boundary)\r\n")
                    body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                    body.appendString(string: "\(value)\r\n")
                }
            }
            
            // append file information and upload data
            body.appendString(string: "--\(boundary)\r\n")
            body.appendString(string: "Content-Disposition: form-data; name=\"\(uploadInfo.type.name)\"; filename=\"\(uploadInfo.type.placeholderName)\"\r\n")
            body.appendString(string: "Content-Type: \(uploadInfo.type.mimeType)\r\n\r\n")
            body.append(uploadData)
            body.appendString(string: "\r\n")
            body.appendString(string: "--\(boundary)--\r\n")
            
            urlRequest.httpBody = body
        } else {
            // set up normal body from parameters
            guard let params = params else {
                return
            }
            
            do {
                let json = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
                urlRequest.httpBody = json
                
                if urlRequest.value(forHTTPHeaderField: HTTPHeaderKey.contentType) == nil {
                    urlRequest.setValue("application/json", forHTTPHeaderField: HTTPHeaderKey.contentType)
                }
            } catch {
                throw APIError.encodingFailed
            }
        }
    }
    
    // MARK: - Response Handling
    
    internal func validateResponse(_ response: URLResponse?, data: Data?) throws {
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
