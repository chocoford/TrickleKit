//
//  File.swift
//  
//
//  Created by Dove Zachary on 2023/6/29.
//

import Foundation
import TrickleCore

public extension TrickleStore {
    func tryLoadMoreDirectMessages(workspaceID: WorkspaceData.ID, option: LoadMoreOption) async throws -> AnyStreamable<TrickleData> {
        guard let workspace = self.workspaces[workspaceID] else { throw TrickleStoreError.invalidWorkspaceID(workspaceID) }
        
        let data: AnyStreamable<TrickleData>
        switch option {
            case .older(let since):
                let until = Int(since?.timeIntervalSince1970) ?? self.workspacesDirectMessageIDs[workspaceID]?.value?.nextTs ?? Int(Date.now.timeIntervalSince1970)
                data = try await webRepositoryClient.listWorkspaceDirectMessages(workspaceID: workspaceID, memberID: workspace.userMemberInfo.memberID,
                                                                                 query: .init(until: until,
                                                                                              limit: 20,
                                                                                              order: .desc))
            case .newer(let since):
                let until = Int(since?.timeIntervalSince1970 ?? self.workspacesDirectMessages[workspaceID]?.value?.items.first?.updateAt?.timeIntervalSince1970)
                data = try await webRepositoryClient.listWorkspaceDirectMessages(workspaceID: workspaceID, memberID: workspace.userMemberInfo.memberID,
                                                                                 query: .init(until: until,
                                                                                              limit: 20,
                                                                                              order: .asc))
        }
        
        data.items.forEach { self.insertTrickle($0) }
        self.workspacesDirectMessageIDs[workspaceID] = .loaded(data: data.map{ $0.trickleID })

        return data
    }
    
    func loadMoreDirectMessages(workspaceID: WorkspaceData.ID, option: LoadMoreOption) async {
        do {
            _ = try await tryLoadMoreDirectMessages(workspaceID: workspaceID, option: option)
        } catch {
            self.error = .init(error)
        }
    }
    
    func tryCreateDirectMessage(workspaceID: WorkspaceData.ID, memberID: MemberData.ID, targetMemberID: MemberData.ID) async throws -> TrickleData {
        let trickleData = try await webRepositoryClient.createWorkspaceDirectMessage(workspaceID: workspaceID, memberID: memberID, payload: .init(targetMemberID: targetMemberID))
        
        self.insertTrickle(trickleData)
        if self.workspacesDirectMessageIDs[workspaceID]?.value?.items.contains(trickleData.trickleID) == false {
            self.workspacesDirectMessageIDs[workspaceID] = .loaded(data: .init(items: [trickleData.trickleID] + (self.workspacesDirectMessageIDs[workspaceID]?.value?.items ?? []),
                                                                               nextTs: self.workspacesDirectMessageIDs[workspaceID]?.value?.nextTs))
        }
        
        return trickleData
    }
    
    func getDirectMessagesUnreadCount(workspaceID: WorkspaceData.ID) async {
        do {
            guard let workspace = self.workspaces[workspaceID] else { throw TrickleStoreError.invalidWorkspaceID(workspaceID) }
            let data = try await webRepositoryClient.getWorkspaceDirectMessagesUnreadCount(workspaceID: workspaceID, memberID: workspace.userMemberInfo.memberID)
            workspacesDirectMessagesUnreadCount[workspaceID] = data.unreadCount
        } catch {
            self.error = .init(error)
        }
    }
}
