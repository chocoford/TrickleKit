//
//  File.swift
//  
//
//  Created by Chocoford on 2023/4/6.
//

import Foundation
import TrickleCore

public extension TrickleStore {
    func tryLoadNewerViewTrickles(_ viewID: GroupData.ViewInfo.ID, groupByID: FieldOptions.FieldOptionInfo.ID = "NULL", nextQuery: NextQuery? = nil) async throws {
        // setIsLoading make view been redrawn, which will cancel the refresh processs
//        viewsTrickleIDs[viewID]?[groupByID]?.setIsLoading()
        guard let view = views[viewID] else { throw TrickleStoreError.invalidViewID(viewID) }
        
        let group = try findViewGroup(viewID)
        let workspace = try findGroupWorkspace(group.groupID)
        
        let query: NextQuery = nextQuery ?? .mock(workspace: workspace, view: view, groupByID: groupByID, limit: 20)

        do {
            let data = try await webRepositoryClient.listGroupTrickles(workspaceID: workspace.workspaceID,
                                                                       groupID: group.groupID,
                                                                       query: query)
            guard let trickleID = data.items.last?.trickleID else { return }
            let encounterExisted = viewsTrickleIDs[viewID]?[groupByID]?.value?.items.contains(trickleID) == true
            prependTrickles(data, to: viewID)
            if !encounterExisted {
                try await tryLoadNewerViewTrickles(viewID, groupByID: groupByID, nextQuery: data.nextQuery)
            }
        } catch {
            throw error
        }
    }
    
    func tryLoadOlderViewTrickles(_ viewID: GroupData.ViewInfo.ID,
                                  groupByID: FieldOptions.FieldOptionInfo.ID = "NULL",
                                  since: Date?,
                                  silent: Bool = false) async throws {
        if !silent {
            viewsTrickleIDs[viewID]?[groupByID]?.setIsLoading()
        }
        do {
            let group = try findViewGroup(viewID)
            let theWorkspace = try findGroupWorkspace(group.groupID)
            
            
            let query: NextQuery?
            if let since = since {
                query = NextQuery(memberID: theWorkspace.userMemberInfo.memberID,
                          limit: 20,
                          filters: nil,
                          sorts: [.init(type: "create_on",
                                        fieldID: nil,
                                        isDescent: true,
                                        next: .int(Int(since.timeIntervalSince1970)))],
                          groupByFilters: nil,
                          filterLogicalOperator: .and)
            } else {
                query = viewsTrickleIDs[viewID]?[groupByID]?.value?.nextQuery
            }
            
            guard let query = query else { return }
            let data = try await webRepositoryClient.listGroupTrickles(workspaceID: theWorkspace.workspaceID,
                                                                       groupID: group.groupID,
                                                                       query: query)
            
            appendTrickles(data, to: viewID, groupByID: groupByID)
        } catch {
            viewsTrickleIDs[viewID]?[groupByID]?.setAsFailed(error)
            throw error
        }
    }
    
    
    func loadMoreViewTrickles(_ viewID: GroupData.ViewInfo.ID, groupByID: FieldOptions.FieldOptionInfo.ID = "NULL", target: LoadMoreOption, silent: Bool = false) async {
        do {
            let group = try findViewGroup(viewID)
            let workspace = try findGroupWorkspace(group.groupID)
            switch target {
                case .newer(let since):
                    try await tryLoadNewerViewTrickles(viewID, groupByID: groupByID, nextQuery: .morkFeed(workspace: workspace,
                                                                                                          isDescent: false,
                                                                                                          since: since,
                                                                                                          limit: 20))
                case .older(let since):
                    try await tryLoadOlderViewTrickles(viewID, groupByID: groupByID, since: since, silent: silent)
            }
        } catch {
            self.error = .init(error)
        }
    }

