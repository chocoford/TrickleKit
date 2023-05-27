//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/5/7.
//

import Foundation

public extension String {
    func toJSON() -> [String: Any]? {
        guard let data = self.data(using: .utf8) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [String: Any]
    }
    
    func decode<T: Decodable>(_ type: T.Type, onFailed: ((_ error: Error) -> Void)? = nil) -> T? {
        guard let data = self.data(using: .utf8) else { return nil }
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            return try decoder.decode(type.self, from: data)
        } catch {
            if let onFailed = onFailed {
                onFailed(error)
            }
        }
        return nil
    }
    
    func snakeCased() -> Self {
       let acronymPattern = "([A-Z]+)([A-Z][a-z]|[0-9])"
       let fullWordsPattern = "([a-z])([A-Z]|[0-9])"
       let digitsFirstPattern = "([0-9])([A-Z])"
       return self.processCamelCaseRegex(pattern: acronymPattern)?
         .processCamelCaseRegex(pattern: fullWordsPattern)?
         .processCamelCaseRegex(pattern:digitsFirstPattern)?.lowercased() ?? self.lowercased()
     }

     fileprivate func processCamelCaseRegex(pattern: String) -> Self? {
       let regex = try? NSRegularExpression(pattern: pattern, options: [])
       let range = NSRange(location: 0, length: count)
       return regex?.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: "$1_$2")
     }
    
    // MARK: - NSRegex
    func matches(regex: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: regex) else { return false }
        let range = NSRange(location: 0, length: self.utf16.count)
        return regex.firstMatch(in: self, options: [], range: range) != nil
    }
}
