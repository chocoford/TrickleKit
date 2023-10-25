//
//  File.swift
//  
//
//  Created by Chocoford on 2023/3/17.
//

import Foundation
import CFWebRepositoryProvider
import Combine
import Logging
import TrickleCore

public struct TrickleWebRepository: TrickleWebRepositoryProvider {
    public var logLevel: [LogOption]
    public var logger: Logger = .init(label: "TrickleWebRepository")
    public var session: URLSession
    public var baseURL: String
    public var bgQueue: DispatchQueue = DispatchQueue(label: "bg_trickle_queue")
    public var responseDataDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()
    
    public var hooks: WebRepositoryHook
    
    internal init(
        session: URLSession,
        baseURL: String = "https://\(TrickleEnv.apiDomain)",
        logLevel: [LogOption] = [.response, .data],
        hooks: WebRepositoryHook = .init()
    ) {
        self.session = session
        self.baseURL = baseURL
        self.logLevel = logLevel
        self.hooks = hooks
    }
}

public extension TrickleWebRepository {
    static var `default`: TrickleWebRepository {
        TrickleWebRepository(session: .shared, logLevel: [.error])
    }
    
    func log(logLevel: [LogOption]) -> Self {
        var repository = self
        repository.logLevel = logLevel
        return repository
    }
}
