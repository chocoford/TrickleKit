//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/5/24.
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
    func reestablishSocket() {
        self.socket.reinitSocket()
        // subscribe workspaces
        Task {
            await subscribeWorkspaces()
        }
        // join room
        Task {
            await joinAllWorkspaces()
        }
        
    }
    
    func disconnectSocket() {
        Task {
            await leaveAllWorkspaces()
            self.socket.close()
        }
    }

    func joinWorkspace(_ workspace: WorkspaceData) async {
        await self.socket.joinRoom(workspaceID: workspace.workspaceID, memberID: workspace.userMemberInfo.memberID)
    }
    func joinAllWorkspaces() async {
        for workspace in workspaces.values {
            await self.socket.joinRoom(workspaceID: workspace.workspaceID, memberID: workspace.userMemberInfo.memberID)
        }
    }
    func leaveWorkspaces(_ workspace: WorkspaceData) async {
        await self.socket.leaveRoom(workspaceID: workspace.workspaceID, memberID: workspace.userMemberInfo.memberID)
    }
    func leaveAllWorkspaces() async {
        for workspace in workspaces.values {
            await self.socket.leaveRoom(workspaceID: workspace.workspaceID, memberID: workspace.userMemberInfo.memberID)
        }
    }
    
    func subscribeWorkspaces() async {
        guard case .loaded(let value) = userInfo, let userInfo = value else { return }
        let workspaceIDs = workspaces.values.map{ $0.workspaceID }
        if !workspaceIDs.isEmpty {
            await self.socket.subscribeWorksaces(workspaceIDs, userID: userInfo.user.id)
        }
    }
    
    func tryRegisterAPNs(_ workspaceEnableStates: TrickleAPNsHelper.RegisterAPNsPayload.WorkspaceEnableStates, isSandbox: Bool = false) async throws {
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
