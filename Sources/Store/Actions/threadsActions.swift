//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/6.
//

import Foundation
import TrickleCore

public extension TrickleStore {
    func loadMoreThreads(_ workspaceID: WorkspaceData.ID, option: LoadMoreOption, silent: Bool = false, reset: Bool = false) async {
        guard let theWorkspace = workspaces[workspaceID] else { return }
        if !silent {
            workspaceThreadIDs[workspaceID]?.setIsLoading()
        }
        let nextTs = workspaceThreads[workspaceID]?.value?.nextTs ?? Int(Date.now.timeIntervalSince1970)

        do {
            switch option {
                case .newer(let since):
                    let data = try await webRepositoryClient.listWorkspaceThreads(workspaceID: workspaceID,
                                                                                  memberID: theWorkspace.userMemberInfo.memberID,
                                                                                  query: .init(until: Int(since?.timeIntervalSince1970 ?? (workspaceThreads[workspaceID]?.value?.items.first?.updateAt ?? .now).timeIntervalSince1970),
                                                                                               limit: 1000,
                                                                                               order: .asc))
                    prependThreads(data, to: workspaceID)
                    
                case .older(let since):
                    let data = try await webRepositoryClient.listWorkspaceThreads(workspaceID: workspaceID,
                                                                                  memberID: theWorkspace.userMemberInfo.memberID,
                                                                                  query: .init(until: Int(since?.timeIntervalSince1970) ?? nextTs,
                                                                                               limit: 20 ,
                                                                                               order: .desc))
                    if reset {
                        resetThreads(data, of: workspaceID)
                    } else {
                        appendThreads(data, to: workspaceID)
                    }
            }
        } catch {
            self.error = .init(error)
            workspaceThreadIDs[workspaceID]?.setAsFailed(error)
        }
    }

    func tryGetThreadsUnreadCount(_ workspaceID: WorkspaceData.ID) async throws -> Int {
        guard let theWorkspace = workspaces[workspaceID] else { throw TrickleStoreError.invalidWorkspaceID(workspaceID) }
        
        do {
            let data = try await webRepositoryClient.getWorkspaceThreadsUnreadCount(workspaceID: workspaceID, memberID: theWorkspace.userMemberInfo.memberID)
            return data.unreadCount
        } catch {
            throw error
        }
        
    }
    
    func getAllThreadsUnreadCount() async {
        do {
            for workspace in workspaces.values {
                let count = try await tryGetThreadsUnreadCount(workspace.workspaceID)
                workspacesThreadsUnreadCount[workspace.workspaceID] = count
            }
        } catch {
            self.error = .init(error)
        }
    }
    
    func getThreadsUnreadCount(_ workspaceID: WorkspaceData.ID) async {
        do {
            let count = try await tryGetThreadsUnreadCount(workspaceID)
            workspacesThreadsUnreadCount[workspaceID] = count
        } catch {
            self.error = .init(error)
        }
    }
}

public extension TrickleStore {
    func appendThreads(_ threads: AnyStreamable<TrickleData>, to workspaceID: WorkspaceData.ID) {
        _updateTrickles(threads.items)
        workspaceThreadIDs[workspaceID] = .loaded(data: workspaceThreadIDs[workspaceID]?.value?.appending(threads.map{$0.trickleID}) ?? threads.map{$0.trickleID})
    }
    
    func prependThreads(_ threads: AnyStreamable<TrickleData>, to workspaceID: WorkspaceData.ID) {
        _updateTrickles(threads.items)
        workspaceThreadIDs[workspaceID] = .loaded(data: workspaceThreadIDs[workspaceID]?.value?.prepending(threads.map{$0.trickleID}) ?? threads.map{$0.trickleID})
    }
    
    
    func reorderThreads(_ workspaceID: WorkspaceData.ID) {
        workspaceThreadIDs[workspaceID] = workspaceThreadIDs[workspaceID]?.map{ .init(items: $0.items.sorted(by: {trickles[$0]?.updateAt ?? .distantPast > trickles[$1]?.updateAt ?? .distantPast}),
                                                                                      nextTs: $0.nextTs) }
    }
    
    
    func resetThreads(_ threads: AnyStreamable<TrickleData>, of workspaceID: WorkspaceData.ID) {
        _updateTrickles(threads.items)
        workspaceThreadIDs[workspaceID] = .loaded(data: threads.map{$0.trickleID})
    }
    func resetThreads(_ workspaceID: WorkspaceData.ID) {
        workspaceThreadIDs[workspaceID] = .loaded(data: .init(items: [], nextTs: Int(Date.now.timeIntervalSince1970)))
    }
    
}
