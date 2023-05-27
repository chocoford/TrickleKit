//
//  AuthMiddleware.swift
//  CSWang
//
//  Created by Chocoford on 2022/11/30.
//

import Foundation
import OSLog
import CFWebRepositoryProvider
import TrickleCore

public final class TrickleAuthMiddleware {
    
    public static let shared = TrickleAuthMiddleware()
    static let service = Config.trickleDomain
    static let account = Bundle.main.bundleIdentifier!
    
    let logger = Logger(subsystem: "TrickleKit",
                        category: "AuthMiddleware")
    
    public var token: String? = nil
    
    init() {
        _  = getTokenFromKeychain()
    }
    
    public func getTokenFromKeychain() -> UserInfo? {
        guard let userInfo: UserInfo = KeychainHelper.standard.read(service: Self.service,
                                                                    account: Self.account) else {
            logger.info("no auth info.")
            return nil
        }
        
        self.token = userInfo.token
        
        return userInfo
    }
    
    public func saveTokenToKeychain(userInfo: UserInfo) {
        guard userInfo.token != nil else { return }
        DispatchQueue.global().async {
            KeychainHelper.standard.save(userInfo, service: Self.service, account: Self.account)
        }
        updateToken(token: userInfo.token!)
    }
    
    public func updateToken(token: String) {
        self.token = token
    }
    
    public func removeToken() {
        DispatchQueue.global().async {
            KeychainHelper.standard.delete(service: Self.service, account: Self.account)
        }
        self.token = nil
    }
}
