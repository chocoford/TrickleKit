//
//  Dictionary+Extension.swift
//  
//
//  Created by Chocoford on 2023/3/19.
//

import Foundation

extension Dictionary where Key: Codable, Value: Codable {
    public func decode<T: Codable>(to: T.Type) throws -> T {
        let data = try JSONEncoder().encode(self)
        return try JSONDecoder().decode(T.self, from: data)
    }
}

