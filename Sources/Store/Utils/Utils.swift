//
//  File.swift
//  
//
//  Created by Chocoford on 2023/5/31.
//

import Foundation
#if DEBUG

func load<T: Decodable>(_ filename: String, type: T.Type) -> T {
    return load(filename)
}

func load<T: Decodable>(_ filename: String) -> T {
    let data: Data

    guard let file = Bundle.module.url(forResource: filename, withExtension: nil)
        else {
            fatalError("Couldn't find \(filename) in main bundle.")
    }

    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from module bundle:\n\(error)")
    }

    do {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return try decoder.decode(T.self, from: data)
    } catch {
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
    }
}

#endif
