//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/6.
//

import Foundation

extension Optional: RawRepresentable where Wrapped: Codable {
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let json = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }
        return json
    }

    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let value = try? JSONDecoder().decode(Self.self, from: data)
        else {
            return nil
        }
        self = value
    }
}

extension Dictionary: RawRepresentable where Key == String, Value == String {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),  // convert from String to Data
            let result = try? JSONDecoder().decode([String:String].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),   // data is  Data type
              let result = String(data: data, encoding: .utf8) // coerce NSData to String
        else {
            return "[:]"  // empty Dictionary respresented as String
        }
        return result
    }

}
