//
//  Network+Uploads.swift
//  
//
//  Created by Eric Ziegler on 7/29/22.
//

import Foundation

extension Network: URLSessionDelegate {
    
    public func upload(uploadInfo: UploadInfo, endpoint: Endpoint, timeoutInterval: Double = 60.0, progress: UploadProgressBlock?) async throws -> Data? {
        // check that we have the necessary information
        if Network.connectionStatus() == .unavailable {
            throw APIError.noNetwork
        }

        // build request
        let request = try buildRequest(from: endpoint, timeoutInterval: timeoutInterval, uploadInfo: uploadInfo)
        // debug log the request
        networkLogger.log(request: request)
        // create the special upload urlSession, setting the delegate to watch for progress
        let uploadSession = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: OperationQueue.main)
        // set the upload closure
        uploadProgress = progress
        // send the request
        let (data, response) = try await uploadSession.data(for: request)
        // debug log the response
        networkLogger.log(response: response, data: data)
        // validate the HTTP status code and the existence of data
        try validateResponse(response, data: data)
        // return the raw data
        return data
    }
 
    private func createBodyWithParameters(parameters: [String: String]?, fileDataPath: Data, boundary: String, uploadInfo: UploadInfo) -> Data {
        var body = Data();
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.appendString(string: "--\(boundary)\r\n")
                body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString(string: "\(value)\r\n")
            }
        }
                
        body.appendString(string: "--\(boundary)\r\n")
        body.appendString(string: "Content-Disposition: form-data; name=\"\(uploadInfo.type.name)\"; filename=\"\(uploadInfo.type.placeholderName)\"\r\n")
        body.appendString(string: "Content-Type: \(uploadInfo.type.mimeType)\r\n\r\n")
        body.append(fileDataPath)
        body.appendString(string: "\r\n")
        

        body.appendString(string: "--\(boundary)--\r\n")
        
        return body
    }
    
    // MARK: - URLSessionDelegate
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let progress = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        uploadProgress?(progress)
    }
    
}
