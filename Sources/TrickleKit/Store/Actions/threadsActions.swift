//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/6.
//

import Foundation

public extension TrickleStore {
     func loadMoreThreads(_ workspaceID: WorkspaceData.ID?, option: LoadMoreOption) async {
        guard let workspaceID = workspaceID ?? currentWorkspaceID,
              let theWorkspace = workspaces[workspaceID] else { return }
        
        workspaceThreadIDs[workspaceID]?.setIsLoading()
        guard let nextTs = workspaceThreads[workspaceID]?.value?.nextTs else { return }

        do {
            let data = try await webRepositoryClient.listWorkspaceThreads(workspaceID: workspaceID,
                                                                          memberID: theWorkspace.userMemberInfo.memberID,
                                                                          query: .init(until: nextTs, limit: 20, order: option == .older ? .desc : .asc))

            data.items.forEach { trickleData in
                trickles[trickleData.trickleID] = trickleData
            }
            workspaceThreadIDs[workspaceID] = .loaded(data: workspaceThreadIDs[workspaceID]?.value?.appending(data.map{$0.trickleID}) ?? data.map{$0.trickleID})
            
        } catch {
            self.error = .init(error)
            workspaceThreadIDs[workspaceID] = .failed(.init(error))
        }
    }
    
    func resetThreads(_ workspaceID: WorkspaceData.ID) {
        workspaceThreadIDs[workspaceID] = .loaded(data: .init(items: [], nextTs: Int(Date.now.timeIntervalSince1970)))
    }
}
