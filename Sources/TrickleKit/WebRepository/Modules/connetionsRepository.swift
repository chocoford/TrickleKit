//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/16.
//

import Foundation

public extension TrickleWebRepository {
    func getSupportedConnections() async throws -> AnyStreamable<Connection> {
        try await call(endpoint: API.getSupportedConnections)
    }
}