    func tryCopyTrickle(trickleID: TrickleData.ID, to groupID: GroupData.ID, afterTrickleID: TrickleData.ID? = nil) async throws {
        guard var trickle = trickles[trickleID] else { throw TrickleStoreError.invalidTrickleID(trickleID) }
        let group = try findTrickleGroup(trickleID)
        let workspace = try findGroupWorkspace(group.groupID)
        
        let tempID = UUID().uuidString
        trickle.trickleID = tempID
        trickle.authorMemberInfo = workspace.userMemberInfo
        trickle.commentCounts = 0
        trickle.reactionInfo = []
        trickle.createAt = .now
        trickle.editAt = nil
        trickle.editBy = nil
        trickle.editingMemberInfo = []
        trickle.viewedMemberInfo = .init(counts: 0, members: [])
        trickle.isPinned = false
        trickle.hasStarred = false
                
        insertTrickle(trickle, to: group.groupID, after: afterTrickleID) { viewID in
            viewsTrickleIDs[viewID]?.first(where: { (key, value) in
                value.value?.items.contains(trickleID) == true
            })?.key
        }
        
        do {
            let data = try await webRepositoryClient.copyTrickle(workspaceID: workspace.workspaceID,
                                                                 trickleID: trickleID,
                                                                 payload: .init(oldReceiverID: group.groupID,
                                                                                newReceiverID: groupID,
                                                                                memberID: workspace.userMemberInfo.memberID,
                                                                                afterTrickleID: afterTrickleID))
            var newTrickle = trickle
            newTrickle.trickleID = data.trickleID
            updateTrickle(from: trickle, to: newTrickle, in: group)
        } catch {
            removeTrickle(trickle.trickleID, in: group)
            throw error
        }
    }
    
    func copyTrickle(trickleID: TrickleData.ID, to groupID: GroupData.ID, afterTrickleID: TrickleData.ID? = nil) async {
        do {
             try await tryCopyTrickle(trickleID: trickleID, to: groupID, afterTrickleID: afterTrickleID)
        } catch {
            self.error = .init(error)
        }
    }
    
    func tryDuplicateTrickle(trickleID: TrickleData.ID, afterTrickleID: TrickleData.ID? = nil) async throws {
        let group = try findTrickleGroup(trickleID)
        try await tryCopyTrickle(trickleID: trickleID, to: group.groupID)
    }
    
    func duplicateTrickle(trickleID: TrickleData.ID, afterTrickleID: TrickleData.ID? = nil) async {
        do {
            try await tryDuplicateTrickle(trickleID: trickleID, afterTrickleID: afterTrickleID)
        } catch {
            self.error = .init(error)
        }
    }
    
    func tryAddTrickleLastView(trickleID: TrickleData.ID) async throws {
        let workspace = try findTrickleWorkspace(trickleID)
        guard let originalLastViewInfo = trickles[trickleID]?.lastViewInfo else {
            throw TrickleStoreError.invalidTrickleID(trickleID)
        }
        trickles[trickleID]?.lastViewInfo.lastViewedAt = .now
        addViewedMember(workspace.userMemberInfo.memberID, to: trickleID)
        do {
            _ = try await webRepositoryClient.addTrickleLastView(workspaceID: workspace.workspaceID, trickleID: trickleID, payload: .init(memberID: workspace.userMemberInfo.memberID))
        } catch {
            trickles[trickleID]?.lastViewInfo.lastViewedAt = originalLastViewInfo.lastViewedAt
            removeViewedMember(workspace.userMemberInfo.memberID, of: trickleID)
            throw error
        }
    }
    
    func addTrickleLastView(trickleID: TrickleData.ID) async {
        do {
            try await tryAddTrickleLastView(trickleID: trickleID)
        } catch {
            self.error = .init(error)
        }
    }
}


public extension TrickleStore {
    /// reset group trickles
    @available(*, deprecated)
    func resetGroupTrickles(_ groupID: String?) {}
    
