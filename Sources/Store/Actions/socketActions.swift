//
//  File.swift
//  
//
//  Created by Chocoford on 2023/5/24.
//

import Foundation
import TrickleCore
import TrickleSocketSupport

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
    
    func addSocketEventHandler(_ handler: @escaping (IncomingMessageType) -> Void) async {
        self.socket.onMessage = { message in
            switch message {
                case .changeNotify(let event):
                    self.handleChangeNotify(event.data ?? [])
                    
                default:
                    break
            }
            
            handler(message)
        }
    }
}
