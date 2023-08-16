//
//  apnsActions.swift
//  
//
//  Created by Dove Zachary on 2023/6/26.
//

import Foundation
import TrickleCore

public extension TrickleStoreError {
    enum APNsError: LocalizedError {
        case deviceTokenInvalid(String?)
        case registerFailed(_ error: Error)
        
        var errorDescription: String {
            switch self {
                case .deviceTokenInvalid(let token):
                    return "Device token(\(token ?? "nil") invalid."
                    
                case .registerFailed(let error):
                    return "Register APNs failed: \(error)"
            }
        }
    }
}

public extension TrickleStore {
    func tryRegisterAPNs(_ workspaceEnableStates: TrickleAPNsHelper.RegisterAPNsPayload.WorkspaceEnableStates, isSandbox: Bool = false) async throws {
        if self.deviceToken == nil {
            if #available(macOS 13.0, iOS 16.0, *) {
                try await Task.sleep(for: .seconds(3))
            } else {
                try await Task.sleep(nanoseconds: 3 * 10^9)
            }
        }
        guard let deviceToken = deviceToken else { throw TrickleStoreError.apnsError(.deviceTokenInvalid(nil)) }
        guard let value = userInfo.value, let userInfo = value else { throw TrickleStoreError.unauthorized }
        
        do {

            _ = try await apnsHelper.registerAPNs(payload: .init(deviceToken: deviceToken,
                                                                 userID: userInfo.user.id,
                                                                 env: .init(rawValue: Config.env) ?? TrickleAPNsHelper.Env.dev,
                                                                 workspaceEnableStates: workspaceEnableStates,
                                                                isSandbox: isSandbox))
        } catch {
            throw TrickleStoreError.apnsError(.registerFailed(error))
        }
    }
    
    func registerAPNs(_ workspaceEnableStates: TrickleAPNsHelper.RegisterAPNsPayload.WorkspaceEnableStates, isSandbox: Bool = false) async {
        do {
            try await tryRegisterAPNs(workspaceEnableStates, isSandbox: isSandbox)
        } catch {
            self.error = .init(error)
        }
    }
    
    func tryUpdateAPNsSettings(_ workspaceID: WorkspaceData.ID, enableStates: TrickleAPNsHelper.WorkspaceEnableState, isSandbox: Bool = false) async throws {
        guard let deviceToken = deviceToken else { throw TrickleStoreError.apnsError(.deviceTokenInvalid(nil)) }
        
        do {

            _ = try await apnsHelper.updateAPNsSettings(deviceToken: deviceToken,
                                                        payload: .init(workspaceID: workspaceID,
                                                                       env: .init(rawValue: Config.env) ?? .dev,
                                                                       enableStates: enableStates,
                                                                       isSandbox: isSandbox))
        } catch {
            throw TrickleStoreError.apnsError(.registerFailed(error))
        }
    }
    
    func updateAPNsSettings(_ workspaceID: WorkspaceData.ID,
                            enableStates: TrickleAPNsHelper.WorkspaceEnableState,
                            isSandbox: Bool = false) async {
        do {
            try await tryUpdateAPNsSettings(workspaceID, enableStates: enableStates, isSandbox: isSandbox)
        } catch {
            self.error = .init(error)
        }
    }
    
    func logoutAPNs(isSandbox: Bool) async {
        do {
            guard let deviceToken = deviceToken else { throw TrickleStoreError.apnsError(.deviceTokenInvalid(nil)) }
            _ = try await apnsHelper.logoutAPNs(deviceToken: deviceToken, payload: .init(isSandbox: isSandbox))
        } catch {
            self.error = .init(error)
        }
    }
    
    @available(*, deprecated)
    func tryEnablePushNotification(for workspaceID: WorkspaceData.ID) async throws {
        guard let deviceToken = deviceToken else { throw TrickleStoreError.apnsError(.deviceTokenInvalid(nil)) }
        guard let workspace = workspaces[workspaceID] else { throw TrickleStoreError.invalidWorkspaceID(workspaceID) }
        guard let value = userInfo.value,
              let userInfo = value,
              let token = userInfo.token else { throw TrickleStoreError.unauthorized }
        
        _ = try await apnsHelper.unmute(deviceToken: deviceToken,
                                        workspaceID: workspaceID,
                                        memberID: workspace.userMemberInfo.memberID,
                                        token: token)
        
    }
    
    @available(*, deprecated)
    func tryDisablePushNotification(for workspaceID: WorkspaceData.ID) async throws {
        guard let deviceToken = deviceToken else { throw TrickleStoreError.apnsError(.deviceTokenInvalid(nil)) }
        _ = try await apnsHelper.mute(deviceToken: deviceToken,
                                        workspaceID: workspaceID)
    }
}
