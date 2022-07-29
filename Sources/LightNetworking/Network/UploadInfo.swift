//
//  UploadInfo.swift
//  
//
//  Created by Eric Ziegler on 7/29/22.
//

import Foundation

// type of upload with conveniences for metadata based on type
public enum UploadType {
    case video
    case image
    
    var mimeType: String {
        switch self {
        case .video:
            return "video/mp4"
        case .image:
            return "image/jpeg"
        }
    }
    
    var placeholderName: String {
        switch self {
        case .video:
            return "placeholder.mov"
        case .image:
            return "placeholder.jpeg"
        }
    }
    
    var name: String {
        return "file"
    }
}

public struct UploadInfo {
    public let type: UploadType
    public let data: Data?
    
    public init(type: UploadType, data: Data?) {
        self.type = type
        self.data = data
    }
}