    func resetViewTrickles(_ viewID: GroupData.ViewInfo.ID) {
        guard let view = views[viewID],
              let group = try? findViewGroup(viewID),
              let workspace = try? findGroupWorkspace(group.groupID)
        else { return }
        
        if let groupBy = view.groupBy {
            if let stats = viewsTricklesStat[viewID]?.value?.stats {
                viewsTrickleIDs[viewID] = stats.map {
                    [$0.groupID : .loaded(data: .init(items: [],
                                                      nextQuery: .init(memberID: workspace.userMemberInfo.memberID,
                                                                       limit: 20,
                                                                       filters: view.filters,
                                                                       sorts: view.sorts ?? [],
                                                                       groupByFilters: .init(fieldID: groupBy.fieldID,
                                                                                             type: groupBy.type,
                                                                                             value: $0.groupID == "NULL" ? .null : (groupBy.type.isMulti ? .strings([$0.groupID]) : .string($0.groupID)),
                                                                                             operatorID: nil,
                                                                                             filterOperator: groupBy.type.isMulti ? .contains : .eq),
                                                                       filterLogicalOperator: .and)))]
                }
                .merged()
            } else {
                viewsTrickleIDs[viewID] = [:]
            }
        } else {
            viewsTrickleIDs[viewID] = ["NULL" : .loaded(data: .init(items: [],
                                                                    nextQuery: .init(memberID: workspace.userMemberInfo.memberID,
                                                                                     limit: 20,
                                                                                     filters: view.filters,
                                                                                     sorts: view.sorts ?? [],
                                                                                     groupByFilters: nil,
                                                                                     filterLogicalOperator: .and)))]
        }
    }
    
    /// Insert the trickle to the specific group after the specific trickle. This function will insert the trickle to every views in the group.
    ///
    /// If not specify `after`, the trickle will be insert to the view's groupBy.
    func insertTrickle(_ trickle: TrickleData,
                       to groupID: GroupData.ID,
                       after afterID: TrickleData.ID? = nil,
                       toGroupBy: (_ viewID: GroupData.ViewInfo.ID) -> String? = { _ in return "NULL"}) {
        trickles[trickle.trickleID] = trickle
        guard let group = groups[groupID] else { return }
        group.viewInfo.forEach { viewInfo in
            var viewGroupby = "NULL"
            var index = -1
            if let afterID = afterID {
                guard let groupBy = viewsTrickleIDs[viewInfo.viewID]?.first(where: { (key, value) in
                    value.value?.items.contains(afterID) == true
                })?.key else { return }
                viewGroupby = groupBy
                guard let insertIndex = viewsTrickleIDs[viewInfo.viewID]?[groupBy]?.value?.items.firstIndex(of: afterID) else { return }
                index = insertIndex
            } else {
                viewGroupby = toGroupBy(viewInfo.viewID) ?? "NULL"
            }
            viewsTrickleIDs[viewInfo.viewID]?[viewGroupby] = viewsTrickleIDs[viewInfo.viewID]?[viewGroupby]?.map{ .init(items: $0.items.insertingItem(trickle.trickleID, at: index+1),
                                                                                                                        nextQuery: $0.nextQuery) }
        }
    }
    
    /// Update the source trickle found in the group relative to `groupID` to the target trickle. This function will update the trickle in every views in the group.
    func updateTrickle(from source: TrickleData, to target: TrickleData, in group: GroupData? = nil) {
        var group = group
        if group == nil {
            group = try? findTrickleGroup(source.trickleID)
        }
        trickles.removeValue(forKey: source.trickleID)
        trickles[target.trickleID] = target
        group?.viewInfo.forEach { viewInfo in
            guard let groupBy = viewsTrickleIDs[viewInfo.viewID]?.first(where: { (key, value) in
                value.value?.items.contains(source.trickleID) == true
            })?.key else { return }
            guard let index = viewsTrickleIDs[viewInfo.viewID]?[groupBy]?.value?.items.firstIndex(of: source.trickleID) else { return }
            
            viewsTrickleIDs[viewInfo.viewID]?[groupBy] = viewsTrickleIDs[viewInfo.viewID]?[groupBy]?.map{ .init(items: $0.items.replacingItem(target.trickleID, at: index),
                                                                                                                nextQuery: $0.nextQuery) }
        }
    }
    
