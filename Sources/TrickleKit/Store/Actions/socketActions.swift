//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/5/24.
//

import Foundation

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
    
    func tryRegisterAPNs(_ workspaceIDs: [WorkspaceData.ID]) async throws {
        guard let deviceToken = deviceToken else { throw TrickleStoreError.apnsError(.deviceTokenInvalid(nil)) }
        guard let value = userInfo.value, let userInfo = value, let token = userInfo.token else { throw TrickleStoreError.unauthorized }
        
        do {
            let userWorkspaces: [TrickleAPNsHelper.API.RegisterAPNsPayload.UserWorkspace] = workspaceIDs.compactMap {
                if let workspace = workspaces[$0] {
                    return .init(memberID: workspace.userMemberInfo.memberID,
                                 workspaceID: workspace.workspaceID)
                } else {
                    return nil
                }
            }
            _ = try await apnsHelper.registerAPNs(payload: .init(deviceToken: deviceToken,
                                                                 trickleToken: token,
                                                                 userID: userInfo.user.id,
                                                                 env: .dev,
                                                                 userWorkspaces: userWorkspaces))
        } catch {
            throw TrickleStoreError.apnsError(.registerFailed(error))
        }
    }
    
    func registerAPNs(_ workspaceIDs: [WorkspaceData.ID]) async {
        do {
            try await tryRegisterAPNs(workspaceIDs)
        } catch {
            self.error = .init(error)
        }
    }
    
    func logoutAPNs() async {
        do {
            guard let value = userInfo.value, let userInfo = value else { throw TrickleStoreError.unauthorized }
            _ = try await apnsHelper.logoutAPNs(userID: userInfo.user.id)
        } catch {
            self.error = .init(error)
        }
    }
    
    func tryEnablePushNotification(for workspaceID: WorkspaceData.ID) async throws {
        guard let workspace = workspaces[workspaceID] else { throw TrickleStoreError.invalidWorkspaceID(workspaceID) }
        guard let value = userInfo.value,
              let userInfo = value,
              let token = userInfo.token else { throw TrickleStoreError.unauthorized }
        
        _ = try await apnsHelper.unmute(userID: userInfo.user.id,
                                        workspaceID: workspaceID,
                                        memberID: workspace.userMemberInfo.memberID,
                                        token: token)
        
    }
    
    func tryDisablePushNotification(for workspaceID: WorkspaceData.ID) async throws {
        guard let workspace = workspaces[workspaceID] else { throw TrickleStoreError.invalidWorkspaceID(workspaceID) }
        _ = try await apnsHelper.mute(userID: workspace.userID,
                                        workspaceID: workspaceID,
                                        memberID: workspace.userMemberInfo.memberID)
    }
}
