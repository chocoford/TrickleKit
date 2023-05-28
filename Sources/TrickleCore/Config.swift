//
//  Config.swift
//  TrickleAnyway
//
//  Created by Chocoford on 2023/2/4.
//

import Foundation

public struct Config {
#if DEBUG
    public static let env = ProcessInfo.processInfo.environment["TRICKLE_ENV"] ?? "dev"
    public static let trickleDomain = ProcessInfo.processInfo.environment["TRICKLE_DOMAIN"] ?? "devapp.trickle.so"
    public static let apiDomain = ProcessInfo.processInfo.environment["TRICKLE_API_DOMAIN"] ?? "devapi.trickle.so"
    public static let webSocketDomain = ProcessInfo.processInfo.environment["TRICKLE_WS_DOMAIN"] ?? "devwsapi.trickle.so"
    public static let ossBucket = ProcessInfo.processInfo.environment["OSS_BUCKET"] ?? ""
    public static let ossAssetsDomain = ProcessInfo.processInfo.environment["OSS_ASSETS_DOMAIN"] ?? ""
#else
    public static let env = "live"
    public static let trickleDomain = "app.trickle.so"
    public static let apiDomain = "api.trickle.so"
    public static let webSocketDomain = "wsapi.trickle.so"
    public static let ossBucket = "trickle-resource-live"
    public static let ossAssetsDomain = "resource.trickle.so"
#endif

}
