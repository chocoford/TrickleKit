//
//  Config.swift
//  TrickleAnyway
//
//  Created by Chocoford on 2023/2/4.
//

import Foundation

public struct TrickleEnv {
    public static var env = ProcessInfo.processInfo.environment["TRICKLE_ENV"] ?? "live"
    public static var trickleDomain = ProcessInfo.processInfo.environment["TRICKLE_DOMAIN"] ?? "testapp.trickle.so"
    public static var apiDomain = ProcessInfo.processInfo.environment["TRICKLE_API_DOMAIN"] ?? "testapi.trickle.so"
    public static var webSocketDomain = ProcessInfo.processInfo.environment["TRICKLE_WS_DOMAIN"] ?? "testwsapi.trickle.so"
    public static var ossBucket = ProcessInfo.processInfo.environment["OSS_BUCKET"] ?? "trickle-resource-test"
    public static var ossAssetsDomain = ProcessInfo.processInfo.environment["OSS_ASSETS_DOMAIN"] ?? "testres.trickle.so"
    
    public static var aiActionDomain = ProcessInfo.processInfo.environment["TRICKLE_AI_ACTION_DOMAIN"] ?? "ai.trickle.so"
    
    public enum EnvType {
        case dev, test, live, aiDev, aiLive
    }
    
    public static func setup(_ type: EnvType) {
        switch type {
            case .dev:
                TrickleEnv.env = "dev"
                TrickleEnv.trickleDomain = "devapp.trickle.so"
                TrickleEnv.apiDomain = "devapi.trickle.so"
                TrickleEnv.webSocketDomain = "devwsapi.trickle.so"
                TrickleEnv.ossBucket = "boom2-resource"
                TrickleEnv.ossAssetsDomain = "devres.trickle.so"
                TrickleEnv.aiActionDomain = "devapp.trickle.so"
            case .test:
                TrickleEnv.env = "test"
                TrickleEnv.trickleDomain = "testapp.trickle.so"
                TrickleEnv.apiDomain = "testapi.trickle.so"
                TrickleEnv.webSocketDomain = "testwsapi.trickle.so"
                TrickleEnv.ossBucket = "trickle-resource-test"
                TrickleEnv.ossAssetsDomain = "testres.trickle.so"
                TrickleEnv.aiActionDomain = "ai.trickle.so"
            case .live:
                TrickleEnv.env = "live"
                TrickleEnv.trickleDomain = "app.trickle.so"
                TrickleEnv.apiDomain = "api.trickle.so"
                TrickleEnv.webSocketDomain = "wsapi.trickle.so"
                TrickleEnv.ossBucket = "trickle-resource-live"
                TrickleEnv.ossAssetsDomain = "https://resource.trickle.so"
                TrickleEnv.aiActionDomain = "ai.trickle.so"
            case .aiDev:
                TrickleEnv.env = "dev"
                TrickleEnv.trickleDomain = "devapp.trickle.so"
                TrickleEnv.apiDomain = "devapi.trickle.so"
                TrickleEnv.webSocketDomain = "devwsapi.trickle.so"
                TrickleEnv.ossBucket = "boom2-resource"
                TrickleEnv.ossAssetsDomain = "devres.trickle.so"
                TrickleEnv.aiActionDomain = "devapp.trickle.so"
            case .aiLive:
                TrickleEnv.env = "live"
                TrickleEnv.trickleDomain = "ai.trickle.so"
                TrickleEnv.apiDomain = "aiapi.trickle.so"
                TrickleEnv.webSocketDomain = "testwsapi.trickle.so"
                TrickleEnv.ossBucket = "trickle-resource-test"
                TrickleEnv.ossAssetsDomain = "testres.trickle.so"
                TrickleEnv.aiActionDomain = "ai.trickle.so"
        }
    }
}
