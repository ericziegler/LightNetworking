//
//  DataExtensions.swift
//  
//
//  Created by Eric Ziegler on 7/23/22.
//

import Foundation

extension Data {
 
    /// Convenience extension to print nicely formatted JSON string
    public var prettyPrintedJSONString: NSString? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
    }
    
    // Appends string as UTF8-encoded data
    mutating func appendString(string: String) {
        guard let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true) else {
            return
        }
        self.append(data)
    }
    
}
