//
//  File.swift
//  
//
//  Created by Chocoford on 2023/6/29.
//

import Foundation
import TrickleCore

public extension TrickleStore {
    func tryLoadMoreDirectMessages(
        workspaceID: WorkspaceData.ID,
        option: LoadMoreOption,
        silent: Bool = false
    ) async throws -> AnyStreamable<TrickleData> {
        guard let workspace = self.workspaces[workspaceID] else { throw TrickleStoreError.invalidWorkspaceID(workspaceID) }
        
        if !silent { self.workspacesDirectMessageIDs[workspaceID]?.setIsLoading() }
        
        let query: TrickleWebRepository.API.ListQuery
        switch option {
            case .older(let since):
                query = .init(
                    until: since ?? self.workspacesDirectMessageIDs[workspaceID]?.value?.nextTs ?? .now,
                    limit: 20,
                    order: .desc
                )
            case .newer(let since):
                query = .init(
                    until: since ?? self.workspacesDirectMessages[workspaceID]?.value?.items.first?.updateAt ?? .now,
                    limit: 20,
                    order: .asc
                )
            case .refresh:
                query = .init(
                    until: .now,
                    limit: 20,
                    order: .desc
                )
        }
        
        let data = try await webRepositoryClient.listWorkspaceDirectMessages(
            workspaceID: workspaceID, memberID: workspace.userMemberInfo.memberID,
            query: query
        )
        
        // TODO: ...
        switch option {
            case .newer:
                self._updateTrickles(data.items)
            case .older:
                self._updateTrickles(data.items)
            case .refresh:
                self._updateTrickles(data.items)
        }
        
        self.workspacesDirectMessageIDs[workspaceID] = .loaded(data: data.map{ $0.trickleID })

        return data
    }
    
    func loadMoreDirectMessages(workspaceID: WorkspaceData.ID, option: LoadMoreOption, silent: Bool = false) async {
        do {
            _ = try await tryLoadMoreDirectMessages(workspaceID: workspaceID, option: option, silent: silent)
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
