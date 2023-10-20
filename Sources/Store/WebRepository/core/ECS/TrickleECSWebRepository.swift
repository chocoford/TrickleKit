//
//  TrickleECSWebRepository.swift
//
//
//  Created by Chocoford on 2023/10/18.
//

import Foundation
import CFWebRepositoryProvider
import Combine
import Logging
import TrickleCore

public struct TrickleECSWebRepository: TrickleECSWebRepositoryProvider {
    public var logLevel: [LogOption]
    public var logger: Logger = .init(label: "TrickleECSWebRepository")
    public var session: URLSession
    public var baseURL: String
    public var bgQueue: DispatchQueue = DispatchQueue(label: "trickle_ecs_bg_queue")
    public var responseDataDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()
    
    internal init(session: URLSession, baseURL: String = "https://\(TrickleEnv.trickleDomain)/sapi", logLevel: [LogOption] = [.response, .data]) {
        self.session = session
        self.baseURL = baseURL
        self.logLevel = logLevel
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
