//
//  JSONParser.swift
//  
//
//  Created by Eric Ziegler on 7/29/22.
//

import Foundation

/// Contains functions that take Data (formatted as JSON), and decodes into a specific data type
public class JSONParser {
 
    /// Parses JSON data and returns a decoded data model
    ///
    /// - Paramters:
    /// - json: Data to be decoded into a data model
    ///
    /// - Returns: A decoded data model populated from the JSON
    ///
    /// - Throws: An API Error
    public static func parse<DecodableDataModel: Codable>(json: Data?) throws -> DecodableDataModel {
        guard let json = json else {
            throw APIError.decodingFailed
        }
        
        let dataModel = try JSONDecoder().decode(DecodableDataModel.self, from: json)
        return dataModel
    }
    
}
