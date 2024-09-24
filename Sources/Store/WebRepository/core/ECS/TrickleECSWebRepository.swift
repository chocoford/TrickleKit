//
//  TrickleECSWebRepository.swift
//
//
//  Created by Chocoford on 2023/10/18.
//

import Foundation
import WebProvider
import Combine
#if canImport(OSLog)
import OSLog
#else
import Logging
#endif
import TrickleCore

public class TrickleECSWebRepository: WebRepository, TrickleECSWebRepositoryProvider {
    internal init(
        session: URLSession,
        logLevel: [LogOption] = [.response, .data],
        hooks: WebRepositoryHook = .init()
    ) {
        super.init(
            logLevel: logLevel,
            baseURL: URL(string: "https://\(TrickleEnv.trickleDomain)/sapi")!,
            session: session,
            responseDataDecoder: {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .secondsSince1970
                return decoder
            }()
        )
        self.hooks = hooks
    }
}

public extension TrickleECSWebRepository {
    static var `default`: TrickleECSWebRepository {
        TrickleECSWebRepository(session: .shared, logLevel: [.error])
    }
    
    func log(logLevel: [LogOption]) -> Self {
        var repository = self
        repository.logLevel = logLevel
        return repository
    }
}