    func moveTrickle(_ trickleID: TrickleData.ID, to targetGroupID: GroupData.ID) {
        guard let trickle = trickles[trickleID],
              let group = try? findTrickleGroup(trickleID) else { return }
        
        removeTrickle(trickleID, in: group)
        insertTrickle(trickle, to: targetGroupID)
    }
    
    func removeTrickle(_ trickleID: TrickleData.ID, in group: GroupData? = nil) {
        var group = group
        if group == nil {
            group = try? findTrickleGroup(trickleID)
        }
        trickles.removeValue(forKey: trickleID)
        group?.viewInfo.forEach { viewInfo in
            guard let groupBy = viewsTrickleIDs[viewInfo.viewID]?.first(where: { (key, value) in
                value.value?.items.contains(trickleID) == true
            })?.key else { return }
            guard viewsTrickleIDs[viewInfo.viewID]?[groupBy]?.value?.items.contains(trickleID) == true else { return }

            viewsTrickleIDs[viewInfo.viewID]?[groupBy] = viewsTrickleIDs[viewInfo.viewID]?[groupBy]?.map{ .init(items: $0.items.removingItem(of: trickleID),
                                                                                                                nextQuery: $0.nextQuery) }
        }
    }
    
    func appendTrickles(_ trickles: AnyQueryStreamable<TrickleData>,
                        to viewID: GroupData.ViewInfo.ID,
                        groupByID: FieldOptions.FieldOptionInfo.ID = "NULL",
                        replace: Bool = false) {
        trickles.items.forEach { trickleData in
            self.trickles.updateValue(trickleData, forKey: trickleData.trickleID)
            if tricklesCommentIDs[trickleData.trickleID] == nil {
                self.tricklesCommentIDs[trickleData.trickleID] = .loaded(data: .init(items: [], nextTs: Int(Date.now.timeIntervalSince1970)))
            }
        }
        viewsTrickleIDs[viewID]?[groupByID] = .loaded(data: viewsTrickleIDs[viewID]?[groupByID]?.value?.appending(trickles.map{$0.trickleID}, replace: replace) ?? trickles.map{$0.trickleID})
    }
    
    func prependTrickles(_ trickles: AnyQueryStreamable<TrickleData>,
                         to viewID: GroupData.ViewInfo.ID,
                         groupByID: FieldOptions.FieldOptionInfo.ID = "NULL") {
        trickles.items.forEach { trickleData in
            self.trickles.updateValue(trickleData, forKey: trickleData.trickleID)
            if tricklesCommentIDs[trickleData.trickleID] == nil {
                self.tricklesCommentIDs[trickleData.trickleID] = .loaded(data: .init(items: [], nextTs: Int(Date.now.timeIntervalSince1970)))
            }
        }
        viewsTrickleIDs[viewID]?[groupByID] = .loaded(data: viewsTrickleIDs[viewID]?[groupByID]?.value?.prepending(trickles.map{$0.trickleID}) ?? trickles.map{$0.trickleID})
    }
    
    func addViewedMember(_ memberID: MemberData.ID, to trickleID: TrickleData.ID) {
        if trickles[trickleID]?.viewedMemberInfo.members.contains(where: {$0.memberID == memberID}) == true {
            return
        }
        
        guard let memberData = members[memberID] else { return }
        
        trickles[trickleID]?.viewedMemberInfo.counts += 1
        trickles[trickleID]?.viewedMemberInfo.members.append(memberData)
    }
    
    func removeViewedMember(_ memberID: MemberData.ID, of trickleID: TrickleData.ID) {
        guard trickles[trickleID]?.viewedMemberInfo.members.contains(where: {$0.memberID == memberID}) == true else {
            return
        }
                
        trickles[trickleID]?.viewedMemberInfo.members.removeAll(where: {$0.memberID == memberID})
        trickles[trickleID]?.viewedMemberInfo.counts -= trickles[trickleID]?.viewedMemberInfo.members.count ?? 0
    }
}
