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
    
    public init(session: URLSession, baseURL: String = "https://\(Config.apiDomain)", logLevel: [LogOption] = [.response, .data]) {
        self.session = session
        self.baseURL = baseURL
        self.logLevel = logLevel
    }
}
